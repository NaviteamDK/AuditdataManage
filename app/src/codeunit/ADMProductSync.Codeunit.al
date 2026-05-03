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
        lItemMapping: Record "ADM Item Mapping";
        lItem: Record Item;
    begin
        ErrorText := '';
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

        if IsNullGuid(lItemMapping."Manage Category ID") then begin
            lItemMapping.MarkSyncError(lItem."No.", 'Manage Category ID is not set on the item mapping. Open Item Mappings, set the category, then re-sync.');
            exit(false);
        end;

        RequestBody := BuildProductPayload(lItem, lItemMapping);

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

    local procedure BuildProductPayload(Item: Record Item; ItemMapping: Record "ADM Item Mapping"): Text
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
        JsonObj.Add('categoryId', LowerCase(Format(ItemMapping."Manage Category ID", 0, 4)));

        if Item."Unit Price" <> 0 then
            JsonObj.Add('price', Item."Unit Price");

        if Item."Base Unit of Measure" <> '' then
            JsonObj.Add('unitOfMeasure', Item."Base Unit of Measure");

        if Item."Description 2" <> '' then
            JsonObj.Add('description', Item."Description 2");

        JsonObj.Add('isSerialized', Item."Item Tracking Code" <> '');

        if not IsNullGuid(ItemMapping."Manage Manufacturer ID") then
            JsonObj.Add('manufacturerId', LowerCase(Format(ItemMapping."Manage Manufacturer ID", 0, 4)));

        if not IsNullGuid(ItemMapping."Manage Supplier ID") then
            JsonObj.Add('supplierId', LowerCase(Format(ItemMapping."Manage Supplier ID", 0, 4)));

        JsonObj.Add('firstVAT', ItemMapping."First VAT");
        JsonObj.Add('secondVAT', ItemMapping."Second VAT");

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

    /// <summary>
    /// Fetches all products from AuditData Manage and creates/updates ADM Item Mapping records.
    /// Matches by SKU to BC Item No. Returns counts of linked, unmatched and already-mapped products.
    /// </summary>
    procedure FetchManageProducts(var Linked: Integer; var Unmatched: Integer; var AlreadyMapped: Integer; var ErrorText: Text): Boolean
    var
        ItemMapping: Record "ADM Item Mapping";
        AllProducts: JsonArray;
        ProductToken: JsonToken;
        ProductObj: JsonObject;
        ManageProductID: Guid;
        ManageSKU: Text;
        ItemNo: Code[20];
        ResponseText: Text;
    begin
        if not ADMAPIClient.TryGet('api/v2/inventory/products', ResponseText, ErrorText) then
            exit(false);

        ADMAPIClient.GetPaged('api/v2/inventory/products', AllProducts);

        foreach ProductToken in AllProducts do begin
            ProductObj := ProductToken.AsObject();
            ManageProductID := ADMAPIClient.GetJsonGuid(ProductObj, 'id');
            ManageSKU := ADMAPIClient.GetJsonText(ProductObj, 'sku');

            if IsNullGuid(ManageProductID) then
                continue;

            // Check if already mapped by Manage Product ID
            ItemMapping.SetRange("Manage Product ID", ManageProductID);
            if not ItemMapping.IsEmpty() then begin
                AlreadyMapped += 1;
                continue;
            end;
            ItemMapping.Reset();

            // Try to match BC Item by SKU
            ItemNo := CopyStr(ManageSKU, 1, 20);
            if (ItemNo <> '') and ItemMapping.Get(ItemNo) then begin
                // Item mapping exists but without Manage Product ID — fill it in
                ItemMapping."Manage Product ID" := ManageProductID;
                ItemMapping."Manage SKU" := CopyStr(ManageSKU, 1, 100);
                ItemMapping."Needs Sync" := false;
                ItemMapping.Modify();
                Linked += 1;
            end else
                if (ItemNo <> '') and not ItemMapping.Get(ItemNo) then begin
                    // No mapping yet — create one if the BC item exists
                    if ItemExistsInBC(ItemNo) then begin
                        ItemMapping.Init();
                        ItemMapping."Item No." := ItemNo;
                        ItemMapping."Manage Product ID" := ManageProductID;
                        ItemMapping."Manage SKU" := CopyStr(ManageSKU, 1, 100);
                        ItemMapping."Needs Sync" := false;
                        ItemMapping.Insert();
                        Linked += 1;
                    end else
                        Unmatched += 1;
                end else
                    Unmatched += 1;
        end;

        exit(true);
    end;

    local procedure ItemExistsInBC(ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
    begin
        exit(Item.Get(ItemNo));
    end;

    procedure AddAllBCItemsToMapping(var Added: Integer; var Skipped: Integer)
    var
        Item: Record Item;
        ItemMapping: Record "ADM Item Mapping";
    begin
        if not Item.FindSet() then
            exit;

        repeat
            if not ItemMapping.Get(Item."No.") then begin
                ItemMapping.Init();
                ItemMapping."Item No." := Item."No.";
                ItemMapping."Needs Sync" := true;
                ItemMapping.Insert();
                Added += 1;
            end else
                Skipped += 1;
        until Item.Next() = 0;
    end;
}
