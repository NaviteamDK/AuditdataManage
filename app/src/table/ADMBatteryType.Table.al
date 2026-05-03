table 80316 "ADM Battery Type"
{
    Caption = 'AuditData Manage Battery Type';
    DataClassification = CustomerContent;
    LookupPageId = "ADM Battery Type List";
    DrillDownPageId = "ADM Battery Type List";

    fields
    {
        field(1; "Manage Battery Type ID"; Guid)
        {
            Caption = 'Manage Battery Type ID';
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
        key(PK; "Manage Battery Type ID")
        {
            Clustered = true;
        }
        key(Name; Name) { }
    }
}
