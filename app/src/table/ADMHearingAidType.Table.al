table 80323 "ADM Hearing Aid Type"
{
    Caption = 'AuditData Manage Hearing Aid Type';
    DataClassification = CustomerContent;
    LookupPageId = "ADM Hearing Aid Type List";
    DrillDownPageId = "ADM Hearing Aid Type List";

    fields
    {
        field(1; "Manage Hearing Aid Type ID"; Guid)
        {
            Caption = 'Manage Hearing Aid Type ID';
            DataClassification = CustomerContent;
        }
        field(2; Name; Text[200])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Manage Hearing Aid Type ID")
        {
            Clustered = true;
        }
    }
}
