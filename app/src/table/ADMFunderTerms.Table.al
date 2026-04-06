table 50104 "ADM Funder Terms"
{
    Caption = 'AuditData Manage Funder Terms';
    DataClassification = CustomerContent;
    LookupPageId = "ADM Funder Terms List";
    DrillDownPageId = "ADM Funder Terms List";

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;

            trigger OnValidate()
            var
                Customer: Record Customer;
            begin
                if Customer.Get("Customer No.") then
                    "Funder Name" := Customer.Name;
            end;
        }
        field(10; "Funder Name"; Text[100])
        {
            Caption = 'Funder Name';
            DataClassification = CustomerContent;
        }
        field(20; Priority; Integer)
        {
            Caption = 'Priority';
            DataClassification = CustomerContent;
            MinValue = 1;
            MaxValue = 999;

            trigger OnValidate()
            begin
                CheckDuplicatePriority();
            end;
        }
        field(30; "Split Type"; Enum "ADM Split Type")
        {
            Caption = 'Split Type';
            DataClassification = CustomerContent;
        }
        field(31; "Default Amount"; Decimal)
        {
            Caption = 'Default Amount';
            DataClassification = CustomerContent;
            MinValue = 0;
            DecimalPlaces = 2 : 2;

            trigger OnValidate()
            begin
                if "Default Amount" <> 0 then
                    "Default Percentage" := 0;
            end;
        }
        field(32; "Default Percentage"; Decimal)
        {
            Caption = 'Default Percentage (%)';
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 100;
            DecimalPlaces = 2 : 2;

            trigger OnValidate()
            begin
                if "Default Percentage" <> 0 then
                    "Default Amount" := 0;
            end;
        }
        field(40; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(50; Notes; Text[500])
        {
            Caption = 'Notes';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Customer No.")
        {
            Clustered = true;
        }
        key(Priority; Priority) { }
        key(Active; Active) { }
    }

    trigger OnInsert()
    var
        Customer: Record Customer;
    begin
        if Priority = 0 then
            Priority := GetNextPriority();
        if "Customer No." <> '' then
            if Customer.Get("Customer No.") then
                "Funder Name" := Customer.Name;
    end;

    local procedure CheckDuplicatePriority()
    var
        FunderTerms: Record "ADM Funder Terms";
        DuplicatePriorityErr: Label 'Priority %1 is already used by funder %2. Please choose a different priority.', Comment = '%1 = Priority, %2 = Funder Name';
    begin
        FunderTerms.SetRange(Priority, Priority);
        FunderTerms.SetFilter("Customer No.", '<>%1', "Customer No.");
        if FunderTerms.FindFirst() then
            Error(DuplicatePriorityErr, Priority, FunderTerms."Funder Name");
    end;

    local procedure GetNextPriority(): Integer
    var
        FunderTerms: Record "ADM Funder Terms";
    begin
        if FunderTerms.FindLast() then
            exit(FunderTerms.Priority + 10);
        exit(10);
    end;

    procedure GetDefaultValue(): Decimal
    begin
        if "Split Type" = "ADM Split Type"::"Fixed Amount" then
            exit("Default Amount");
        exit("Default Percentage");
    end;
}
