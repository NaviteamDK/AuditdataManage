page 80328 "ADM Item Battery Type Links"
{
    Caption = 'Item Battery Type Links';
    PageType = List;
    SourceTable = "ADM Item Battery Type";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(BatteryTypes)
            {
                field("Battery Type Name"; Rec."Battery Type Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'The battery type name as defined in AuditData Manage.';
                }
                field(Linked; Rec."Linked")
                {
                    ApplicationArea = All;
                    ToolTip = 'Select to include this battery type when syncing the item to AuditData Manage.';
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
                ToolTip = 'Retrieves the battery type assignments for this item from AuditData Manage and updates the Linked checkboxes accordingly.';

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
