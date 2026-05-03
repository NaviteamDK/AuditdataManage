table 80313 "ADM Item Battery Type"
{
    Caption = 'AuditData Manage Item Battery Type';
    DataClassification = CustomerContent;
    LookupPageId = "ADM Item Battery Type Subpage";
    DrillDownPageId = "ADM Item Battery Type Subpage";

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(2; "Manage Battery Type ID"; Guid)
        {
            Caption = 'Manage Battery Type ID';
            DataClassification = CustomerContent;
            TableRelation = "ADM Battery Type"."Manage Battery Type ID";
        }
        field(10; "Battery Type Name"; Text[100])
        {
            Caption = 'Battery Type Name';
            DataClassification = CustomerContent;
        }
        field(11; "Is Active"; Boolean)
        {
            Caption = 'Is Active';
            DataClassification = CustomerContent;
        }
        field(12; "Linked"; Boolean)
        {
            Caption = 'Linked';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Item No.", "Manage Battery Type ID")
        {
            Clustered = true;
        }
    }

    procedure GetBatteryTypeIDsAsJsonArray(ItemNo: Code[20]): JsonArray
    var
        ItemBatteryType: Record "ADM Item Battery Type";
        JsonArr: JsonArray;
    begin
        ItemBatteryType.SetRange("Item No.", ItemNo);
        ItemBatteryType.SetRange("Linked", true);
        if ItemBatteryType.FindSet() then
            repeat
                if not IsNullGuid(ItemBatteryType."Manage Battery Type ID") then
                    JsonArr.Add(LowerCase(Format(ItemBatteryType."Manage Battery Type ID", 0, 4)));
            until ItemBatteryType.Next() = 0;
        exit(JsonArr);
    end;
}
