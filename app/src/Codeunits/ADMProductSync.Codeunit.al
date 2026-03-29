codeunit 50108 "ADM Product Sync"
{
    Caption = 'ADM Product Sync';

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
        ItemMapping: Record "ADM Item Mapping";
        Item: Record Item;
    begin
        ItemMapping.SetRange("Needs Sync", true);
        if not ItemMapping.FindSet(true) then
            exit(true); // Nothing to sync

        repeat
            if Item.Get(ItemMapping."Item No.") then begin
                if PushItem(Item, ItemMapping) then
                    Processed += 1
                else
                    Failed += 1;
            end else begin
                // Item was deleted - skip
                ItemMapping."Needs Sync" := false;
                ItemMapping.Modify();
            end;
            Commit();
        until ItemMapping.Next() = 0;

        exit(true);
    end;

    local procedure PushItem(var Item: Record Item; var ItemMapping: Record "ADM Item Mapping"): Boolean
    var
        ADMAPIClient: Codeunit "ADM API Client";
        RequestBody: Text;
        ResponseText: Text;
        ErrorText: Text;
        ResponseJson: JsonObject;
        ManageProductID: Guid;
        ManageIDText: Text;
        IsNew: Boolean;
    begin
        IsNew := IsNullGuid(ItemMapping."Manage Product ID");

        RequestBody := BuildProductPayload(Item);

        if IsNew then begin
            // POST - create new product
            if not ADMAPIClient.TryPost(
                'api/v2/inventory/products',
                RequestBody, ResponseText, ErrorText)
            then begin
                ItemMapping.MarkSyncError(Item."No.", ErrorText);
                exit(false);
            end;

            // Parse returned ID from response
            if ResponseJson.ReadFrom(ResponseText) then begin
                ManageProductID := ADMAPIClient.GetJsonGuid(ResponseJson, 'id');
                if IsNullGuid(ManageProductID) then begin
                    // Try nested data field
                    var DataObj: JsonObject;
                    if ADMAPIClient.GetJsonObject(ResponseJson, 'data', DataObj) then
                        ManageProductID := ADMAPIClient.GetJsonGuid(DataObj, 'id');
                end;
            end;

            ItemMapping.MarkSynced(Item."No.", ManageProductID,
                CopyStr(Item."No.", 1, 100));
        end else begin
            // PUT - update existing product
            ManageIDText := LowerCase(Format(ItemMapping."Manage Product ID", 0, 4));
            if not ADMAPIClient.TryPut(
                StrSubstNo('api/v2/inventory/products/%1', ManageIDText),
                RequestBody, ResponseText, ErrorText)
            then begin
                ItemMapping.MarkSyncError(Item."No.", ErrorText);
                exit(false);
            end;

            ItemMapping.MarkSynced(Item."No.",
                ItemMapping."Manage Product ID",
                CopyStr(Item."No.", 1, 100));
        end;

        exit(true);
    end;

    local procedure BuildProductPayload(Item: Record Item): Text
    var
        JsonObj: JsonObject;
        Writer: TextBuilder;
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

        JsonObj.WriteTo(Writer);
        exit(Writer.ToText());
    end;

    procedure SyncSingleItem(ItemNo: Code[20])
    var
        Item: Record Item;
        ItemMapping: Record "ADM Item Mapping";
    begin
        if not Item.Get(ItemNo) then
            exit;

        if not ItemMapping.Get(ItemNo) then begin
            ItemMapping.Init();
            ItemMapping."Item No." := ItemNo;
            ItemMapping."Needs Sync" := true;
            ItemMapping.Insert();
        end else begin
            ItemMapping."Needs Sync" := true;
            ItemMapping.Modify();
        end;

        PushItem(Item, ItemMapping);
    end;
}
