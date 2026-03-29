table 50110 "ADM Master Order Line"
{
    Caption = 'AuditData Manage Master Order Line';
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
        field(10; "BC Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                if Item.Get("BC Item No.") then begin
                    Description := Item.Description;
                    "Unit Price" := Item."Unit Price";
                end;
            end;
        }
        field(11; Description; Text[200])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(12; "Manage Product ID"; Guid)
        {
            Caption = 'Manage Product ID';
            DataClassification = CustomerContent;
        }
        field(13; "Product SKU"; Text[100])
        {
            Caption = 'Product SKU';
            DataClassification = CustomerContent;
        }
        field(14; "Product Category"; Text[100])
        {
            Caption = 'Product Category';
            DataClassification = CustomerContent;
        }
        field(20; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                CalcLineAmount();
            end;
        }
        field(21; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;

            trigger OnValidate()
            begin
                CalcLineAmount();
            end;
        }
        field(22; "Discount Percentage"; Decimal)
        {
            Caption = 'Discount Percentage (%)';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
            MinValue = 0;
            MaxValue = 100;

            trigger OnValidate()
            begin
                CalcLineAmount();
            end;
        }
        field(23; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
        }
        field(24; "Line Amount"; Decimal)
        {
            Caption = 'Line Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
            Editable = false;
        }
        field(25; "VAT Amount"; Decimal)
        {
            Caption = 'VAT Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
        }
        field(30; "Serial No."; Text[50])
        {
            Caption = 'Serial No.';
            DataClassification = CustomerContent;
        }
        field(31; "Is Serialized"; Boolean)
        {
            Caption = 'Is Serialized';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Master Order No.", "Line No.")
        {
            Clustered = true;
        }
        key(BCItemNo; "BC Item No.") { }
    }

    local procedure CalcLineAmount()
    begin
        "Discount Amount" := Round(Quantity * "Unit Price" * "Discount Percentage" / 100, 0.01);
        "Line Amount" := Round(Quantity * "Unit Price", 0.01) - "Discount Amount";
    end;
}
