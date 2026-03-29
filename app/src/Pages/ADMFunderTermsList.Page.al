page 50104 "ADM Funder Terms List"
{
    Caption = 'Funder Terms';
    PageType = List;
    SourceTable = "ADM Funder Terms";
    SourceTableView = sorting(Priority);
    UsageCategory = Administration;
    ApplicationArea = All;
    CardPageId = "ADM Funder Terms Card";

    layout
    {
        area(Content)
        {
            repeater(FunderLines)
            {
                field(Priority; Rec.Priority)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the order in which this funder is applied when splitting a master order. Lower numbers are applied first.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Business Central customer number for this funder.';
                }
                field("Funder Name"; Rec."Funder Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the funder.';
                }
                field("Split Type"; Rec."Split Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this funder pays a fixed amount or a percentage of the remaining order total.';
                }
                field("Default Amount"; Rec."Default Amount")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the default fixed amount this funder contributes to an order.';
                }
                field("Default Percentage"; Rec."Default Percentage")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the default percentage of the remaining order total this funder contributes.';
                }
                field(DefaultValue; Rec.GetDefaultValue())
                {
                    ApplicationArea = All;
                    Caption = 'Default Value';
                    DecimalPlaces = 2 : 2;
                    ToolTip = 'Specifies the default amount or percentage for this funder, depending on the split type.';
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this funder is active and will be included in auto-suggested order splits.';
                }
            }
        }
        area(FactBoxes)
        {
            systempart(Notes; Notes) { }
            systempart(Links; Links) { }
        }
    }

    actions
    {
        area(Processing)
        {
            action(MoveUp)
            {
                ApplicationArea = All;
                Caption = 'Move Up';
                Image = MoveUp;
                ToolTip = 'Increases the priority of the selected funder by swapping it with the funder above.';

                trigger OnAction()
                begin
                    MovePriority(-1);
                end;
            }
            action(MoveDown)
            {
                ApplicationArea = All;
                Caption = 'Move Down';
                Image = MoveDown;
                ToolTip = 'Decreases the priority of the selected funder by swapping it with the funder below.';

                trigger OnAction()
                begin
                    MovePriority(1);
                end;
            }
            action(ActivateAll)
            {
                ApplicationArea = All;
                Caption = 'Activate All';
                Image = Apply;
                ToolTip = 'Marks all funders as active so they are included in auto-suggested order splits.';

                trigger OnAction()
                begin
                    Rec.ModifyAll(Active, true);
                end;
            }
            action(DeactivateAll)
            {
                ApplicationArea = All;
                Caption = 'Deactivate All';
                Image = Stop;
                ToolTip = 'Marks all funders as inactive so they are excluded from auto-suggested order splits.';

                trigger OnAction()
                begin
                    Rec.ModifyAll(Active, false);
                end;
            }
        }
    }

    local procedure MovePriority(Direction: Integer)
    var
        OtherFunderTerms: Record "ADM Funder Terms";
        TempPriority: Integer;
        NoFunderToSwapErr: Label 'Cannot move funder in that direction.';
    begin
        OtherFunderTerms.SetRange(Active, Rec.Active);
        if Direction < 0 then begin
            OtherFunderTerms.SetFilter(Priority, '<%1', Rec.Priority);
            if not OtherFunderTerms.FindLast() then
                Error(NoFunderToSwapErr);
        end else begin
            OtherFunderTerms.SetFilter(Priority, '>%1', Rec.Priority);
            if not OtherFunderTerms.FindFirst() then
                Error(NoFunderToSwapErr);
        end;

        TempPriority := Rec.Priority;
        Rec.Priority := OtherFunderTerms.Priority;
        Rec.Modify();
        OtherFunderTerms.Priority := TempPriority;
        OtherFunderTerms.Modify();
        CurrPage.Update(false);
    end;
}
