codeunit 80312 "ADM Stock Sync"
{
    Description = 'Synchronises stock levels from Business Central to AuditData Manage.';

    trigger OnRun()
    begin
        SyncStock();
    end;

    var
        ADMAPIClient: Codeunit "ADM API Client";
        StockSyncLbl: Label 'Stock Sync';
        ProductUrlLbl: Label 'api/v2/inventory/products/%1', Comment = '%1 = Manage product ID (GUID)';
        AdjustNotSerializedUrlLbl: Label 'api/v2/inventory/stock/locations/%1/products/%2/not-serialized/adjust', Comment = '%1 = Manage location ID, %2 = Manage product ID';
        AdjustSerializedUrlLbl: Label 'api/v2/inventory/stock/locations/%1/products/%2/serialized/adjust', Comment = '%1 = Manage location ID, %2 = Manage product ID';
        NoLocationConfiguredErr: Label 'No Manage Location ID is configured. Set the Default Manage Location ID in the Integration Setup, or assign a Manage Location ID to one or more BC Locations.';

    procedure SyncStock()
    var
        IntegrationSetup: Record "ADM Integration Setup";
        SyncLogManager: Codeunit "ADM Sync Log Manager";
        LogEntryNo: Integer;
        Processed: Integer;
        Failed: Integer;
    begin
        IntegrationSetup := IntegrationSetup.GetSetup();
        if not IntegrationSetup."Stock Sync Enabled" then
            exit;

        LogEntryNo := SyncLogManager.StartLog("ADM Sync Direction"::Outbound, StockSyncLbl);

        if not HasAnyLocationConfigured(IntegrationSetup) then begin
            SyncLogManager.FailLog(LogEntryNo, NoLocationConfiguredErr);
            exit;
        end;

        TrySyncAll(IntegrationSetup, Processed, Failed);

        IntegrationSetup."Last Stock Sync" := CurrentDateTime();
        IntegrationSetup.Modify();

        SyncLogManager.FinishLog(LogEntryNo, Processed, Failed);
    end;

    local procedure HasAnyLocationConfigured(IntegrationSetup: Record "ADM Integration Setup"): Boolean
    begin
        if not IsNullGuid(IntegrationSetup."Default Manage Location ID") then
            exit(true);
        exit(AnyBCLocationHasMappedManageLocation());
    end;

    local procedure AnyBCLocationHasMappedManageLocation(): Boolean
    var
        Location: Record Location;
    begin
        if not Location.FindSet() then
            exit(false);
        repeat
            if not IsNullGuid(Location."ADM Manage Location ID") then
                exit(true);
        until Location.Next() = 0;
        exit(false);
    end;

    local procedure TrySyncAll(IntegrationSetup: Record "ADM Integration Setup"; var Processed: Integer; var Failed: Integer)
    var
        Item: Record Item;
        IsSerialized: Boolean;
        UseLocationMappings: Boolean;
    begin
        UseLocationMappings := AnyBCLocationHasMappedManageLocation();

        if not Item.FindSet() then
            exit;

        repeat
            if IsNullGuid(Item."ADM Manage Product ID") then begin
                // No Manage product linked yet — skip
            end else begin
                IsSerialized := Item."Item Tracking Code" <> '';
                if UseLocationMappings then begin
                    if IsSerialized then
                        SyncSerializedItemPerLocation(Item, Processed, Failed)
                    else
                        SyncItemPerLocation(Item, Processed, Failed);
                end else begin
                    if IsSerialized then
                        SyncSerializedItemToDefaultLocation(IntegrationSetup, Item, Processed, Failed)
                    else
                        SyncItemToDefaultLocation(IntegrationSetup, Item, Processed, Failed);
                end;
            end;
            Commit();
        until Item.Next() = 0;
    end;

    // ── Non-serialized ─────────────────────────────────────────────────────────

    /// <summary>
    /// Single-location mode: compare total BC inventory against Manage's quantity
    /// and adjust at the Default Manage Location.
    /// </summary>
    local procedure SyncItemToDefaultLocation(IntegrationSetup: Record "ADM Integration Setup"; var Item: Record Item; var Processed: Integer; var Failed: Integer)
    var
        ManageQty: Integer;
        BCQty: Integer;
        Delta: Integer;
    begin
        ManageQty := GetManageQuantity(Item."ADM Manage Product ID");
        if ManageQty = -1 then begin
            Failed += 1;
            exit;
        end;

        Item.CalcFields(Inventory);
        BCQty := Round(Item.Inventory, 1);
        Delta := BCQty - ManageQty;

        if Delta = 0 then begin
            Processed += 1;
            exit;
        end;

        if AdjustManageStock(IntegrationSetup."Default Manage Location ID", Item."ADM Manage Product ID", Delta) then
            Processed += 1
        else
            Failed += 1;
    end;

    /// <summary>
    /// Multi-location mode: for each BC Location with a Manage Location ID,
    /// compare that location's BC inventory against Manage's total product quantity
    /// and adjust the corresponding Manage location.
    /// </summary>
    local procedure SyncItemPerLocation(var Item: Record Item; var Processed: Integer; var Failed: Integer)
    var
        Location: Record Location;
        ManageQty: Integer;
        BCQty: Integer;
        Delta: Integer;
        ManageQtyFetched: Boolean;
    begin
        ManageQtyFetched := false;

        if not Location.FindSet() then
            exit;

        repeat
            if not IsNullGuid(Location."ADM Manage Location ID") then begin
                if not ManageQtyFetched then begin
                    ManageQty := GetManageQuantity(Item."ADM Manage Product ID");
                    ManageQtyFetched := true;
                end;

                if ManageQty = -1 then begin
                    Failed += 1;
                    exit;
                end;

                BCQty := GetBCInventoryForLocation(Item."No.", Location.Code);
                Delta := BCQty - ManageQty;

                if Delta = 0 then
                    Processed += 1
                else begin
                    if AdjustManageStock(Location."ADM Manage Location ID", Item."ADM Manage Product ID", Delta) then
                        Processed += 1
                    else
                        Failed += 1;
                end;
            end;
        until Location.Next() = 0;
    end;

    // ── Serialized ─────────────────────────────────────────────────────────────

    /// <summary>
    /// Single-location mode for serialized items.
    /// Compares the count of BC serial numbers in stock (all locations) against
    /// Manage's total quantity, then pushes the newest unsynced serial numbers.
    /// Delta &lt;= 0 is skipped — serial removal requires knowing which serials
    /// Manage holds, which the API does not expose in bulk.
    /// </summary>
    local procedure SyncSerializedItemToDefaultLocation(IntegrationSetup: Record "ADM Integration Setup"; var Item: Record Item; var Processed: Integer; var Failed: Integer)
    var
        ManageQty: Integer;
        BCSerials: List of [Text];
        SerialNumbers: List of [Text];
        Delta: Integer;
        i: Integer;
    begin
        ManageQty := GetManageQuantity(Item."ADM Manage Product ID");
        if ManageQty = -1 then begin
            Failed += 1;
            exit;
        end;

        GetBCSerialNumbersInStock(Item."No.", '', BCSerials);
        Delta := BCSerials.Count - ManageQty;

        if Delta <= 0 then begin
            // Quantities match or Manage has more — nothing to push
            Processed += 1;
            exit;
        end;

        // Take the newest Delta serial numbers (sorted desc by Posting Date in GetBCSerialNumbersInStock)
        for i := 1 to Delta do
            SerialNumbers.Add(BCSerials.Get(i));

        if AdjustManageStockSerialized(
            IntegrationSetup."Default Manage Location ID",
            Item."ADM Manage Product ID",
            SerialNumbers)
        then
            Processed += 1
        else
            Failed += 1;
    end;

    /// <summary>
    /// Multi-location mode for serialized items.
    /// For each BC Location that has a Manage Location ID, compares the count of
    /// serial numbers in BC stock at that location against Manage's total quantity,
    /// then pushes the newest unsynced serial numbers.
    /// </summary>
    local procedure SyncSerializedItemPerLocation(var Item: Record Item; var Processed: Integer; var Failed: Integer)
    var
        Location: Record Location;
        ManageQty: Integer;
        BCSerials: List of [Text];
        SerialNumbers: List of [Text];
        Delta: Integer;
        i: Integer;
        ManageQtyFetched: Boolean;
    begin
        ManageQtyFetched := false;

        if not Location.FindSet() then
            exit;

        repeat
            if not IsNullGuid(Location."ADM Manage Location ID") then begin
                if not ManageQtyFetched then begin
                    ManageQty := GetManageQuantity(Item."ADM Manage Product ID");
                    ManageQtyFetched := true;
                end;

                if ManageQty = -1 then begin
                    Failed += 1;
                    exit;
                end;

                Clear(BCSerials);
                Clear(SerialNumbers);
                GetBCSerialNumbersInStock(Item."No.", Location.Code, BCSerials);
                Delta := BCSerials.Count - ManageQty;

                if Delta <= 0 then begin
                    Processed += 1;
                end else begin
                    for i := 1 to Delta do
                        SerialNumbers.Add(BCSerials.Get(i));

                    if AdjustManageStockSerialized(
                        Location."ADM Manage Location ID",
                        Item."ADM Manage Product ID",
                        SerialNumbers)
                    then
                        Processed += 1
                    else
                        Failed += 1;
                end;
            end;
        until Location.Next() = 0;
    end;

    // ── Helpers ────────────────────────────────────────────────────────────────

    /// <summary>
    /// Calls GET /api/v2/inventory/products/{id} and returns the 'quantity' field.
    /// Returns -1 on failure.
    /// </summary>
    local procedure GetManageQuantity(ManageProductID: Guid): Integer
    var
        ResponseText: Text;
        ErrorText: Text;
        ResponseObj: JsonObject;
        ProductIDStr: Text;
    begin
        ProductIDStr := LowerCase(Format(ManageProductID, 0, 4));
        if not ADMAPIClient.TryGet(StrSubstNo(ProductUrlLbl, ProductIDStr), ResponseText, ErrorText) then
            exit(-1);
        if not ResponseObj.ReadFrom(ResponseText) then
            exit(-1);
        exit(ADMAPIClient.GetJsonInteger(ResponseObj, 'quantity'));
    end;

    /// <summary>
    /// Returns the net inventory quantity for the given item at a BC location.
    /// Pass LocationCode = '' to sum across all locations.
    /// </summary>
    local procedure GetBCInventoryForLocation(ItemNo: Code[20]; LocationCode: Code[10]): Integer
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        if LocationCode <> '' then
            ItemLedgerEntry.SetRange("Location Code", LocationCode);
        ItemLedgerEntry.CalcSums(Quantity);
        exit(Round(ItemLedgerEntry.Quantity, 1));
    end;

    /// <summary>
    /// Collects serial numbers currently in stock (Remaining Quantity > 0) for the
    /// given item, sorted newest first (Posting Date DESC, Entry No. DESC).
    /// Pass LocationCode = '' to include all BC locations.
    /// </summary>
    local procedure GetBCSerialNumbersInStock(ItemNo: Code[20]; LocationCode: Code[10]; var SerialNumbers: List of [Text])
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        Clear(SerialNumbers);
        ItemLedgerEntry.SetCurrentKey("Item No.", "Posting Date", "Entry No.");
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        if LocationCode <> '' then
            ItemLedgerEntry.SetRange("Location Code", LocationCode);
        ItemLedgerEntry.SetFilter("Remaining Quantity", '>0');
        ItemLedgerEntry.SetFilter("Serial No.", '<>%1', '');
        ItemLedgerEntry.Ascending(false); // newest first
        if not ItemLedgerEntry.FindSet() then
            exit;
        repeat
            if not SerialNumbers.Contains(ItemLedgerEntry."Serial No.") then
                SerialNumbers.Add(ItemLedgerEntry."Serial No.");
        until ItemLedgerEntry.Next() = 0;
    end;

    /// <summary>
    /// Posts a non-serialized stock adjustment to Manage.
    /// A positive Delta adds stock; a negative Delta removes it.
    /// </summary>
    local procedure AdjustManageStock(ManageLocationID: Guid; ManageProductID: Guid; Delta: Integer): Boolean
    var
        LocationIDStr: Text;
        ProductIDStr: Text;
        RequestBody: Text;
        ResponseText: Text;
        ErrorText: Text;
        Payload: JsonObject;
    begin
        LocationIDStr := LowerCase(Format(ManageLocationID, 0, 4));
        ProductIDStr := LowerCase(Format(ManageProductID, 0, 4));
        Payload.Add('quantity', Delta);
        Payload.WriteTo(RequestBody);
        exit(ADMAPIClient.TryPost(
            StrSubstNo(AdjustNotSerializedUrlLbl, LocationIDStr, ProductIDStr),
            RequestBody, ResponseText, ErrorText));
    end;

    /// <summary>
    /// Posts a serialized stock adjustment to Manage, adding the given serial numbers.
    /// Calls POST /api/v2/inventory/stock/locations/{loc}/products/{prod}/serialized/adjust
    /// with payload: { "serialNumbers": [...], "batteryTypeId": null, "colorId": null, "attributes": [] }
    /// </summary>
    local procedure AdjustManageStockSerialized(ManageLocationID: Guid; ManageProductID: Guid; SerialNumbers: List of [Text]): Boolean
    var
        LocationIDStr: Text;
        ProductIDStr: Text;
        RequestBody: Text;
        ResponseText: Text;
        ErrorText: Text;
        SerialsArr: JsonArray;
        NullToken: JsonToken;
        SerialNo: Text;
    begin
        LocationIDStr := LowerCase(Format(ManageLocationID, 0, 4));
        ProductIDStr := LowerCase(Format(ManageProductID, 0, 4));

        foreach SerialNo in SerialNumbers do
            SerialsArr.Add(SerialNo);

        // Build JSON manually to emit null for optional guid fields
        NullToken.ReadFrom('null');
        RequestBody := '{"serialNumbers":';
        SerialsArr.WriteTo(ErrorText); // reuse ErrorText as temp
        RequestBody := RequestBody + ErrorText;
        RequestBody := RequestBody + ',"batteryTypeId":null,"colorId":null,"attributes":[]}';

        exit(ADMAPIClient.TryPost(
            StrSubstNo(AdjustSerializedUrlLbl, LocationIDStr, ProductIDStr),
            RequestBody, ResponseText, ErrorText));
    end;
}
