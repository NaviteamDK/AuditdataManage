page 80329 "ADM Item Attribute Links"
{
    Caption = 'Item Attribute Links';
    PageType = List;
    SourceTable = "ADM Item Attribute";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Attributes)
            {
                field("Attribute Name"; Rec."Attribute Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'The attribute name as defined in AuditData Manage.';
                }
                field("Value Name"; Rec."Value Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'The attribute value as defined in AuditData Manage.';
                }
                field(Linked; Rec."Linked")
                {
                    ApplicationArea = All;
                    ToolTip = 'Select to include this attribute value when syncing the item to AuditData Manage.';
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
                ToolTip = 'Retrieves the attribute assignments for this item from AuditData Manage and updates the Linked checkboxes accordingly.';

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
