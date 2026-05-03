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
}
