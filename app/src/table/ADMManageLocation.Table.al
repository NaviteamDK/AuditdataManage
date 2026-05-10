table 80324 "ADM Manage Location"
{
    Caption = 'AuditData Manage Location';
    DataClassification = CustomerContent;
    LookupPageId = "ADM Manage Location List";
    DrillDownPageId = "ADM Manage Location List";

    fields
    {
        field(1; "Manage Location ID"; Guid)
        {
            Caption = 'Manage Location ID';
            DataClassification = CustomerContent;
        }
        field(10; Name; Text[250])
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
        key(PK; "Manage Location ID")
        {
            Clustered = true;
        }
    }
}
