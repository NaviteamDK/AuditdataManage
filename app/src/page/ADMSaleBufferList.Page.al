page 50108 "ADM Sale Buffer List"
{
    Caption = 'Sale Buffer';
    PageType = List;
    SourceTable = "ADM Sale Buffer Header";
    SourceTableView = sorting(Status, "Sale Date");
    UsageCategory = Lists;
    ApplicationArea = All;
    InsertAllowed = false;
    ModifyAllowed = false;
    CardPageId = "ADM Sale Buffer Card";

    layout
    {
        area(Content)
        {
            repeater(SaleLines)
            {
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyle;
                    ToolTip = 'Specifies the processing status of this sale buffer record.';
                }
                field("Sale No."; Rec."Sale No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the sale number from AuditData Manage.';
                }
                field("Sale Date"; Rec."Sale Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date of the sale in AuditData Manage.';
                }
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
                field("Location Name"; Rec."Location Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the AuditData Manage location where this sale was made.';
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total amount of the sale including VAT.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the currency of the sale.';
                }
                field("Sale Status"; Rec."Sale Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status of the sale as reported by AuditData Manage.';
                }
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
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    StyleExpr = 'Unfavorable';
                    ToolTip = 'Specifies the error message if processing this sale failed.';
                }
            }
        }
        area(FactBoxes)
        {
            systempart(Notes; Notes) { }
        }
    }

    actions
    {
        area(Processing)
        {
            action(PromoteSelected)
            {
                ApplicationArea = All;
                Caption = 'Promote to Master Order';
                Image = MakeOrder;
                ToolTip = 'Promotes the selected sale buffer records to Master Orders.';

                trigger OnAction()
                var
                    SaleBufferHeader: Record "ADM Sale Buffer Header";
                    BufferProcessor: Codeunit "ADM Buffer Processor";
                begin
                    CurrPage.SetSelectionFilter(SaleBufferHeader);
                    if SaleBufferHeader.IsEmpty() then
                        Error('Please select one or more sale records to promote.');
                    BufferProcessor.ProcessSaleBuffer(SaleBufferHeader);
                    CurrPage.Update(false);
                end;
            }
            action(PromoteAllNew)
            {
                ApplicationArea = All;
                Caption = 'Promote All New';
                Image = ApplyEntries;
                ToolTip = 'Promotes all new sale buffer records to Master Orders.';

                trigger OnAction()
                var
                    SaleBufferHeader: Record "ADM Sale Buffer Header";
                    BufferProcessor: Codeunit "ADM Buffer Processor";
                begin
                    SaleBufferHeader.SetRange(Status, "ADM Buffer Status"::New);
                    if SaleBufferHeader.IsEmpty() then begin
                        Message('There are no new sale records to promote.');
                        exit;
                    end;
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
                    if Rec."Master Order No." = '' then
                        Error('This sale has not yet been promoted to a master order.');
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
