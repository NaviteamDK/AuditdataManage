table 80305 "ADM Client Buffer"
{
    Caption = 'AuditData Manage Client Buffer';
    DataClassification = CustomerContent;
    LookupPageId = "ADM Client Buffer List";
    DrillDownPageId = "ADM Client Buffer List";

    fields
    {
        field(1; "Manage ID"; Guid)
        {
            Caption = 'Manage ID';
            DataClassification = CustomerContent;
        }
        field(10; "First Name"; Text[100])
        {
            Caption = 'First Name';
            DataClassification = CustomerContent;
        }
        field(11; "Last Name"; Text[100])
        {
            Caption = 'Last Name';
            DataClassification = CustomerContent;
        }
        field(12; "Full Name"; Text[200])
        {
            Caption = 'Full Name';
            DataClassification = CustomerContent;
        }
        field(13; "Date of Birth"; Date)
        {
            Caption = 'Date of Birth';
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
        field(22; Mobile; Text[50])
        {
            Caption = 'Mobile';
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

            trigger OnValidate()
            var
                CustomerMapping: Record "ADM Customer Mapping";
                ExistingMapping: Record "ADM Customer Mapping";
            begin
                // Remove any existing mapping for this Manage ID (handles customer change)
                if CustomerMapping.Get("Manage ID") then
                    CustomerMapping.Delete();

                if "BC Customer No." <> '' then begin
                    // Ensure no other Manage ID already maps to the target customer
                    ExistingMapping.SetRange("Customer No.", "BC Customer No.");
                    ExistingMapping.SetRange("Customer Type", "ADM Customer Type"::Client);
                    if not ExistingMapping.IsEmpty() then
                        ExistingMapping.DeleteAll();

                    CustomerMapping.CreateOrUpdate(
                        "Manage ID",
                        "BC Customer No.",
                        "ADM Customer Type"::Client,
                        CopyStr("Full Name", 1, 100));
                    Status := "ADM Buffer Status"::Processed;
                    "Processed At" := CurrentDateTime();
                end;
            end;
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

    procedure GetFullName(): Text[200]
    begin
        if "Full Name" <> '' then
            exit("Full Name");
        exit(CopyStr("First Name" + ' ' + "Last Name", 1, 200));
    end;
}
