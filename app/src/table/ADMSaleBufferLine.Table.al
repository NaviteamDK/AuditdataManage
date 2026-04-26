table 80308 "ADM Sale Buffer Line"
{
    Caption = 'AuditData Manage Sale Buffer Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Manage Sale ID"; Guid)
        {
            Caption = 'Manage Sale ID';
            DataClassification = CustomerContent;
            TableRelation = "ADM Sale Buffer Header"."Manage Sale ID";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; "Manage Product ID"; Guid)
        {
            Caption = 'Manage Product ID';
            DataClassification = CustomerContent;
        }
        field(11; "Manage Sale Product ID"; Guid)
        {
            Caption = 'Manage Sale Product ID';
            DataClassification = CustomerContent;
        }
        field(12; "Product Name"; Text[200])
        {
            Caption = 'Product Name';
            DataClassification = CustomerContent;
        }
        field(13; "Product SKU"; Text[100])
        {
            Caption = 'Product SKU';
            DataClassification = CustomerContent;
        }
        field(14; "BC Item No."; Code[20])
        {
            Caption = 'BC Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(20; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(21; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
        }
        field(22; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
        }
        field(23; "Discount Percentage"; Decimal)
        {
            Caption = 'Discount Percentage (%)';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
        }
        field(24; "Line Amount"; Decimal)
        {
            Caption = 'Line Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
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
        field(31; "Product Category"; Text[100])
        {
            Caption = 'Product Category';
            DataClassification = CustomerContent;
        }
        field(40; "Is Serialized"; Boolean)
        {
            Caption = 'Is Serialized';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Manage Sale ID", "Line No.")
        {
            Clustered = true;
        }
        key(ManageProductID; "Manage Product ID") { }
        key(BCItemNo; "BC Item No.") { }
    }
}
