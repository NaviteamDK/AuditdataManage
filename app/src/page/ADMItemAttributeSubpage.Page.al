page 80326 "ADM Item Attribute Subpage"
{
    Caption = 'Manage Attributes';
    PageType = ListPart;
    SourceTable = "ADM Item Attribute";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
    ApplicationArea = All;

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
                    ToolTip = 'Select to mark this attribute value as linked to the item. Only linked values will be included when syncing to AuditData Manage.';
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
                ToolTip = 'Open the attribute link maintenance page for this item.';

                trigger OnAction()
                var
                    ItemAttribute: Record "ADM Item Attribute";
                    ItemAttributeLinks: Page "ADM Item Attribute Links";
                    ItemNo: Code[20];
                begin
                    ItemNo := CopyStr(Rec.GetFilter("Item No."), 1, MaxStrLen(ItemNo));
                    if ItemNo = '' then
                        ItemNo := Rec."Item No.";
                    if ItemNo = '' then
                        Error('Navigate to an item first.');
                    ItemAttribute.SetRange("Item No.", ItemNo);
                    ItemAttributeLinks.SetTableView(ItemAttribute);
                    ItemAttributeLinks.Run();
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
