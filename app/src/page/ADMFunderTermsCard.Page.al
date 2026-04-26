page 80305 "ADM Funder Terms Card"
{
    Caption = 'Funder Terms';
    PageType = Card;
    SourceTable = "ADM Funder Terms";
    UsageCategory = None;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Business Central customer number for this funder.';
                }
                field("Funder Name"; Rec."Funder Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the name of the funder, populated from the customer record.';
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this funder is active and will be included in auto-suggested order splits.';
                }
            }
            group(PaymentSplit)
            {
                Caption = 'Payment Split';

                field(Priority; Rec.Priority)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the order in which this funder is applied when splitting a master order. Lower numbers are applied first.';
                }
                field("Split Type"; Rec."Split Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this funder pays a fixed amount or a percentage of the remaining order total.';

                    trigger OnValidate()
                    begin
                        SetAmountFieldVisibility();
                    end;
                }
                field("Default Amount"; Rec."Default Amount")
                {
                    ApplicationArea = All;
                    Visible = ShowAmount;
                    ToolTip = 'Specifies the default fixed amount this funder contributes to an order.';
                }
                field("Default Percentage"; Rec."Default Percentage")
                {
                    ApplicationArea = All;
                    Visible = ShowPercentage;
                    ToolTip = 'Specifies the default percentage of the remaining order total this funder contributes.';
                }
                field(Notes; Rec.Notes)
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ToolTip = 'Specifies any additional notes about this funder''s payment terms.';
                }
            }
        }
        area(FactBoxes)
        {
            part(CustomerDetails; "Customer Details FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("Customer No.");
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetAmountFieldVisibility();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetAmountFieldVisibility();
    end;

    local procedure SetAmountFieldVisibility()
    begin
        ShowAmount := Rec."Split Type" = "ADM Split Type"::"Fixed Amount";
        ShowPercentage := Rec."Split Type" = "ADM Split Type"::"Percentage of Remaining";
    end;

    var
        ShowAmount: Boolean;
        ShowPercentage: Boolean;
}
