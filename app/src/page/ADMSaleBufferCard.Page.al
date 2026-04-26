page 80309 "ADM Sale Buffer Card"
{
    Caption = 'Sale Buffer';
    PageType = Card;
    SourceTable = "ADM Sale Buffer Header";
    UsageCategory = None;
    ApplicationArea = All;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Manage Sale ID"; Rec."Manage Sale ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier of this sale in AuditData Manage.';
                }
                field("Sale No."; Rec."Sale No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the sale number from AuditData Manage.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyle;
                    ToolTip = 'Specifies the processing status of this sale.';
                }
                field("Sale Status"; Rec."Sale Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status of the sale as reported by AuditData Manage.';
                }
                field("Sale Date"; Rec."Sale Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date of the sale.';
                }
                field("External Doc. No."; Rec."External Doc. No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the external document number from AuditData Manage.';
                }
            }
            group(ClientInfo)
            {
                Caption = 'Client';

                field("Client Name"; Rec."Client Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the client associated with this sale.';
                }
                field("BC Client Customer No."; Rec."BC Client Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Business Central customer number of the client.';
                }
                field("Manage Client ID"; Rec."Manage Client ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the AuditData Manage unique identifier of the client.';
                }
            }
            group(LocationInfo)
            {
                Caption = 'Location';

                field("Location Name"; Rec."Location Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the AuditData Manage location where this sale was made.';
                }
                field("Location ID"; Rec."Location ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the AuditData Manage unique identifier of the location.';
                }
            }
            group(Amounts)
            {
                Caption = 'Amounts';

                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the currency of the sale.';
                }
                field("Amount Excluding VAT"; Rec."Amount Excluding VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total sale amount excluding VAT.';
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the VAT amount on the sale.';
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total sale amount including VAT.';
                }
            }
            group(Processing)
            {
                Caption = 'Processing';

                field("Master Order No."; Rec."Master Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Business Central master order number this sale has been promoted to.';
                }
                field("Imported At"; Rec."Imported At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when this sale was imported from AuditData Manage.';
                }
                field("Processed At"; Rec."Processed At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when this sale was promoted to a master order.';
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    StyleExpr = 'Unfavorable';
                    ToolTip = 'Specifies the error message if processing this sale failed.';
                }
            }
            group(NotesGroup)
            {
                Caption = 'Notes';

                field(Notes; Rec.Notes)
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ToolTip = 'Specifies any notes from AuditData Manage about this sale.';
                }
            }
            part(SaleLines; "ADM Sale Buffer Line Subpage")
            {
                ApplicationArea = All;
                Caption = 'Sale Lines';
                SubPageLink = "Manage Sale ID" = field("Manage Sale ID");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(PromoteToMasterOrder)
            {
                ApplicationArea = All;
                Caption = 'Promote to Master Order';
                Image = MakeOrder;
                Enabled = Rec.Status = "ADM Buffer Status"::New;
                ToolTip = 'Promotes this sale to a Master Order for order splitting.';

                trigger OnAction()
                var
                    SaleBufferHeader: Record "ADM Sale Buffer Header";
                    BufferProcessor: Codeunit "ADM Buffer Processor";
                begin
                    SaleBufferHeader := Rec;
                    BufferProcessor.ProcessSaleBuffer(SaleBufferHeader);
                    CurrPage.Update(false);
                end;
            }
        }
        area(Navigation)
        {
            action(OpenMasterOrder)
            {
                ApplicationArea = All;
                Caption = 'Open Master Order';
                Image = Order;
                Enabled = Rec."Master Order No." <> '';
                ToolTip = 'Opens the Master Order that this sale has been promoted to.';

                trigger OnAction()
                var
                    MasterOrderHeader: Record "ADM Master Order Header";
                begin
                    if MasterOrderHeader.Get(Rec."Master Order No.") then
                        Page.Run(Page::"ADM Master Order Card", MasterOrderHeader);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        case Rec.Status of
            "ADM Buffer Status"::New:
                StatusStyle := 'Standard';
            "ADM Buffer Status"::"In Progress":
                StatusStyle := 'Ambiguous';
            "ADM Buffer Status"::Processed:
                StatusStyle := 'Favorable';
            "ADM Buffer Status"::Error:
                StatusStyle := 'Unfavorable';
        end;
    end;

    var
        StatusStyle: Text;
}
