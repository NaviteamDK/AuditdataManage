codeunit 80307 "ADM Sale Sync"
{
    procedure SyncSales()
    var
        IntegrationSetup: Record "ADM Integration Setup";
        SyncLogManager: Codeunit "ADM Sync Log Manager";
        LogEntryNo: Integer;
        Processed: Integer;
        Failed: Integer;
    begin
        IntegrationSetup := IntegrationSetup.GetSetup();
        if not IntegrationSetup."Sale Sync Enabled" then
            exit;

        LogEntryNo := SyncLogManager.StartLog("ADM Sync Direction"::Inbound, 'Sale Sync');

        if not TrySyncSales(Processed, Failed) then begin
            SyncLogManager.FailLog(LogEntryNo, GetLastErrorText());
            exit;
        end;

        IntegrationSetup."Last Sale Sync" := CurrentDateTime();
        IntegrationSetup.Modify();

        SyncLogManager.FinishLog(LogEntryNo, Processed, Failed);
    end;

    local procedure TrySyncSales(var Processed: Integer; var Failed: Integer): Boolean
    var
        SaleBufferHeader: Record "ADM Sale Buffer Header";
        ADMAPIClient: Codeunit "ADM API Client";
        AllResults: JsonArray;
        SaleToken: JsonToken;
        SaleObj: JsonObject;
        ManageSaleID: Guid;
    begin
        ADMAPIClient.GetPaged('api/v2/invoicing/sales', AllResults);

        foreach SaleToken in AllResults do begin
            SaleObj := SaleToken.AsObject();
            ManageSaleID := ADMAPIClient.GetJsonGuid(SaleObj, 'id');

            if IsNullGuid(ManageSaleID) then begin
                Failed += 1;
                continue;
            end;

            // Skip already processed sales
            if SaleBufferHeader.Get(ManageSaleID) then
                if SaleBufferHeader.Status = "ADM Buffer Status"::Processed then begin
                    Processed += 1;
                    continue;
                end;

            if ImportSale(ManageSaleID, ADMAPIClient) then
                Processed += 1
            else
                Failed += 1;

            Commit();
        end;

        exit(true);
    end;

    local procedure ImportSale(ManageSaleID: Guid; ADMAPIClient: Codeunit "ADM API Client"): Boolean
    var
        SaleBufferHeader: Record "ADM Sale Buffer Header";
        SaleObj: JsonObject;
        ResponseText: Text;
        ErrorText: Text;
        SaleIDText: Text;
        SaleUrlLbl: Label 'api/v2/invoicing/sales/%1', Comment = '%1 = sale ID';
    begin
        SaleIDText := LowerCase(Format(ManageSaleID, 0, 4));

        // Fetch full sale details
        if not ADMAPIClient.TryGet(
            StrSubstNo(SaleUrlLbl, SaleIDText),
            ResponseText, ErrorText)
        then
            exit(false);

        SaleObj.ReadFrom(ResponseText);

        // Upsert Sale Buffer Header
        if not SaleBufferHeader.Get(ManageSaleID) then begin
            SaleBufferHeader.Init();
            SaleBufferHeader."Manage Sale ID" := ManageSaleID;
            SaleBufferHeader."Imported At" := CurrentDateTime();
            SaleBufferHeader.Status := "ADM Buffer Status"::New;
            SaleBufferHeader.Insert();
        end;

        PopulateSaleHeader(SaleBufferHeader, SaleObj, ADMAPIClient);
        SaleBufferHeader.Modify();

        // Fetch and import sale lines
        ImportSaleLines(ManageSaleID, SaleIDText, ADMAPIClient);

        // Try to resolve BC Client Customer No. from mapping
        ResolveBCClientCustomer(SaleBufferHeader);

        exit(true);
    end;

    local procedure PopulateSaleHeader(var SaleBufferHeader: Record "ADM Sale Buffer Header"; SaleObj: JsonObject; ADMAPIClient: Codeunit "ADM API Client")
    var
        ClientObj: JsonObject;
        LocationObj: JsonObject;
        ClientID: Guid;
    begin
        SaleBufferHeader."Sale No." := CopyStr(
            ADMAPIClient.GetJsonText(SaleObj, 'saleNumber'), 1, 50);
        SaleBufferHeader."Sale Date" := ADMAPIClient.ParseDate(
            ADMAPIClient.GetJsonText(SaleObj, 'saleDate'));
        SaleBufferHeader."Sale Status" := CopyStr(
            ADMAPIClient.GetJsonText(SaleObj, 'status'), 1, 50);
        SaleBufferHeader."Total Amount" := ADMAPIClient.GetJsonDecimal(SaleObj, 'totalAmount');
        SaleBufferHeader."VAT Amount" := ADMAPIClient.GetJsonDecimal(SaleObj, 'vatAmount');
        SaleBufferHeader."Amount Excluding VAT" :=
            SaleBufferHeader."Total Amount" - SaleBufferHeader."VAT Amount";
        SaleBufferHeader."Currency Code" := CopyStr(
            ADMAPIClient.GetJsonText(SaleObj, 'currencyCode'), 1, 10);
        SaleBufferHeader."External Doc. No." := CopyStr(
            ADMAPIClient.GetJsonText(SaleObj, 'externalReference'), 1, 50);
        SaleBufferHeader.Notes := CopyStr(
            ADMAPIClient.GetJsonText(SaleObj, 'notes'), 1, 2048);
        SaleBufferHeader."Manage Created At" := ADMAPIClient.ParseDateTime(
            ADMAPIClient.GetJsonText(SaleObj, 'createdAt'));
        SaleBufferHeader."Manage Updated At" := ADMAPIClient.ParseDateTime(
            ADMAPIClient.GetJsonText(SaleObj, 'updatedAt'));

        // Resolve client info
        if ADMAPIClient.GetJsonObject(SaleObj, 'patient', ClientObj) then begin
            ClientID := ADMAPIClient.GetJsonGuid(ClientObj, 'id');
            SaleBufferHeader."Manage Client ID" := ClientID;
            SaleBufferHeader."Client Name" := CopyStr(
                ADMAPIClient.GetJsonText(ClientObj, 'fullName'), 1, 200);
        end else
            // Try direct patientId field
            SaleBufferHeader."Manage Client ID" := ADMAPIClient.GetJsonGuid(SaleObj, 'patientId');

        // Resolve location info
        if ADMAPIClient.GetJsonObject(SaleObj, 'location', LocationObj) then begin
            SaleBufferHeader."Location ID" := ADMAPIClient.GetJsonGuid(LocationObj, 'id');
            SaleBufferHeader."Location Name" := CopyStr(
                ADMAPIClient.GetJsonText(LocationObj, 'name'), 1, 100);
        end;
    end;

    local procedure ImportSaleLines(ManageSaleID: Guid; SaleIDText: Text; ADMAPIClient: Codeunit "ADM API Client")
    var
        SaleBufferLine: Record "ADM Sale Buffer Line";
        ItemMapping: Record "ADM Item Mapping";
        ResponseText: Text;
        ErrorText: Text;
        ProductsArray: JsonArray;
        ProductToken: JsonToken;
        ProductObj: JsonObject;
        LineNo: Integer;
        ManageProductID: Guid;
        SaleLinesUrlLbl: Label 'api/v2/invoicing/sales/%1/products', Comment = '%1 = sale ID';
    begin
        if not ADMAPIClient.TryGet(
            StrSubstNo(SaleLinesUrlLbl, SaleIDText),
            ResponseText, ErrorText)
        then
            exit;

        ProductsArray.ReadFrom(ResponseText);

        // Delete existing lines before re-importing
        SaleBufferLine.SetRange("Manage Sale ID", ManageSaleID);
        SaleBufferLine.DeleteAll();

        LineNo := 10000;
        foreach ProductToken in ProductsArray do begin
            ProductObj := ProductToken.AsObject();

            SaleBufferLine.Init();
            SaleBufferLine."Manage Sale ID" := ManageSaleID;
            SaleBufferLine."Line No." := LineNo;
            SaleBufferLine."Manage Sale Product ID" :=
                ADMAPIClient.GetJsonGuid(ProductObj, 'id');

            ManageProductID := ADMAPIClient.GetJsonGuid(ProductObj, 'productId');
            SaleBufferLine."Manage Product ID" := ManageProductID;

            // Try to resolve BC Item No. from item mapping
            if not IsNullGuid(ManageProductID) then
                SaleBufferLine."BC Item No." :=
                    ItemMapping.FindByManageProductID(ManageProductID);

            SaleBufferLine."Product Name" := CopyStr(
                ADMAPIClient.GetJsonText(ProductObj, 'name'), 1, 200);
            SaleBufferLine."Product SKU" := CopyStr(
                ADMAPIClient.GetJsonText(ProductObj, 'sku'), 1, 100);
            SaleBufferLine."Product Category" := CopyStr(
                ADMAPIClient.GetJsonText(ProductObj, 'categoryName'), 1, 100);
            SaleBufferLine.Quantity := ADMAPIClient.GetJsonDecimal(ProductObj, 'quantity');
            SaleBufferLine."Unit Price" := ADMAPIClient.GetJsonDecimal(ProductObj, 'unitPrice');
            SaleBufferLine."Discount Percentage" :=
                ADMAPIClient.GetJsonDecimal(ProductObj, 'discountPercentage');
            SaleBufferLine."Discount Amount" :=
                ADMAPIClient.GetJsonDecimal(ProductObj, 'discountAmount');
            SaleBufferLine."Line Amount" := ADMAPIClient.GetJsonDecimal(ProductObj, 'lineAmount');
            SaleBufferLine."VAT Amount" := ADMAPIClient.GetJsonDecimal(ProductObj, 'vatAmount');
            SaleBufferLine."Serial No." := CopyStr(
                ADMAPIClient.GetJsonText(ProductObj, 'serialNumber'), 1, 50);
            SaleBufferLine."Is Serialized" :=
                ADMAPIClient.GetJsonBoolean(ProductObj, 'isSerialized');

            SaleBufferLine.Insert();
            LineNo += 10000;
        end;
    end;

    local procedure ResolveBCClientCustomer(var SaleBufferHeader: Record "ADM Sale Buffer Header")
    var
        CustomerMapping: Record "ADM Customer Mapping";
        CustomerNo: Code[20];
    begin
        if IsNullGuid(SaleBufferHeader."Manage Client ID") then
            exit;
        CustomerNo := CustomerMapping.FindCustomerNo(SaleBufferHeader."Manage Client ID");
        if CustomerNo <> '' then begin
            SaleBufferHeader."BC Client Customer No." := CustomerNo;
            SaleBufferHeader.Modify();
        end;
    end;
}
