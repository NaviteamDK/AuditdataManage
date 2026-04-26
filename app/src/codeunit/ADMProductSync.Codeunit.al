codeunit 80308 "ADM Product Sync"
{
    var
        ADMAPIClient: Codeunit "ADM API Client";

    procedure SyncItems()
    var
        IntegrationSetup: Record "ADM Integration Setup";
        SyncLogManager: Codeunit "ADM Sync Log Manager";
        LogEntryNo: Integer;
        Processed: Integer;
        Failed: Integer;
    begin
        IntegrationSetup := IntegrationSetup.GetSetup();
        if not IntegrationSetup."Item Sync Enabled" then
            exit;

        LogEntryNo := SyncLogManager.StartLog("ADM Sync Direction"::Outbound, 'Item Sync');

        if not TrySyncItems(Processed, Failed) then begin
            SyncLogManager.FailLog(LogEntryNo, GetLastErrorText());
            exit;
        end;

        IntegrationSetup."Last Item Sync" := CurrentDateTime();
        IntegrationSetup.Modify();

        SyncLogManager.FinishLog(LogEntryNo, Processed, Failed);
    end;

    local procedure TrySyncItems(var Processed: Integer; var Failed: Integer): Boolean
    var
        lItemMapping: Record "ADM Item Mapping";
        lItem: Record Item;
    begin
        lItemMapping.SetRange("Needs Sync", true);
        if not lItemMapping.FindSet(true) then
            exit(true); // Nothing to sync

        repeat
            if lItem.Get(lItemMapping."Item No.") then begin
                if PushItem(lItem, lItemMapping) then
                    Processed += 1
                else
                    Failed += 1;
            end else begin
                // Item was deleted - skip
                lItemMapping."Needs Sync" := false;
                lItemMapping.Modify();
            end;
            Commit();
        until lItemMapping.Next() = 0;

        exit(true);
    end;

    local procedure PushItem(var lItem: Record Item; var lItemMapping: Record "ADM Item Mapping"): Boolean
    var
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
        IsNew := IsNullGuid(lItemMapping."Manage Product ID");

        RequestBody := BuildProductPayload(lItem);

        if IsNew then begin
            // POST - create new product
            if not ADMAPIClient.TryPost(
                'api/v2/inventory/products',
                RequestBody, ResponseText, ErrorText)
            then begin
                lItemMapping.MarkSyncError(lItem."No.", ErrorText);
                exit(false);
            end;

            // Parse returned ID from response
            if ResponseJson.ReadFrom(ResponseText) then begin
                ManageProductID := ADMAPIClient.GetJsonGuid(ResponseJson, 'id');
                if IsNullGuid(ManageProductID) then
                    // Try nested data field
                    if ADMAPIClient.GetJsonObject(ResponseJson, 'data', DataObj) then
                        ManageProductID := ADMAPIClient.GetJsonGuid(DataObj, 'id');
            end;

            lItemMapping.MarkSynced(lItem."No.", ManageProductID,
                CopyStr(lItem."No.", 1, 100));
        end else begin
            // PUT - update existing product
            ManageIDText := LowerCase(Format(lItemMapping."Manage Product ID", 0, 4));
            if not ADMAPIClient.TryPut(
                StrSubstNo(ProductUrlLbl, ManageIDText),
                RequestBody, ResponseText, ErrorText)
            then begin
                lItemMapping.MarkSyncError(lItem."No.", ErrorText);
                exit(false);
            end;

            lItemMapping.MarkSynced(lItem."No.",
                lItemMapping."Manage Product ID",
                CopyStr(lItem."No.", 1, 100));
        end;

        exit(true);
    end;

    local procedure BuildProductPayload(Item: Record Item): Text
    var
        JsonObj: JsonObject;
        PayloadText: Text;
    begin
        JsonObj.Add('name', Item.Description);
        JsonObj.Add('sku', Item."No.");
        JsonObj.Add('isActive', not Item.Blocked);

        if Item."Unit Price" <> 0 then
            JsonObj.Add('price', Item."Unit Price");

        if Item."Base Unit of Measure" <> '' then
            JsonObj.Add('unitOfMeasure', Item."Base Unit of Measure");

        if Item."Item Category Code" <> '' then
            JsonObj.Add('categoryCode', Item."Item Category Code");

        if Item."Description 2" <> '' then
            JsonObj.Add('description', Item."Description 2");

        JsonObj.Add('isSerialized', Item."Item Tracking Code" <> '');

        JsonObj.WriteTo(PayloadText);
        exit(PayloadText);
    end;

    procedure SyncSingleItem(ItemNo: Code[20])
    var
        lItem: Record Item;
        lItemMapping: Record "ADM Item Mapping";
    begin
        if not lItem.Get(ItemNo) then
            exit;

        if not lItemMapping.Get(ItemNo) then begin
            lItemMapping.Init();
            lItemMapping."Item No." := ItemNo;
            lItemMapping."Needs Sync" := true;
            lItemMapping.Insert();
        end else begin
            lItemMapping."Needs Sync" := true;
            lItemMapping.Modify();
        end;

        PushItem(lItem, lItemMapping);
    end;
}
