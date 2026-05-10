pageextension 80304 "ADM Location Card Ext" extends "Location Card"
{
    layout
    {
        addlast(General)
        {
            group(AuditDataManage)
            {
                Caption = 'AuditData Manage';

                field("ADM Manage Location ID"; Rec."ADM Manage Location ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the AuditData Manage location that corresponds to this BC location. Used by the stock level synchronisation to push inventory to the correct clinic in Manage. Run ''Sync Locations from Manage'' on the Manage Locations page to populate the available IDs.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"ADM Manage Location List");
                    end;
                }
            }
        }
    }
}
