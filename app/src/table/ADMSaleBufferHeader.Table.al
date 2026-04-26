table 80307 "ADM Sale Buffer Header"
{
    Caption = 'AuditData Manage Sale Buffer Header';
    DataClassification = CustomerContent;
    LookupPageId = "ADM Sale Buffer List";
    DrillDownPageId = "ADM Sale Buffer List";

    fields
    {
        field(1; "Manage Sale ID"; Guid)
        {
            Caption = 'Manage Sale ID';
            DataClassification = CustomerContent;
        }
        field(10; "Sale No."; Text[50])
        {
            Caption = 'Sale No.';
            DataClassification = CustomerContent;
        }
        field(11; "Manage Client ID"; Guid)
        {
            Caption = 'Manage Client ID';
            DataClassification = CustomerContent;
        }
        field(12; "Client Name"; Text[200])
        {
            Caption = 'Client Name';
            DataClassification = CustomerContent;
        }
        field(13; "BC Client Customer No."; Code[20])
        {
            Caption = 'BC Client Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(20; "Sale Date"; Date)
        {
            Caption = 'Sale Date';
            DataClassification = CustomerContent;
        }
        field(21; "Sale Status"; Text[50])
        {
            Caption = 'Sale Status';
            DataClassification = CustomerContent;
        }
        field(22; "Location ID"; Guid)
        {
            Caption = 'Location ID';
            DataClassification = CustomerContent;
        }
        field(23; "Location Name"; Text[100])
        {
            Caption = 'Location Name';
            DataClassification = CustomerContent;
        }
        field(30; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
        }
        field(31; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
        }
        field(32; "VAT Amount"; Decimal)
        {
            Caption = 'VAT Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
        }
        field(33; "Amount Excluding VAT"; Decimal)
        {
            Caption = 'Amount Excluding VAT';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
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
        field(42; "Master Order No."; Code[20])
        {
            Caption = 'Master Order No.';
            DataClassification = CustomerContent;
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
        field(60; "External Doc. No."; Text[50])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }
        field(61; Notes; Text[2048])
        {
            Caption = 'Notes';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Manage Sale ID")
        {
            Clustered = true;
        }
        key(Status; Status) { }
        key(SaleDate; "Sale Date") { }
        key(BCClientCustomerNo; "BC Client Customer No.") { }
        key(MasterOrderNo; "Master Order No.") { }
    }

    procedure MarkProcessed(MasterOrderNo: Code[20])
    begin
        Rec."Master Order No." := MasterOrderNo;
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
