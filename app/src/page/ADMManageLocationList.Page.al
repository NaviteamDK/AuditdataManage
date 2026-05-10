page 80334 "ADM Manage Location List"
{
    Caption = 'AuditData Manage Locations';
    PageType = List;
    SourceTable = "ADM Manage Location";
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Locations)
            {
                field("Manage Location ID"; Rec."Manage Location ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier of this location in AuditData Manage. Use this ID when configuring the Default Manage Location ID in the Integration Setup, or when assigning a Manage Location ID to a BC Location.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the AuditData Manage location.';
                }
                field("Is Active"; Rec."Is Active")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this location is currently active in AuditData Manage.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SyncLocations)
            {
                ApplicationArea = All;
                Caption = 'Sync Locations from Manage';
                Image = Refresh;
                ToolTip = 'Fetches the list of clinic locations (brands) from AuditData Manage and updates this table.';

                trigger OnAction()
                var
                    ADMInvRefSync: Codeunit "ADM Inventory Reference Sync";
                    ErrorText: Text;
                    SyncDoneMsg: Label 'Locations synced successfully from AuditData Manage.';
                begin
                    if ADMInvRefSync.SyncLocations(ErrorText) then
                        Message(SyncDoneMsg)
                    else
                        Error(ErrorText);
                end;
            }
        }
    }
}
