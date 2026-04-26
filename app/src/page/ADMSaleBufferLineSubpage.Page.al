page 80310 "ADM Sale Buffer Line Subpage"
{
    Caption = 'Sale Lines';
    PageType = ListPart;
    SourceTable = "ADM Sale Buffer Line";
    ApplicationArea = All;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the line number of this sale line.';
                }
                field("Product Name"; Rec."Product Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the product on this sale line.';
                }
                field("Product SKU"; Rec."Product SKU")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the SKU of the product as defined in AuditData Manage.';
                }
                field("BC Item No."; Rec."BC Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Business Central item number mapped to this product.';
                }
                field("Product Category"; Rec."Product Category")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the product category from AuditData Manage.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity of the product on this sale line.';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit price of the product.';
                }
                field("Discount Percentage"; Rec."Discount Percentage")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the discount percentage applied to this line.';
                }
                field("Line Amount"; Rec."Line Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total amount for this line after discount.';
                }
                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the serial number of the product, if serialized.';
                }
                field("Is Serialized"; Rec."Is Serialized")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this product is tracked by serial number.';
                }
            }
        }
    }
}
