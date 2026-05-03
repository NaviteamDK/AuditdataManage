page 80325 "ADM Item Battery Type Subpage"
{
    Caption = 'Manage Battery Types';
    PageType = ListPart;
    SourceTable = "ADM Item Battery Type";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
    ApplicationArea = All;

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
                field("Linked"; Rec."Linked")
                {
                    ApplicationArea = All;
                    ToolTip = 'Select to mark this battery type as linked to the item. Only linked battery types will be included when syncing to AuditData Manage.';
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
                ToolTip = 'Open the battery type link maintenance page for this item.';

                trigger OnAction()
                var
                    ItemBatteryType: Record "ADM Item Battery Type";
                    ItemBatteryTypeLinks: Page "ADM Item Battery Type Links";
                    ItemNo: Code[20];
                begin
                    ItemNo := CopyStr(Rec.GetFilter("Item No."), 1, MaxStrLen(ItemNo));
                    if ItemNo = '' then
                        ItemNo := Rec."Item No.";
                    if ItemNo = '' then
                        Error('Navigate to an item first.');
                    ItemBatteryType.SetRange("Item No.", ItemNo);
                    ItemBatteryType.SetRange("Is Active", true);
                    ItemBatteryTypeLinks.SetTableView(ItemBatteryType);
                    ItemBatteryTypeLinks.Run();
                    CurrPage.Update(false);
                end;
            }
        }
    }

}
