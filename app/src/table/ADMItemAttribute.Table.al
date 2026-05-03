table 80314 "ADM Item Attribute"
{
    Caption = 'AuditData Manage Item Attribute';
    DataClassification = CustomerContent;
    LookupPageId = "ADM Item Attribute Subpage";
    DrillDownPageId = "ADM Item Attribute Subpage";

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(2; "Manage Attribute ID"; Guid)
        {
            Caption = 'Manage Attribute ID';
            DataClassification = CustomerContent;
            TableRelation = "ADM Attribute"."Manage Attribute ID";
        }
        field(3; "Value Name"; Text[100])
        {
            Caption = 'Value Name';
            DataClassification = CustomerContent;
        }
        field(10; "Attribute Name"; Text[100])
        {
            Caption = 'Attribute Name';
            DataClassification = CustomerContent;
        }
        field(11; "Linked"; Boolean)
        {
            Caption = 'Linked';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Item No.", "Manage Attribute ID", "Value Name")
        {
            Clustered = true;
        }
    }

    /// <summary>
    /// Builds the attributes JSON array required by the Manage ProductRequest.
    /// Groups linked values by Attribute ID, producing:
    ///   [ { "attributeId": "...", "values": [ { "name": "..." } ] } ]
    /// </summary>
    procedure GetAttributesAsJsonArray(ItemNo: Code[20]): JsonArray
    var
        ItemAttr: Record "ADM Item Attribute";
        OuterArr: JsonArray;
        AttrObj: JsonObject;
        ValuesArr: JsonArray;
        ValueObj: JsonObject;
        LastAttrID: Guid;
        IsFirst: Boolean;
    begin
        ItemAttr.SetRange("Item No.", ItemNo);
        ItemAttr.SetRange("Linked", true);
        ItemAttr.SetCurrentKey("Item No.", "Manage Attribute ID", "Value Name");
        if not ItemAttr.FindSet() then
            exit(OuterArr);

        IsFirst := true;
        Clear(LastAttrID);

        repeat
            if IsNullGuid(ItemAttr."Manage Attribute ID") then begin
                // skip rows with no attribute ID
            end else begin
                if ItemAttr."Manage Attribute ID" <> LastAttrID then begin
                    // Flush previous attribute object
                    if not IsFirst then begin
                        AttrObj.Add('values', ValuesArr);
                        OuterArr.Add(AttrObj);
                    end;
                    // Start new attribute
                    Clear(AttrObj);
                    Clear(ValuesArr);
                    AttrObj.Add('attributeId', LowerCase(Format(ItemAttr."Manage Attribute ID", 0, 4)));
                    LastAttrID := ItemAttr."Manage Attribute ID";
                    IsFirst := false;
                end;
                if ItemAttr."Value Name" <> '' then begin
                    Clear(ValueObj);
                    ValueObj.Add('name', ItemAttr."Value Name");
                    ValuesArr.Add(ValueObj);
                end;
            end;
        until ItemAttr.Next() = 0;

        // Flush last attribute object
        if not IsFirst then begin
            AttrObj.Add('values', ValuesArr);
            OuterArr.Add(AttrObj);
        end;

        exit(OuterArr);
    end;
}
