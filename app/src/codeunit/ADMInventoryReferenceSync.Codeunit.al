codeunit 80311 "ADM Inventory Reference Sync"
{
    var
        ADMAPIClient: Codeunit "ADM API Client";
        SyncColorsLbl: Label 'Colors Sync';
        SyncBatteryTypesLbl: Label 'Battery Types Sync';
        SyncAttributesLbl: Label 'Attributes Sync';
        SyncProductCategoriesLbl: Label 'Product Categories Sync';
        SyncManufacturersLbl: Label 'Manufacturers Sync';
        SyncSuppliersLbl: Label 'Suppliers Sync';

    /// <summary>
    /// Syncs colors, battery types and attributes from AuditData Manage.
    /// </summary>
    procedure SyncAll()
    var
        ErrorText: Text;
    begin
        if not SyncProductCategories(ErrorText) then
            Error(ErrorText);
        if not SyncManufacturers(ErrorText) then
            Error(ErrorText);
        if not SyncSuppliers(ErrorText) then
            Error(ErrorText);
        if not SyncColors(ErrorText) then
            Error(ErrorText);
        if not SyncBatteryTypes(ErrorText) then
            Error(ErrorText);
        if not SyncAttributes(ErrorText) then
            Error(ErrorText);
    end;

    /// <summary>
    /// Retrieves all colors from GET /api/v2/inventory/colors and upserts ADM Color records.
    /// Returns the number of records upserted.
    /// </summary>
    procedure SyncColors(var ErrorText: Text): Boolean
    var
        ADMColor: Record "ADM Color";
        AllItems: JsonArray;
        ItemToken: JsonToken;
        ItemObj: JsonObject;
        ManageID: Guid;
        ItemName: Text;
        Upserted: Integer;
        SyncLogManager: Codeunit "ADM Sync Log Manager";
        LogEntryNo: Integer;
        SyncCompleteMsg: Label 'Colors sync complete. %1 record(s) upserted.', Comment = '%1 = count';
    begin
        LogEntryNo := SyncLogManager.StartLog("ADM Sync Direction"::Inbound, SyncColorsLbl);

        ADMAPIClient.GetPaged('api/v2/inventory/colors', AllItems);

        foreach ItemToken in AllItems do begin
            if not ItemToken.IsObject() then
                continue;
            ItemObj := ItemToken.AsObject();
            ManageID := ADMAPIClient.GetJsonGuid(ItemObj, 'id');
            ItemName := ADMAPIClient.GetJsonText(ItemObj, 'name');

            if IsNullGuid(ManageID) then
                continue;

            if not ADMColor.Get(ManageID) then begin
                ADMColor.Init();
                ADMColor."Manage Color ID" := ManageID;
                ADMColor.Name := CopyStr(ItemName, 1, 100);
                ADMColor.Insert();
            end else begin
                ADMColor.Name := CopyStr(ItemName, 1, 100);
                ADMColor.Modify();
            end;
            Upserted += 1;
        end;

        SyncLogManager.FinishLog(LogEntryNo, Upserted, 0);
        Message(SyncCompleteMsg, Upserted);
        exit(true);
    end;

    /// <summary>
    /// Retrieves all battery types from GET /api/v2/inventory/battery-types and upserts ADM Battery Type records.
    /// </summary>
    procedure SyncBatteryTypes(var ErrorText: Text): Boolean
    var
        ADMBatteryType: Record "ADM Battery Type";
        AllItems: JsonArray;
        ItemToken: JsonToken;
        ItemObj: JsonObject;
        ManageID: Guid;
        ItemName: Text;
        IsActive: Boolean;
        Upserted: Integer;
        SyncLogManager: Codeunit "ADM Sync Log Manager";
        LogEntryNo: Integer;
        SyncCompleteMsg: Label 'Battery types sync complete. %1 record(s) upserted.', Comment = '%1 = count';
    begin
        LogEntryNo := SyncLogManager.StartLog("ADM Sync Direction"::Inbound, SyncBatteryTypesLbl);

        ADMAPIClient.GetPaged('api/v2/inventory/battery-types', AllItems);

        foreach ItemToken in AllItems do begin
            if not ItemToken.IsObject() then
                continue;
            ItemObj := ItemToken.AsObject();
            ManageID := ADMAPIClient.GetJsonGuid(ItemObj, 'id');
            ItemName := ADMAPIClient.GetJsonText(ItemObj, 'name');
            IsActive := ADMAPIClient.GetJsonBoolean(ItemObj, 'isActive');

            if IsNullGuid(ManageID) then
                continue;

            if not ADMBatteryType.Get(ManageID) then begin
                ADMBatteryType.Init();
                ADMBatteryType."Manage Battery Type ID" := ManageID;
                ADMBatteryType.Name := CopyStr(ItemName, 1, 100);
                ADMBatteryType."Is Active" := IsActive;
                ADMBatteryType.Insert();
            end else begin
                ADMBatteryType.Name := CopyStr(ItemName, 1, 100);
                ADMBatteryType."Is Active" := IsActive;
                ADMBatteryType.Modify();
            end;
            Upserted += 1;
        end;

        SyncLogManager.FinishLog(LogEntryNo, Upserted, 0);
        Message(SyncCompleteMsg, Upserted);
        exit(true);
    end;

    /// <summary>
    /// Retrieves all attributes from GET /api/v2/inventory/attributes and upserts ADM Attribute + ADM Attribute Value records.
    /// </summary>
    procedure SyncAttributes(var ErrorText: Text): Boolean
    var
        ADMAttribute: Record "ADM Attribute";
        ADMAttrValue: Record "ADM Attribute Value";
        AllItems: JsonArray;
        ItemToken: JsonToken;
        ItemObj: JsonObject;
        ValuesToken: JsonToken;
        ValuesArray: JsonArray;
        ValueToken: JsonToken;
        ValueObj: JsonObject;
        ManageID: Guid;
        ItemName: Text;
        IsActive: Boolean;
        ValueName: Text;
        ValueIsActive: Boolean;
        EntryNo: Integer;
        Upserted: Integer;
        SyncLogManager: Codeunit "ADM Sync Log Manager";
        LogEntryNo: Integer;
        SyncCompleteMsg: Label 'Attributes sync complete. %1 attribute(s) upserted.', Comment = '%1 = count';
    begin
        LogEntryNo := SyncLogManager.StartLog("ADM Sync Direction"::Inbound, SyncAttributesLbl);

        ADMAPIClient.GetPaged('api/v2/inventory/attributes', AllItems);

        foreach ItemToken in AllItems do begin
            if not ItemToken.IsObject() then
                continue;
            ItemObj := ItemToken.AsObject();
            ManageID := ADMAPIClient.GetJsonGuid(ItemObj, 'id');
            ItemName := ADMAPIClient.GetJsonText(ItemObj, 'name');
            IsActive := ADMAPIClient.GetJsonBoolean(ItemObj, 'isActive');

            if IsNullGuid(ManageID) then
                continue;

            if not ADMAttribute.Get(ManageID) then begin
                ADMAttribute.Init();
                ADMAttribute."Manage Attribute ID" := ManageID;
                ADMAttribute.Name := CopyStr(ItemName, 1, 100);
                ADMAttribute."Is Active" := IsActive;
                ADMAttribute.Insert();
            end else begin
                ADMAttribute.Name := CopyStr(ItemName, 1, 100);
                ADMAttribute."Is Active" := IsActive;
                ADMAttribute.Modify();
            end;

            // Rebuild attribute values — delete old and re-insert
            ADMAttrValue.SetRange("Manage Attribute ID", ManageID);
            ADMAttrValue.DeleteAll();

            EntryNo := 1;
            if ItemObj.Get('values', ValuesToken) and ValuesToken.IsArray() then begin
                ValuesArray := ValuesToken.AsArray();
                foreach ValueToken in ValuesArray do begin
                    if ValueToken.IsObject() then begin
                        ValueObj := ValueToken.AsObject();
                        ValueName := ADMAPIClient.GetJsonText(ValueObj, 'name');
                        ValueIsActive := ADMAPIClient.GetJsonBoolean(ValueObj, 'isActive');

                        if ValueName <> '' then begin
                            ADMAttrValue.Init();
                            ADMAttrValue."Manage Attribute ID" := ManageID;
                            ADMAttrValue."Entry No." := EntryNo;
                            ADMAttrValue.Name := CopyStr(ValueName, 1, 100);
                            ADMAttrValue."Is Active" := ValueIsActive;
                            ADMAttrValue.Insert();
                            EntryNo += 1;
                        end;
                    end;
                end;
            end;

            Upserted += 1;
        end;

        SyncLogManager.FinishLog(LogEntryNo, Upserted, 0);
        Message(SyncCompleteMsg, Upserted);
        exit(true);
    end;

    /// <summary>
    /// Fetches per-item color, battery type and attribute assignments from Manage
    /// for a given item (identified via ADM Item Mapping) and updates the BC item tables.
    /// </summary>
    procedure FetchItemAssignments(ItemNo: Code[20]): Boolean
    var
        ItemMapping: Record "ADM Item Mapping";
        ItemColor: Record "ADM Item Color";
        ItemBatteryType: Record "ADM Item Battery Type";
        ItemAttribute: Record "ADM Item Attribute";
        ResponseText: Text;
        ErrorText: Text;
        ResponseToken: JsonToken;
        ResponseObj: JsonObject;
        DataToken: JsonToken;
        DataObj: JsonObject;
        ColorsToken: JsonToken;
        BatteryTypesToken: JsonToken;
        AttributesToken: JsonToken;
        ColorToken: JsonToken;
        BatteryToken: JsonToken;
        AttrToken: JsonToken;
        ColorObj: JsonObject;
        BatteryObj: JsonObject;
        AttrObj: JsonObject;
        AttrDictObj: JsonObject;
        AttrValuesToken: JsonToken;
        AttrValueToken: JsonToken;
        AttrValueObj: JsonObject;
        ManageColorID: Guid;
        ManageBatteryID: Guid;
        ManageAttrID: Guid;
        ValueName: Text[100];
        ManageIDText: Text;
        ProductUrlLbl: Label 'api/v2/inventory/products/%1', Comment = '%1 = product GUID';
        ItemNotMappedErr: Label 'Item %1 has no AuditData Manage product mapping. Use ''Fetch Products from Manage'' first.', Comment = '%1 = item no.';
    begin
        if not ItemMapping.Get(ItemNo) then
            Error(ItemNotMappedErr, ItemNo);
        if IsNullGuid(ItemMapping."Manage Product ID") then
            Error(ItemNotMappedErr, ItemNo);

        ManageIDText := LowerCase(Format(ItemMapping."Manage Product ID", 0, 4));

        if not ADMAPIClient.TryGet(StrSubstNo(ProductUrlLbl, ManageIDText), ResponseText, ErrorText) then
            Error(ErrorText);

        ResponseToken.ReadFrom(ResponseText);
        if not ResponseToken.IsObject() then
            exit(false);
        ResponseObj := ResponseToken.AsObject();

        // Handle optional {data: {...}} wrapper
        if ResponseObj.Get('data', DataToken) and DataToken.IsObject() then
            DataObj := DataToken.AsObject()
        else
            DataObj := ResponseObj;

        // Ensure all catalog rows exist for this item, then reset Linked = false
        PopulateItemColorLinks(ItemNo);
        ItemColor.SetRange("Item No.", ItemNo);
        if ItemColor.FindSet() then
            repeat
                ItemColor."Linked" := false;
                ItemColor.Modify();
            until ItemColor.Next() = 0;

        // Mark colors returned by the API as Linked = true
        if DataObj.Get('colors', ColorsToken) and ColorsToken.IsArray() then
            foreach ColorToken in ColorsToken.AsArray() do begin
                if ColorToken.IsObject() then begin
                    ColorObj := ColorToken.AsObject();
                    ManageColorID := ADMAPIClient.GetJsonGuid(ColorObj, 'id');
                    if not IsNullGuid(ManageColorID) and ItemColor.Get(ItemNo, ManageColorID) then begin
                        ItemColor."Linked" := true;
                        ItemColor.Modify();
                    end;
                end;
            end;

        // Ensure all catalog rows exist for battery types, then reset
        PopulateItemBatteryTypeLinks(ItemNo);
        ItemBatteryType.SetRange("Item No.", ItemNo);
        if ItemBatteryType.FindSet() then
            repeat
                ItemBatteryType."Linked" := false;
                ItemBatteryType.Modify();
            until ItemBatteryType.Next() = 0;

        // Mark battery types returned by the API as Linked = true
        if DataObj.Get('batteryTypes', BatteryTypesToken) and BatteryTypesToken.IsArray() then
            foreach BatteryToken in BatteryTypesToken.AsArray() do begin
                if BatteryToken.IsObject() then begin
                    BatteryObj := BatteryToken.AsObject();
                    ManageBatteryID := ADMAPIClient.GetJsonGuid(BatteryObj, 'id');
                    if not IsNullGuid(ManageBatteryID) and ItemBatteryType.Get(ItemNo, ManageBatteryID) then begin
                        ItemBatteryType."Linked" := true;
                        ItemBatteryType.Modify();
                    end;
                end;
            end;

        // Ensure all catalog rows exist for attributes, then reset
        PopulateItemAttributeLinks(ItemNo);
        ItemAttribute.SetRange("Item No.", ItemNo);
        if ItemAttribute.FindSet() then
            repeat
                ItemAttribute."Linked" := false;
                ItemAttribute.Modify();
            until ItemAttribute.Next() = 0;

        // Mark attribute values returned by the API as Linked = true
        if DataObj.Get('attributes', AttributesToken) and AttributesToken.IsArray() then
            foreach AttrToken in AttributesToken.AsArray() do begin
                if AttrToken.IsObject() then begin
                    AttrObj := AttrToken.AsObject();
                    if ADMAPIClient.GetJsonObject(AttrObj, 'attribute', AttrDictObj) then begin
                        ManageAttrID := ADMAPIClient.GetJsonGuid(AttrDictObj, 'id');
                        if not IsNullGuid(ManageAttrID) then
                            if AttrObj.Get('values', AttrValuesToken) and AttrValuesToken.IsArray() then
                                foreach AttrValueToken in AttrValuesToken.AsArray() do begin
                                    if AttrValueToken.IsObject() then begin
                                        AttrValueObj := AttrValueToken.AsObject();
                                        ValueName := CopyStr(ADMAPIClient.GetJsonText(AttrValueObj, 'name'), 1, 100);
                                        if (ValueName <> '') and ItemAttribute.Get(ItemNo, ManageAttrID, ValueName) then begin
                                            ItemAttribute."Linked" := true;
                                            ItemAttribute.Modify();
                                        end;
                                    end;
                                end;
                    end;
                end;
            end;

        exit(true);
    end;

    /// <summary>
    /// Ensures a row exists in ADM Item Color for every color in the catalog for the given item.
    /// New rows are inserted with Linked = false. Existing rows are left unchanged.
    /// </summary>
    procedure PopulateItemColorLinks(ItemNo: Code[20])
    var
        ADMColor: Record "ADM Color";
        ItemColor: Record "ADM Item Color";
    begin
        if ADMColor.FindSet() then
            repeat
                if not ItemColor.Get(ItemNo, ADMColor."Manage Color ID") then begin
                    ItemColor.Init();
                    ItemColor."Item No." := ItemNo;
                    ItemColor."Manage Color ID" := ADMColor."Manage Color ID";
                    ItemColor."Color Name" := ADMColor.Name;
                    ItemColor."Linked" := false;
                    ItemColor.Insert();
                end;
            until ADMColor.Next() = 0;
    end;

    /// <summary>
    /// Ensures a row exists in ADM Item Battery Type for every battery type in the catalog for the given item.
    /// New rows are inserted with Linked = false. Existing rows are left unchanged.
    /// </summary>
    procedure PopulateItemBatteryTypeLinks(ItemNo: Code[20])
    var
        ADMBatteryType: Record "ADM Battery Type";
        ItemBatteryType: Record "ADM Item Battery Type";
    begin
        if ADMBatteryType.FindSet() then
            repeat
                if not ItemBatteryType.Get(ItemNo, ADMBatteryType."Manage Battery Type ID") then begin
                    ItemBatteryType.Init();
                    ItemBatteryType."Item No." := ItemNo;
                    ItemBatteryType."Manage Battery Type ID" := ADMBatteryType."Manage Battery Type ID";
                    ItemBatteryType."Battery Type Name" := ADMBatteryType.Name;
                    ItemBatteryType."Is Active" := ADMBatteryType."Is Active";
                    ItemBatteryType."Linked" := false;
                    ItemBatteryType.Insert();
                end;
            until ADMBatteryType.Next() = 0;
    end;

    /// <summary>
    /// Ensures a row exists in ADM Item Attribute for every attribute value in the catalog for the given item.
    /// New rows are inserted with Linked = false. Existing rows are left unchanged.
    /// </summary>
    procedure PopulateItemAttributeLinks(ItemNo: Code[20])
    var
        ADMAttrValue: Record "ADM Attribute Value";
        ADMAttr: Record "ADM Attribute";
        ItemAttribute: Record "ADM Item Attribute";
    begin
        if ADMAttrValue.FindSet() then
            repeat
                if not ItemAttribute.Get(ItemNo, ADMAttrValue."Manage Attribute ID", ADMAttrValue.Name) then begin
                    ItemAttribute.Init();
                    ItemAttribute."Item No." := ItemNo;
                    ItemAttribute."Manage Attribute ID" := ADMAttrValue."Manage Attribute ID";
                    ItemAttribute."Value Name" := ADMAttrValue.Name;
                    if ADMAttr.Get(ADMAttrValue."Manage Attribute ID") then
                        ItemAttribute."Attribute Name" := ADMAttr.Name;
                    ItemAttribute."Linked" := false;
                    ItemAttribute.Insert();
                end;
            until ADMAttrValue.Next() = 0;
    end;

    /// <summary>
    /// Retrieves all product categories from GET /api/v2/inventory/product-categories and upserts ADM Product Category records.
    /// </summary>
    procedure SyncProductCategories(var ErrorText: Text): Boolean
    var
        ADMProductCategory: Record "ADM Product Category";
        AllItems: JsonArray;
        ItemToken: JsonToken;
        ItemObj: JsonObject;
        ManageID: Guid;
        ItemName: Text;
        ItemCode: Text;
        Upserted: Integer;
        SyncLogManager: Codeunit "ADM Sync Log Manager";
        LogEntryNo: Integer;
        SyncCompleteMsg: Label 'Product categories sync complete. %1 record(s) upserted.', Comment = '%1 = count';
    begin
        LogEntryNo := SyncLogManager.StartLog("ADM Sync Direction"::Inbound, SyncProductCategoriesLbl);

        ADMAPIClient.GetPaged('api/v2/inventory/product-categories', AllItems);

        foreach ItemToken in AllItems do begin
            if not ItemToken.IsObject() then
                continue;
            ItemObj := ItemToken.AsObject();
            ManageID := ADMAPIClient.GetJsonGuid(ItemObj, 'id');
            ItemName := ADMAPIClient.GetJsonText(ItemObj, 'name');
            ItemCode := ADMAPIClient.GetJsonText(ItemObj, 'code');

            if IsNullGuid(ManageID) then
                continue;

            if not ADMProductCategory.Get(ManageID) then begin
                ADMProductCategory.Init();
                ADMProductCategory."Manage Category ID" := ManageID;
                ADMProductCategory.Name := CopyStr(ItemName, 1, 100);
                ADMProductCategory.Code := CopyStr(ItemCode, 1, 50);
                ADMProductCategory.Insert();
            end else begin
                ADMProductCategory.Name := CopyStr(ItemName, 1, 100);
                ADMProductCategory.Code := CopyStr(ItemCode, 1, 50);
                ADMProductCategory.Modify();
            end;
            Upserted += 1;
        end;

        SyncLogManager.FinishLog(LogEntryNo, Upserted, 0);
        Message(SyncCompleteMsg, Upserted);
        exit(true);
    end;

    /// <summary>
    /// Retrieves all manufacturers from GET /api/v2/inventory/manufacturers and upserts ADM Manufacturer records.
    /// </summary>
    procedure SyncManufacturers(var ErrorText: Text): Boolean
    var
        ADMManufacturer: Record "ADM Manufacturer";
        AllItems: JsonArray;
        ItemToken: JsonToken;
        ItemObj: JsonObject;
        ManageID: Guid;
        ItemName: Text;
        IsActive: Boolean;
        Upserted: Integer;
        SyncLogManager: Codeunit "ADM Sync Log Manager";
        LogEntryNo: Integer;
        SyncCompleteMsg: Label 'Manufacturers sync complete. %1 record(s) upserted.', Comment = '%1 = count';
    begin
        LogEntryNo := SyncLogManager.StartLog("ADM Sync Direction"::Inbound, SyncManufacturersLbl);

        ADMAPIClient.GetPaged('api/v2/inventory/manufacturers', AllItems);

        foreach ItemToken in AllItems do begin
            if not ItemToken.IsObject() then
                continue;
            ItemObj := ItemToken.AsObject();
            ManageID := ADMAPIClient.GetJsonGuid(ItemObj, 'id');
            ItemName := ADMAPIClient.GetJsonText(ItemObj, 'name');
            IsActive := ADMAPIClient.GetJsonBoolean(ItemObj, 'isActive');

            if IsNullGuid(ManageID) then
                continue;

            if not ADMManufacturer.Get(ManageID) then begin
                ADMManufacturer.Init();
                ADMManufacturer."Manage Manufacturer ID" := ManageID;
                ADMManufacturer.Name := CopyStr(ItemName, 1, 200);
                ADMManufacturer."Is Active" := IsActive;
                ADMManufacturer.Insert();
            end else begin
                ADMManufacturer.Name := CopyStr(ItemName, 1, 200);
                ADMManufacturer."Is Active" := IsActive;
                ADMManufacturer.Modify();
            end;
            Upserted += 1;
        end;

        SyncLogManager.FinishLog(LogEntryNo, Upserted, 0);
        Message(SyncCompleteMsg, Upserted);
        exit(true);
    end;

    /// <summary>
    /// Retrieves all suppliers from GET /api/v2/inventory/suppliers and upserts ADM Supplier records.
    /// </summary>
    procedure SyncSuppliers(var ErrorText: Text): Boolean
    var
        ADMSupplier: Record "ADM Supplier";
        AllItems: JsonArray;
        ItemToken: JsonToken;
        ItemObj: JsonObject;
        ManageID: Guid;
        ItemName: Text;
        IsActive: Boolean;
        Upserted: Integer;
        SyncLogManager: Codeunit "ADM Sync Log Manager";
        LogEntryNo: Integer;
        SyncCompleteMsg: Label 'Suppliers sync complete. %1 record(s) upserted.', Comment = '%1 = count';
    begin
        LogEntryNo := SyncLogManager.StartLog("ADM Sync Direction"::Inbound, SyncSuppliersLbl);

        ADMAPIClient.GetPaged('api/v2/inventory/suppliers', AllItems);

        foreach ItemToken in AllItems do begin
            if not ItemToken.IsObject() then
                continue;
            ItemObj := ItemToken.AsObject();
            ManageID := ADMAPIClient.GetJsonGuid(ItemObj, 'id');
            ItemName := ADMAPIClient.GetJsonText(ItemObj, 'name');
            IsActive := ADMAPIClient.GetJsonBoolean(ItemObj, 'isActive');

            if IsNullGuid(ManageID) then
                continue;

            if not ADMSupplier.Get(ManageID) then begin
                ADMSupplier.Init();
                ADMSupplier."Manage Supplier ID" := ManageID;
                ADMSupplier.Name := CopyStr(ItemName, 1, 200);
                ADMSupplier."Is Active" := IsActive;
                ADMSupplier.Insert();
            end else begin
                ADMSupplier.Name := CopyStr(ItemName, 1, 200);
                ADMSupplier."Is Active" := IsActive;
                ADMSupplier.Modify();
            end;
            Upserted += 1;
        end;

        SyncLogManager.FinishLog(LogEntryNo, Upserted, 0);
        Message(SyncCompleteMsg, Upserted);
        exit(true);
    end;
}
