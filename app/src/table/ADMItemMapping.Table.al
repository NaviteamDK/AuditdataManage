table 80302 "ADM Item Mapping"
{
    Caption = 'AuditData Manage Product Catalog';
    DataClassification = CustomerContent;
    LookupPageId = "ADM Item Mapping List";
    DrillDownPageId = "ADM Item Mapping List";

    fields
    {
        field(1; "Manage Product ID"; Guid)
        {
            Caption = 'Manage Product ID';
            DataClassification = CustomerContent;
        }
        field(10; "Manage SKU"; Text[100])
        {
            Caption = 'Manage SKU';
            DataClassification = CustomerContent;
        }
        field(20; Name; Text[250])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(30; "Is Active"; Boolean)
        {
            Caption = 'Is Active';
            DataClassification = CustomerContent;
        }
        field(40; "Item No."; Code[20])
        {
            Caption = 'BC Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;

            trigger OnValidate()
            begin
                if "Item No." <> '' then
                    LinkToBCItem("Item No.");
            end;
        }
    }

    keys
    {
        key(PK; "Manage Product ID")
        {
            Clustered = true;
        }
        key(ItemNo; "Item No.") { }
        key(SKU; "Manage SKU") { }
    }

    /// <summary>
    /// Returns the BC Item No. linked to the given Manage Product ID, or '' if none.
    /// </summary>
    procedure FindByManageProductID(ManageProductID: Guid): Code[20]
    var
        ItemMapping: Record "ADM Item Mapping";
    begin
        if ItemMapping.Get(ManageProductID) then
            exit(ItemMapping."Item No.");
        exit('');
    end;

    /// <summary>
    /// Links this catalog record to a BC item and writes the Manage Product ID
    /// back onto the BC item record so stock sync can find it.
    /// </summary>
    procedure LinkToBCItem(ItemNo: Code[20])
    var
        Item: Record Item;
    begin
        Rec."Item No." := ItemNo;
        Rec.Modify();
        if Item.Get(ItemNo) then begin
            Item."ADM Manage Product ID" := Rec."Manage Product ID";
            Item.Modify();
        end;
    end;
}
