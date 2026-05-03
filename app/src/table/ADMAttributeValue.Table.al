table 80318 "ADM Attribute Value"
{
    Caption = 'AuditData Manage Attribute Value';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Manage Attribute ID"; Guid)
        {
            Caption = 'Manage Attribute ID';
            DataClassification = CustomerContent;
            TableRelation = "ADM Attribute"."Manage Attribute ID";
        }
        field(2; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(11; "Is Active"; Boolean)
        {
            Caption = 'Is Active';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Manage Attribute ID", "Entry No.")
        {
            Clustered = true;
        }
        key(AttributeName; "Manage Attribute ID", Name) { }
    }
}
