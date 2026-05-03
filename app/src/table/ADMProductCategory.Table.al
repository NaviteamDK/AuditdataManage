table 80319 "ADM Product Category"
{
    Caption = 'AuditData Manage Product Category';
    DataClassification = CustomerContent;
    LookupPageId = "ADM Product Category List";
    DrillDownPageId = "ADM Product Category List";

    fields
    {
        field(1; "Manage Category ID"; Guid)
        {
            Caption = 'Manage Category ID';
            DataClassification = CustomerContent;
        }
        field(10; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(11; Code; Text[50])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Manage Category ID")
        {
            Clustered = true;
        }
        key(Name; Name) { }
        key(Code; Code) { }
    }
}
