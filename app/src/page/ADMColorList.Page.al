page 80320 "ADM Color List"
{
    Caption = 'AuditData Manage Colors';
    PageType = List;
    SourceTable = "ADM Color";
    UsageCategory = Administration;
    ApplicationArea = All;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Colors)
            {
                field("Manage Color ID"; Rec."Manage Color ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier of this color in AuditData Manage.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the color as defined in AuditData Manage.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SyncColors)
            {
                ApplicationArea = All;
                Caption = 'Sync Colors from Manage';
                Image = Refresh;
                ToolTip = 'Retrieves all available colors from AuditData Manage and updates this list.';

                trigger OnAction()
                var
                    InvRefSync: Codeunit "ADM Inventory Reference Sync";
                    ErrorText: Text;
                begin
                    if not InvRefSync.SyncColors(ErrorText) then
                        Error(ErrorText);
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
