table 80306 "ADM Funder Buffer"
{
    Caption = 'AuditData Manage Funder Buffer';
    DataClassification = CustomerContent;
    LookupPageId = "ADM Funder Buffer List";
    DrillDownPageId = "ADM Funder Buffer List";

    fields
    {
        field(1; "Manage ID"; Guid)
        {
            Caption = 'Manage ID';
            DataClassification = CustomerContent;
        }
        field(10; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(11; "Short Name"; Text[50])
        {
            Caption = 'Short Name';
            DataClassification = CustomerContent;
        }
        field(20; Email; Text[250])
        {
            Caption = 'Email';
            DataClassification = CustomerContent;
        }
        field(21; Phone; Text[50])
        {
            Caption = 'Phone';
            DataClassification = CustomerContent;
        }
        field(30; "Address Line 1"; Text[100])
        {
            Caption = 'Address Line 1';
            DataClassification = CustomerContent;
        }
        field(31; "Address Line 2"; Text[100])
        {
            Caption = 'Address Line 2';
            DataClassification = CustomerContent;
        }
        field(32; City; Text[50])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }
        field(33; "Post Code"; Text[20])
        {
            Caption = 'Post Code';
            DataClassification = CustomerContent;
        }
        field(34; Country; Text[50])
        {
            Caption = 'Country';
            DataClassification = CustomerContent;
        }
        field(35; "VAT Registration No."; Text[30])
        {
            Caption = 'VAT Registration No.';
            DataClassification = CustomerContent;
        }
        field(40; Status; Enum "ADM Buffer Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            InitValue = New;
        }
        field(41; "Error Message"; Text[500])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
        }
        field(42; "BC Customer No."; Code[20])
        {
            Caption = 'BC Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(50; "Imported At"; DateTime)
        {
            Caption = 'Imported At';
            DataClassification = CustomerContent;
        }
        field(51; "Processed At"; DateTime)
        {
            Caption = 'Processed At';
            DataClassification = CustomerContent;
        }
        field(52; "Manage Created At"; DateTime)
        {
            Caption = 'Manage Created At';
            DataClassification = CustomerContent;
        }
        field(53; "Manage Updated At"; DateTime)
        {
            Caption = 'Manage Updated At';
            DataClassification = CustomerContent;
        }
        field(60; "Is Active"; Boolean)
        {
            Caption = 'Is Active';
            DataClassification = CustomerContent;
            InitValue = true;
        }
    }

    keys
    {
        key(PK; "Manage ID")
        {
            Clustered = true;
        }
        key(StatusImportedAt; Status, "Imported At") { }
        key(Status; Status) { }
        key(BCCustomerNo; "BC Customer No.") { }
    }

    procedure MarkProcessed(CustomerNo: Code[20])
    begin
        Rec."BC Customer No." := CustomerNo;
        Rec.Status := "ADM Buffer Status"::Processed;
        Rec."Processed At" := CurrentDateTime();
        Rec."Error Message" := '';
        Rec.Modify();
    end;

    procedure MarkError(ErrorText: Text)
    begin
        Rec.Status := "ADM Buffer Status"::Error;
        Rec."Error Message" := CopyStr(ErrorText, 1, 500);
        Rec.Modify();
    end;
}
