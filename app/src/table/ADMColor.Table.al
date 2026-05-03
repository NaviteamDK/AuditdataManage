table 80315 "ADM Color"
{
    Caption = 'AuditData Manage Color';
    DataClassification = CustomerContent;
    LookupPageId = "ADM Color List";
    DrillDownPageId = "ADM Color List";

    fields
    {
        field(1; "Manage Color ID"; Guid)
        {
            Caption = 'Manage Color ID';
            DataClassification = CustomerContent;
        }
        field(10; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Manage Color ID")
        {
            Clustered = true;
        }
        key(Name; Name) { }
    }
}
