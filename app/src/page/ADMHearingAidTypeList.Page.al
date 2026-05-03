page 80333 "ADM Hearing Aid Type List"
{
    Caption = 'AuditData Manage Hearing Aid Types';
    PageType = List;
    SourceTable = "ADM Hearing Aid Type";
    UsageCategory = Administration;
    ApplicationArea = All;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(HearingAidTypes)
            {
                field("Manage Hearing Aid Type ID"; Rec."Manage Hearing Aid Type ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier of this hearing aid type in AuditData Manage.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the hearing aid type as defined in AuditData Manage.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SyncHearingAidTypes)
            {
                ApplicationArea = All;
                Caption = 'Sync Hearing Aid Types from Manage';
                Image = Refresh;
                ToolTip = 'Retrieves all available hearing aid types from AuditData Manage and updates this list.';

                trigger OnAction()
                var
                    InvRefSync: Codeunit "ADM Inventory Reference Sync";
                    ErrorText: Text;
                begin
                    if not InvRefSync.SyncHearingAidTypes(ErrorText) then
                        Error(ErrorText);
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
