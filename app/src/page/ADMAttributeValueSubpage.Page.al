page 80323 "ADM Attribute Value Subpage"
{
    Caption = 'Attribute Values';
    PageType = ListPart;
    SourceTable = "ADM Attribute Value";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Values)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the attribute value name.';
                }
                field("Is Active"; Rec."Is Active")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this value is active in AuditData Manage.';
                }
            }
        }
    }
}
