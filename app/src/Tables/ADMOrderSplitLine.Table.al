table 50111 "ADM Order Split Line"
{
    Caption = 'AuditData Manage Order Split Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Master Order No."; Code[20])
        {
            Caption = 'Master Order No.';
            DataClassification = CustomerContent;
            TableRelation = "ADM Master Order Header"."No.";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; Priority; Integer)
        {
            Caption = 'Priority';
            DataClassification = CustomerContent;
            MinValue = 1;
        }
        field(11; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;

            trigger OnValidate()
            var
                Customer: Record Customer;
            begin
                if Customer.Get("Customer No.") then
                    "Customer Name" := Customer.Name;
            end;
        }
        field(12; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
        }
        field(13; "Is Client"; Boolean)
        {
            Caption = 'Is Client (Residual Payer)';
            DataClassification = CustomerContent;
        }
        field(20; "Split Type"; Enum "ADM Split Type")
        {
            Caption = 'Split Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Split Type" = "ADM Split Type"::"Fixed Amount" then
                    "Split Percentage" := 0
                else
                    "Split Amount" := 0;
                "Calculated Amount" := 0;
            end;
        }
        field(21; "Split Amount"; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
            MinValue = 0;

            trigger OnValidate()
            begin
                if "Split Type" = "ADM Split Type"::"Fixed Amount" then
                    "Calculated Amount" := "Split Amount";
            end;
        }
        field(22; "Split Percentage"; Decimal)
        {
            Caption = 'Percentage (%)';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
            MinValue = 0;
            MaxValue = 100;
        }
        field(23; "Calculated Amount"; Decimal)
        {
            Caption = 'Calculated Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
            Editable = false;
        }
        field(30; "BC Sales Order No."; Code[20])
        {
            Caption = 'BC Sales Order No.';
            DataClassification = CustomerContent;
        }
        field(31; "Order Created"; Boolean)
        {
            Caption = 'Order Created';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Master Order No.", "Line No.")
        {
            Clustered = true;
        }
        key(Priority; "Master Order No.", Priority) { }
        key(CustomerNo; "Customer No.") { }
    }

    procedure GetNextLineNo(MasterOrderNo: Code[20]): Integer
    var
        OrderSplitLine: Record "ADM Order Split Line";
    begin
        OrderSplitLine.SetRange("Master Order No.", MasterOrderNo);
        if OrderSplitLine.FindLast() then
            exit(OrderSplitLine."Line No." + 10000);
        exit(10000);
    end;
}
