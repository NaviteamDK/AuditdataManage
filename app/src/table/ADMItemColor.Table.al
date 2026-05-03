table 80312 "ADM Item Color"
{
    Caption = 'AuditData Manage Item Color';
    DataClassification = CustomerContent;
    LookupPageId = "ADM Item Color Subpage";
    DrillDownPageId = "ADM Item Color Subpage";

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(2; "Manage Color ID"; Guid)
        {
            Caption = 'Manage Color ID';
            DataClassification = CustomerContent;
            TableRelation = "ADM Color"."Manage Color ID";
        }
        field(10; "Color Name"; Text[100])
        {
            Caption = 'Color Name';
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
        key(PK; "Item No.", "Manage Color ID")
        {
            Clustered = true;
        }
    }

    procedure GetColorIDsAsJsonArray(ItemNo: Code[20]): JsonArray
    var
        ItemColor: Record "ADM Item Color";
        JsonArr: JsonArray;
    begin
        ItemColor.SetRange("Item No.", ItemNo);
        ItemColor.SetRange("Linked", true);
        if ItemColor.FindSet() then
            repeat
                if not IsNullGuid(ItemColor."Manage Color ID") then
                    JsonArr.Add(LowerCase(Format(ItemColor."Manage Color ID", 0, 4)));
            until ItemColor.Next() = 0;
        exit(JsonArr);
    end;
}
