page 50112 "ADM Master Order Card"
{
    Caption = 'Master Order';
    PageType = Document;
    SourceTable = "ADM Master Order Header";
    UsageCategory = None;
    ApplicationArea = All;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the master order number.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyle;
                    Editable = false;
                    ToolTip = 'Specifies the processing status of this master order.';
                }
                field("Split Status"; Rec."Split Status")
                {
                    ApplicationArea = All;
                    StyleExpr = SplitStatusStyle;
                    Editable = false;
                    ToolTip = 'Specifies the current splitting stage of this master order.';
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date of the original sale in AuditData Manage.';
                }
                field("Manage Sale No."; Rec."Manage Sale No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the original sale number from AuditData Manage.';
                }
                field("External Doc. No."; Rec."External Doc. No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the external document number from AuditData Manage.';
                }
                field("Location Name"; Rec."Location Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the AuditData Manage location for this order.';
                }
            }
            group(ClientGroup)
            {
                Caption = 'Client';

                field("Client Customer No."; Rec."Client Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Business Central customer number of the client.';
                }
                field("Client Name"; Rec."Client Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the name of the client for this master order.';
                }
            }
            group(AmountsGroup)
            {
                Caption = 'Amounts';

                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the currency of this master order.';
                }
                field("Amount Excluding VAT"; Rec."Amount Excluding VAT")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the total order amount excluding VAT.';
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the VAT amount on the order.';
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the total order amount including VAT.';
                }
                field(SplitTotal; Rec.GetSplitTotal())
                {
                    ApplicationArea = All;
                    Caption = 'Split Total';
                    Editable = false;
                    StyleExpr = SplitTotalStyle;
                    ToolTip = 'Specifies the sum of all split line calculated amounts. This should equal the Total Amount before confirming.';
                }
                field(Difference; Rec."Total Amount" - Rec.GetSplitTotal())
                {
                    ApplicationArea = All;
                    Caption = 'Remaining to Split';
                    Editable = false;
                    StyleExpr = DifferenceStyle;
                    ToolTip = 'Specifies the difference between the order total and the current split total. Should be zero before confirming.';
                }
            }
            group(NotesGroup)
            {
                Caption = 'Notes';

                field(Notes; Rec.Notes)
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ToolTip = 'Specifies any notes about this master order.';
                }
            }
            part(OrderLines; "ADM Master Order Line Subpage")
            {
                ApplicationArea = All;
                Caption = 'Order Lines';
                SubPageLink = "Master Order No." = field("No.");
            }
            part(SplitLines; "ADM Order Split Subpage")
            {
                ApplicationArea = All;
                Caption = 'Payment Split';
                SubPageLink = "Master Order No." = field("No.");
            }
        }
        area(FactBoxes)
        {
            part(CustomerDetails; "Customer Details FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("Client Customer No.");
                Caption = 'Client Details';
            }
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
                Enabled = Rec."Split Status" = Rec."Split Status"::"Not Split";
                ToolTip = 'Auto-suggests payment split lines based on all active funders and their default terms. The client is added as the residual payer.';

                trigger OnAction()
                var
                    SplitSuggester: Codeunit "ADM Split Suggester";
                begin
                    SplitSuggester.SuggestSplitLines(Rec);
                    CurrPage.SplitLines.Page.Update(false);
                    CurrPage.Update(false);
                end;
            }
            action(RecalcSplit)
            {
                ApplicationArea = All;
                Caption = 'Recalculate Split';
                Image = Refresh;
                Enabled = Rec."Split Status" in [Rec."Split Status"::"Split Suggested", Rec."Split Status"::"Split Confirmed"];
                ToolTip = 'Recalculates the calculated amounts on all split lines based on current amounts and percentages.';

                trigger OnAction()
                var
                    SplitSuggester: Codeunit "ADM Split Suggester";
                begin
                    SplitSuggester.RecalculateSplitAmounts(Rec);
                    CurrPage.SplitLines.Page.Update(false);
                    CurrPage.Update(false);
                end;
            }
            action(ConfirmSplit)
            {
                ApplicationArea = All;
                Caption = 'Confirm Split';
                Image = Approve;
                Enabled = Rec."Split Status" = Rec."Split Status"::"Split Suggested";
                ToolTip = 'Confirms the payment split and locks it for sales order creation. The split total must equal the order total.';

                trigger OnAction()
                var
                    SplitSuggester: Codeunit "ADM Split Suggester";
                begin
                    SplitSuggester.ConfirmSplit(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(ResetSplit)
            {
                ApplicationArea = All;
                Caption = 'Reset Split';
                Image = ResetStatus;
                Enabled = Rec."Split Status" in [Rec."Split Status"::"Split Suggested", Rec."Split Status"::"Split Confirmed"];
                ToolTip = 'Removes all split lines and resets the split status so you can start over.';

                trigger OnAction()
                var
                    OrderSplitLine: Record "ADM Order Split Line";
                    ResetConfirmQst: Label 'This will delete all current split lines. Are you sure?';
                begin
                    if not Confirm(ResetConfirmQst, false) then
                        exit;
                    OrderSplitLine.SetRange("Master Order No.", Rec."No.");
                    OrderSplitLine.DeleteAll();
                    Rec."Split Status" := Rec."Split Status"::"Not Split";
                    Rec.Modify();
                    CurrPage.SplitLines.Page.Update(false);
                    CurrPage.Update(false);
                end;
            }
            action(CreateSalesOrders)
            {
                ApplicationArea = All;
                Caption = 'Create Sales Orders';
                Image = CreateDocuments;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Enabled = Rec.CanCreateOrders();
                ToolTip = 'Creates individual Business Central sales orders for each confirmed split line.';

                trigger OnAction()
                var
                    OrderSplitter: Codeunit "ADM Order Splitter";
                begin
                    OrderSplitter.CreateSalesOrders(Rec);
                    CurrPage.SplitLines.Page.Update(false);
                    CurrPage.Update(false);
                end;
            }
        }
        area(Navigation)
        {
            action(OpenSaleBuffer)
            {
                ApplicationArea = All;
                Caption = 'Sale Buffer';
                Image = Documents;
                ToolTip = 'Opens the original sale buffer record that was used to create this master order.';

                trigger OnAction()
                var
                    SaleBufferHeader: Record "ADM Sale Buffer Header";
                begin
                    SaleBufferHeader.SetRange("Manage Sale ID", Rec."Manage Sale ID");
                    if SaleBufferHeader.FindFirst() then
                        Page.Run(Page::"ADM Sale Buffer Card", SaleBufferHeader);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetStyleExpressions();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetStyleExpressions();
    end;

    local procedure SetStyleExpressions()
    var
        Difference: Decimal;
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
            Rec."Split Status"::"Split Confirmed",
            Rec."Split Status"::"Orders Created":
                SplitStatusStyle := 'Favorable';
        end;
        Difference := Rec."Total Amount" - Rec.GetSplitTotal();
        if Abs(Difference) < 0.01 then begin
            SplitTotalStyle := 'Favorable';
            DifferenceStyle := 'Favorable';
        end else begin
            SplitTotalStyle := 'Unfavorable';
            DifferenceStyle := 'Unfavorable';
        end;
    end;

    var
        StatusStyle: Text;
        SplitStatusStyle: Text;
        SplitTotalStyle: Text;
        DifferenceStyle: Text;
}
