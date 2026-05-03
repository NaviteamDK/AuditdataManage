table 80321 "ADM Supplier"
{
    Caption = 'AuditData Manage Supplier';
    DataClassification = CustomerContent;
    LookupPageId = "ADM Supplier List";
    DrillDownPageId = "ADM Supplier List";

    fields
    {
        field(1; "Manage Supplier ID"; Guid)
        {
            Caption = 'Manage Supplier ID';
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
        key(PK; "Manage Supplier ID")
        {
            Clustered = true;
        }
        key(Name; Name) { }
    }
}
