page 80327 "ADM Item Color Links"
{
    Caption = 'Item Color Links';
    PageType = List;
    SourceTable = "ADM Item Color";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
    ApplicationArea = All;
    UsageCategory = None;

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
                    ToolTip = 'Select to include this color when syncing the item to AuditData Manage.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(FetchFromManage)
            {
                ApplicationArea = All;
                Caption = 'Fetch from Manage';
                Image = ImportDatabase;
                ToolTip = 'Retrieves the color assignments for this item from AuditData Manage and updates the Linked checkboxes accordingly.';

                trigger OnAction()
                var
                    InvRefSync: Codeunit "ADM Inventory Reference Sync";
                    ItemNo: Code[20];
                begin
                    ItemNo := Rec."Item No.";
                    if ItemNo = '' then
                        Error('Save the item first before fetching assignments from AuditData Manage.');
                    InvRefSync.FetchItemAssignments(ItemNo);
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
