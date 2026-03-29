page 50111 "ADM Master Order List"
{
    Caption = 'Master Orders';
    PageType = List;
    SourceTable = "ADM Master Order Header";
    SourceTableView = sorting(Status, "Order Date") order(descending);
    UsageCategory = Lists;
    ApplicationArea = All;
    CardPageId = "ADM Master Order Card";
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(OrderLines)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the master order number.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyle;
                    ToolTip = 'Specifies the processing status of this master order.';
                }
                field("Split Status"; Rec."Split Status")
                {
                    ApplicationArea = All;
                    StyleExpr = SplitStatusStyle;
                    ToolTip = 'Specifies the current splitting stage of this master order.';
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date of the original sale in AuditData Manage.';
                }
                field("Client Name"; Rec."Client Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the client for this master order.';
                }
                field("Client Customer No."; Rec."Client Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Business Central customer number of the client.';
                }
                field("Location Name"; Rec."Location Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the AuditData Manage location for this order.';
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total amount of this master order.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the currency of this master order.';
                }
                field("Manage Sale No."; Rec."Manage Sale No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the original sale number from AuditData Manage.';
                }
                field("External Doc. No."; Rec."External Doc. No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the external document number from AuditData Manage.';
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
            action(SuggestSplit)
            {
                ApplicationArea = All;
                Caption = 'Suggest Split';
                Image = SuggestSalesPrices;
                ToolTip = 'Auto-suggests order split lines for the selected master orders based on active funder terms.';

                trigger OnAction()
                var
                    MasterOrderHeader: Record "ADM Master Order Header";
                    SplitSuggester: Codeunit "ADM Split Suggester";
                begin
                    CurrPage.SetSelectionFilter(MasterOrderHeader);
                    if MasterOrderHeader.IsEmpty() then
                        Error('Please select one or more master orders.');
                    if MasterOrderHeader.FindSet() then
                        repeat
                            SplitSuggester.SuggestSplitLines(MasterOrderHeader);
                        until MasterOrderHeader.Next() = 0;
                    CurrPage.Update(false);
                end;
            }
            action(CreateOrders)
            {
                ApplicationArea = All;
                Caption = 'Create Sales Orders';
                Image = CreateDocuments;
                ToolTip = 'Creates individual Business Central sales orders for each split line on the selected confirmed master orders.';

                trigger OnAction()
                var
                    MasterOrderHeader: Record "ADM Master Order Header";
                    OrderSplitter: Codeunit "ADM Order Splitter";
                begin
                    CurrPage.SetSelectionFilter(MasterOrderHeader);
                    if MasterOrderHeader.IsEmpty() then
                        Error('Please select one or more master orders.');
                    if MasterOrderHeader.FindSet() then
                        repeat
                            OrderSplitter.CreateSalesOrders(MasterOrderHeader);
                        until MasterOrderHeader.Next() = 0;
                    CurrPage.Update(false);
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
        case Rec."Split Status" of
            Rec."Split Status"::"Not Split":
                SplitStatusStyle := 'Standard';
            Rec."Split Status"::"Split Suggested":
                SplitStatusStyle := 'Ambiguous';
            Rec."Split Status"::"Split Confirmed":
                SplitStatusStyle := 'Favorable';
            Rec."Split Status"::"Orders Created":
                SplitStatusStyle := 'Favorable';
        end;
    end;

    var
        StatusStyle: Text;
        SplitStatusStyle: Text;
}
