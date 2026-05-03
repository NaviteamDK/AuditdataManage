table 80320 "ADM Manufacturer"
{
    Caption = 'AuditData Manage Manufacturer';
    DataClassification = CustomerContent;
    LookupPageId = "ADM Manufacturer List";
    DrillDownPageId = "ADM Manufacturer List";

    fields
    {
        field(1; "Manage Manufacturer ID"; Guid)
        {
            Caption = 'Manage Manufacturer ID';
            DataClassification = CustomerContent;
        }
        field(10; Name; Text[200])
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
        key(PK; "Manage Manufacturer ID")
        {
            Clustered = true;
        }
        key(Name; Name) { }
    }
}
