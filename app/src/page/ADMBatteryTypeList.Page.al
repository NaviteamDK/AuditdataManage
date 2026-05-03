page 80321 "ADM Battery Type List"
{
    Caption = 'AuditData Manage Battery Types';
    PageType = List;
    SourceTable = "ADM Battery Type";
    UsageCategory = Administration;
    ApplicationArea = All;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(BatteryTypes)
            {
                field("Manage Battery Type ID"; Rec."Manage Battery Type ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier of this battery type in AuditData Manage.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the battery type as defined in AuditData Manage.';
                }
                field("Is Active"; Rec."Is Active")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this battery type is currently active in AuditData Manage.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SyncBatteryTypes)
            {
                ApplicationArea = All;
                Caption = 'Sync Battery Types from Manage';
                Image = Refresh;
                ToolTip = 'Retrieves all available battery types from AuditData Manage and updates this list.';

                trigger OnAction()
                var
                    InvRefSync: Codeunit "ADM Inventory Reference Sync";
                    ErrorText: Text;
                begin
                    if not InvRefSync.SyncBatteryTypes(ErrorText) then
                        Error(ErrorText);
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
