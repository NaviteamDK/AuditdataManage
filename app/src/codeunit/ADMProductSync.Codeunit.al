codeunit 80308 "ADM Product Sync"
{
    var
        ADMAPIClient: Codeunit "ADM API Client";

    trigger OnRun()
    begin
        SyncItems();
    end;

    procedure SyncItems()
    var
        IntegrationSetup: Record "ADM Integration Setup";
        SyncLogManager: Codeunit "ADM Sync Log Manager";
        LogEntryNo: Integer;
        Processed: Integer;
        Failed: Integer;
        ErrorText: Text;
    begin
        IntegrationSetup := IntegrationSetup.GetSetup();
        if not IntegrationSetup."Item Sync Enabled" then
            exit;

        LogEntryNo := SyncLogManager.StartLog("ADM Sync Direction"::Outbound, 'Item Sync');

        if not TrySyncItems(Processed, Failed, ErrorText) then begin
            SyncLogManager.FailLog(LogEntryNo, ErrorText);
            exit;
        end;

        IntegrationSetup."Last Item Sync" := CurrentDateTime();
        IntegrationSetup.Modify();

        SyncLogManager.FinishLog(LogEntryNo, Processed, Failed);
    end;

    local procedure TrySyncItems(var Processed: Integer; var Failed: Integer; var ErrorText: Text): Boolean
    var
        Item: Record Item;
    begin
        ErrorText := '';
        Item.SetRange("ADM Needs Sync", true);
        if not Item.FindSet(true) then
            exit(true); // Nothing to sync

        repeat
            if PushItem(Item) then
                Processed += 1
            else
                Failed += 1;
            Commit();
        until Item.Next() = 0;

        exit(true);
    end;

    local procedure PushItem(var lItem: Record Item): Boolean
    var
        ItemMapping: Record "ADM Item Mapping";
        RequestBody: Text;
        ResponseText: Text;
        ErrorText: Text;
        ResponseJson: JsonObject;
        ManageProductID: Guid;
        ManageIDText: Text;
        IsNew: Boolean;
        DataObj: JsonObject;
        ProductUrlLbl: Label 'api/v2/inventory/products/%1', Comment = '%1 = product ID';
    begin
        IsNew := IsNullGuid(lItem."ADM Manage Product ID");

        if IsNullGuid(lItem."ADM Manage Category ID") then begin
            MarkItemSyncError(lItem, 'Manage Category ID is not set on the item. Open the Item Card, set the category, then re-sync.');
            exit(false);
        end;

        if IsHearingAidsCategory(lItem."ADM Manage Category ID") and IsNullGuid(lItem."ADM Manage Hearing Aid Type ID") then begin
            MarkItemSyncError(lItem, 'Manage Hearing Aid Type ID is required for items in the Hearing Aids category. Open the Item Card, set the hearing aid type, then re-sync.');
            exit(false);
        end;

        RequestBody := BuildProductPayload(lItem);

        if IsNew then begin
            // POST - create new product
            if not ADMAPIClient.TryPost('api/v2/inventory/products', RequestBody, ResponseText, ErrorText) then begin
                MarkItemSyncError(lItem, ErrorText);
                exit(false);
            end;

            // Parse returned ID from response
            if ResponseJson.ReadFrom(ResponseText) then begin
                ManageProductID := ADMAPIClient.GetJsonGuid(ResponseJson, 'id');
                if IsNullGuid(ManageProductID) then
                    if ADMAPIClient.GetJsonObject(ResponseJson, 'data', DataObj) then
                        ManageProductID := ADMAPIClient.GetJsonGuid(DataObj, 'id');
            end;

            // Update the catalog entry if one exists, or create it
            if not ItemMapping.Get(ManageProductID) then begin
                ItemMapping.Init();
                ItemMapping."Manage Product ID" := ManageProductID;
                ItemMapping."Manage SKU" := CopyStr(lItem."No.", 1, 100);
                ItemMapping."Item No." := lItem."No.";
                ItemMapping.Insert();
            end else begin
                if ItemMapping."Item No." = '' then begin
                    ItemMapping."Item No." := lItem."No.";
                    ItemMapping.Modify();
                end;
            end;

            MarkItemSynced(lItem, ManageProductID);
        end else begin
            // PUT - update existing product
            ManageIDText := LowerCase(Format(lItem."ADM Manage Product ID", 0, 4));
            if not ADMAPIClient.TryPut(StrSubstNo(ProductUrlLbl, ManageIDText), RequestBody, ResponseText, ErrorText) then begin
                MarkItemSyncError(lItem, ErrorText);
                exit(false);
            end;

            MarkItemSynced(lItem, lItem."ADM Manage Product ID");
        end;

        exit(true);
    end;

    local procedure BuildProductPayload(Item: Record Item): Text
    var
        ItemColor: Record "ADM Item Color";
        ItemBatteryType: Record "ADM Item Battery Type";
        ItemAttribute: Record "ADM Item Attribute";
        JsonObj: JsonObject;
        ColorsArr: JsonArray;
        BatteryTypesArr: JsonArray;
        AttributesArr: JsonArray;
        SuggestedProductsArr: JsonArray;
        PayloadText: Text;
    begin
        JsonObj.Add('name', Item.Description);
        JsonObj.Add('sku', Item."No.");
        JsonObj.Add('isActive', not Item.Blocked);
        JsonObj.Add('categoryId', LowerCase(Format(Item."ADM Manage Category ID", 0, 4)));

        if Item."Unit Price" <> 0 then
            JsonObj.Add('price', Item."Unit Price");

        if Item."Base Unit of Measure" <> '' then
            JsonObj.Add('unitOfMeasure', Item."Base Unit of Measure");

        if Item."Description 2" <> '' then
            JsonObj.Add('description', Item."Description 2");

        JsonObj.Add('isSerialized', Item."Item Tracking Code" <> '');
        JsonObj.Add('isSellable', true);

        if not IsNullGuid(Item."ADM Manage Manufacturer ID") then
            JsonObj.Add('manufacturerId', LowerCase(Format(Item."ADM Manage Manufacturer ID", 0, 4)));

        if not IsNullGuid(Item."ADM Manage Supplier ID") then
            JsonObj.Add('supplierId', LowerCase(Format(Item."ADM Manage Supplier ID", 0, 4)));

        if not IsNullGuid(Item."ADM Manage Hearing Aid Type ID") then
            JsonObj.Add('hearingAidTypeId', LowerCase(Format(Item."ADM Manage Hearing Aid Type ID", 0, 4)));

        JsonObj.Add('firstVAT', Item."ADM First VAT");
        JsonObj.Add('secondVAT', Item."ADM Second VAT");

        ColorsArr := ItemColor.GetColorIDsAsJsonArray(Item."No.");
        JsonObj.Add('colors', ColorsArr);

        BatteryTypesArr := ItemBatteryType.GetBatteryTypeIDsAsJsonArray(Item."No.");
        JsonObj.Add('batteryTypes', BatteryTypesArr);

        AttributesArr := ItemAttribute.GetAttributesAsJsonArray(Item."No.");
        JsonObj.Add('attributes', AttributesArr);

        JsonObj.Add('suggestedProductIds', SuggestedProductsArr);

        JsonObj.WriteTo(PayloadText);
        exit(PayloadText);
    end;

    local procedure MarkItemSynced(var Item: Record Item; ManageProductID: Guid)
    begin
        Item."ADM Manage Product ID" := ManageProductID;
        Item."ADM Needs Sync" := false;
        Item."ADM Last Pushed At" := CurrentDateTime();
        Item."ADM Last Push Status" := "ADM Buffer Status"::Processed;
        Item."ADM Last Push Error" := '';
        Item.Modify();
    end;

    local procedure MarkItemSyncError(var Item: Record Item; ErrorText: Text)
    begin
        Item."ADM Needs Sync" := true;
        Item."ADM Last Pushed At" := CurrentDateTime();
        Item."ADM Last Push Status" := "ADM Buffer Status"::Error;
        Item."ADM Last Push Error" := CopyStr(ErrorText, 1, 500);
        Item.Modify();
    end;

    procedure SyncSingleItem(ItemNo: Code[20])
    var
        Item: Record Item;
    begin
        if not Item.Get(ItemNo) then
            exit;

        Item."ADM Needs Sync" := true;
        Item.Modify();

        PushItem(Item);
    end;

    /// <summary>
    /// Fetches all products from AuditData Manage and upserts them into the ADM Item Mapping
    /// catalog table. Where the Manage SKU matches a BC Item No., the Manage Product ID is
    /// written directly onto the BC item. Returns counts of linked, unmatched and already-linked products.
    /// </summary>
    procedure FetchManageProducts(var Linked: Integer; var Unmatched: Integer; var AlreadyLinked: Integer; var ErrorText: Text): Boolean
    var
        ItemMapping: Record "ADM Item Mapping";
        Item: Record Item;
        AllProducts: JsonArray;
        ProductToken: JsonToken;
        ProductObj: JsonObject;
        ManageProductID: Guid;
        ManageSKU: Text;
        ManageName: Text;
        ManageIsActive: Boolean;
        ItemNo: Code[20];
    begin
        if not ADMAPIClient.TryGetPaged('api/v2/inventory/products', AllProducts, ErrorText) then
            exit(false);

        foreach ProductToken in AllProducts do begin
            ProductObj := ProductToken.AsObject();
            ManageProductID := ADMAPIClient.GetJsonGuid(ProductObj, 'id');
            ManageSKU := ADMAPIClient.GetJsonText(ProductObj, 'sku');
            ManageName := ADMAPIClient.GetJsonText(ProductObj, 'name');
            ManageIsActive := ADMAPIClient.GetJsonBoolean(ProductObj, 'isActive');

            if IsNullGuid(ManageProductID) then
                continue;

            // Upsert into catalog
            if not ItemMapping.Get(ManageProductID) then begin
                ItemMapping.Init();
                ItemMapping."Manage Product ID" := ManageProductID;
                ItemMapping.Insert();
            end;
            ItemMapping."Manage SKU" := CopyStr(ManageSKU, 1, 100);
            ItemMapping.Name := CopyStr(ManageName, 1, 250);
            ItemMapping."Is Active" := ManageIsActive;
            ItemMapping.Modify();

            // Check if already linked to a BC item
            ItemNo := ItemMapping."Item No.";
            if (ItemNo <> '') and Item.Get(ItemNo) and (not IsNullGuid(Item."ADM Manage Product ID")) then begin
                AlreadyLinked += 1;
                continue;
            end;

            // Try to match by SKU
            ItemNo := CopyStr(ManageSKU, 1, 20);
            if (ItemNo <> '') and Item.Get(ItemNo) then begin
                Item."ADM Manage Product ID" := ManageProductID;
                Item.Modify();
                if ItemMapping."Item No." = '' then begin
                    ItemMapping."Item No." := ItemNo;
                    ItemMapping.Modify();
                end;
                Linked += 1;
            end else
                Unmatched += 1;
        end;

        exit(true);
    end;

    local procedure IsHearingAidsCategory(CategoryID: Guid): Boolean
    var
        ProdCat: Record "ADM Product Category";
    begin
        if IsNullGuid(CategoryID) then
            exit(false);
        if not ProdCat.Get(CategoryID) then
            exit(false);
        exit(UpperCase(ProdCat.Code) = 'HEARINGAIDS');
    end;
}
