page 50114 "ADM Order Split Subpage"
{
    Caption = 'Payment Split';
    PageType = ListPart;
    SourceTable = "ADM Order Split Line";
    SourceTableView = sorting(Priority);
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(SplitLines)
            {
                field(Priority; Rec.Priority)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the order in which this payer is applied. Lower numbers are calculated first.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Business Central customer responsible for this portion of the order.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the name of the payer.';
                }
                field("Is Client"; Rec."Is Client")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies whether this line represents the client (residual payer).';
                }
                field("Split Type"; Rec."Split Type")
                {
                    ApplicationArea = All;
                    Enabled = not Rec."Is Client";
                    ToolTip = 'Specifies whether this payer contributes a fixed amount or a percentage of the remaining balance.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Split Amount"; Rec."Split Amount")
                {
                    ApplicationArea = All;
                    Enabled = (Rec."Split Type" = "ADM Split Type"::"Fixed Amount") and (not Rec."Is Client");
                    ToolTip = 'Specifies the fixed amount this payer contributes.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Split Percentage"; Rec."Split Percentage")
                {
                    ApplicationArea = All;
                    Enabled = (Rec."Split Type" = "ADM Split Type"::"Percentage of Remaining") and (not Rec."Is Client");
                    ToolTip = 'Specifies the percentage of the remaining order balance this payer contributes.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Calculated Amount"; Rec."Calculated Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the calculated amount for this payer based on the split type and the order total.';
                }
                field("BC Sales Order No."; Rec."BC Sales Order No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the Business Central sales order number created for this split line.';
                }
                field("Order Created"; Rec."Order Created")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = OrderCreatedStyle;
                    ToolTip = 'Specifies whether a Business Central sales order has been created for this split line.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenSalesOrder)
            {
                ApplicationArea = All;
                Caption = 'Open Sales Order';
                Image = Order;
                Enabled = Rec."BC Sales Order No." <> '';
                ToolTip = 'Opens the Business Central sales order created for this split line.';

                trigger OnAction()
                var
                    SalesHeader: Record "Sales Header";
                begin
                    if Rec."BC Sales Order No." = '' then
                        exit;
                    SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
                    SalesHeader.SetRange("No.", Rec."BC Sales Order No.");
                    if SalesHeader.FindFirst() then
                        Page.Run(Page::"Sales Order", SalesHeader);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if Rec."Order Created" then
            OrderCreatedStyle := 'Favorable'
        else
            OrderCreatedStyle := 'Standard';
    end;

    var
        OrderCreatedStyle: Text;
}
