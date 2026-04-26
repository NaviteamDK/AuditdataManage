table 80309 "ADM Master Order Header"
{
    Caption = 'AuditData Manage Master Order Header';
    DataClassification = CustomerContent;
    LookupPageId = "ADM Master Order List";
    DrillDownPageId = "ADM Master Order List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    NoSeriesMgt.TestManual(GetNoSeriesCode());
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "No. Series";
        }
        field(10; "Manage Sale ID"; Guid)
        {
            Caption = 'Manage Sale ID';
            DataClassification = CustomerContent;
        }
        field(11; "Manage Sale No."; Text[50])
        {
            Caption = 'Manage Sale No.';
            DataClassification = CustomerContent;
        }
        field(20; "Client Customer No."; Code[20])
        {
            Caption = 'Client Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;

            trigger OnValidate()
            var
                Customer: Record Customer;
            begin
                if Customer.Get("Client Customer No.") then
                    "Client Name" := Customer.Name;
            end;
        }
        field(21; "Client Name"; Text[100])
        {
            Caption = 'Client Name';
            DataClassification = CustomerContent;
        }
        field(30; "Order Date"; Date)
        {
            Caption = 'Order Date';
            DataClassification = CustomerContent;
        }
        field(31; "Location Name"; Text[100])
        {
            Caption = 'Location Name';
            DataClassification = CustomerContent;
        }
        field(32; "External Doc. No."; Text[50])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }
        field(40; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
            Editable = false;
        }
        field(41; "Amount Excluding VAT"; Decimal)
        {
            Caption = 'Amount Excluding VAT';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
            Editable = false;
        }
        field(42; "VAT Amount"; Decimal)
        {
            Caption = 'VAT Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
            Editable = false;
        }
        field(43; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
        }
        field(50; Status; Enum "ADM Buffer Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            InitValue = New;
        }
        field(51; "Split Status"; Option)
        {
            Caption = 'Split Status';
            DataClassification = CustomerContent;
            OptionMembers = "Not Split","Split Suggested","Split Confirmed","Orders Created";
            OptionCaption = 'Not Split,Split Suggested,Split Confirmed,Orders Created';
        }
        field(60; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = CustomerContent;
        }
        field(61; "Orders Created At"; DateTime)
        {
            Caption = 'Orders Created At';
            DataClassification = CustomerContent;
        }
        field(62; Notes; Text[2048])
        {
            Caption = 'Notes';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(ManageSaleID; "Manage Sale ID") { }
        key(ClientCustomerNo; "Client Customer No.") { }
        key(Status; Status) { }
        key(StatusOrderDate; Status, "Order Date") { }
        key(SplitStatus; "Split Status") { }
    }

    trigger OnInsert()
    begin
        if "No." = '' then
            NoSeriesMgt.GetNextNo(GetNoSeriesCode(), 0D);
        "Created At" := CurrentDateTime();
    end;

    local procedure GetNoSeriesCode(): Code[20]
    var
        DefaultNoSeriesLbl: Label 'ADM-ORD', Locked = true;
    begin
        // No. Series is not stored in setup yet - using a default code
        // This can be extended later to read from Integration Setup
        exit(DefaultNoSeriesLbl);
    end;

    procedure CalcTotalAmount()
    var
        MasterOrderLine: Record "ADM Master Order Line";
    begin
        MasterOrderLine.SetRange("Master Order No.", "No.");
        MasterOrderLine.CalcSums("Line Amount", "VAT Amount");
        "Amount Excluding VAT" := MasterOrderLine."Line Amount";
        "VAT Amount" := MasterOrderLine."VAT Amount";
        "Total Amount" := "Amount Excluding VAT" + "VAT Amount";
        Modify();
    end;

    procedure GetSplitTotal(): Decimal
    var
        OrderSplitLine: Record "ADM Order Split Line";
    begin
        OrderSplitLine.SetRange("Master Order No.", "No.");
        OrderSplitLine.CalcSums("Calculated Amount");
        exit(OrderSplitLine."Calculated Amount");
    end;

    procedure CanCreateOrders(): Boolean
    begin
        exit(
            ("Split Status" = "Split Status"::"Split Confirmed") and
            (Status = "ADM Buffer Status"::New)
        );
    end;

    var
        NoSeriesMgt: Codeunit "No. Series";
}
