page 80324 "ADM Item Color Subpage"
{
    Caption = 'Manage Colors';
    PageType = ListPart;
    SourceTable = "ADM Item Color";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Colors)
            {
                field("Color Name"; Rec."Color Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'The color name as defined in AuditData Manage.';
                }
                field(Linked; Rec."Linked")
                {
                    ApplicationArea = All;
                    ToolTip = 'Select to mark this color as linked to the item. Only linked colors will be included when syncing to AuditData Manage.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Maintain)
            {
                ApplicationArea = All;
                Caption = 'Maintain';
                Image = Edit;
                ToolTip = 'Open the color link maintenance page for this item.';

                trigger OnAction()
                var
                    ItemColor: Record "ADM Item Color";
                    ItemColorLinks: Page "ADM Item Color Links";
                    ItemNo: Code[20];
                begin
                    ItemNo := CopyStr(Rec.GetFilter("Item No."), 1, MaxStrLen(ItemNo));
                    if ItemNo = '' then
                        ItemNo := Rec."Item No.";
                    if ItemNo = '' then
                        Error('Navigate to an item first.');
                    ItemColor.SetRange("Item No.", ItemNo);
                    ItemColorLinks.SetTableView(ItemColor);
                    ItemColorLinks.Run();
                    CurrPage.Update(false);
                end;
            }
        }
    }

}
