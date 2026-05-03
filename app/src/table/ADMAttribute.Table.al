table 80317 "ADM Attribute"
{
    Caption = 'AuditData Manage Attribute';
    DataClassification = CustomerContent;
    LookupPageId = "ADM Attribute List";
    DrillDownPageId = "ADM Attribute List";

    fields
    {
        field(1; "Manage Attribute ID"; Guid)
        {
            Caption = 'Manage Attribute ID';
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
        key(PK; "Manage Attribute ID")
        {
            Clustered = true;
        }
        key(Name; Name) { }
    }
}
