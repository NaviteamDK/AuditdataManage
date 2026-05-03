page 80322 "ADM Attribute List"
{
    Caption = 'AuditData Manage Attributes';
    PageType = List;
    SourceTable = "ADM Attribute";
    UsageCategory = Administration;
    ApplicationArea = All;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Attributes)
            {
                field("Manage Attribute ID"; Rec."Manage Attribute ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier of this attribute in AuditData Manage.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the attribute as defined in AuditData Manage.';
                }
                field("Is Active"; Rec."Is Active")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this attribute is currently active in AuditData Manage.';
                }
            }
        }
        area(FactBoxes)
        {
            part(AttributeValues; "ADM Attribute Value Subpage")
            {
                ApplicationArea = All;
                Caption = 'Attribute Values';
                SubPageLink = "Manage Attribute ID" = field("Manage Attribute ID");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SyncAttributes)
            {
                ApplicationArea = All;
                Caption = 'Sync Attributes from Manage';
                Image = Refresh;
                ToolTip = 'Retrieves all available attributes and their values from AuditData Manage and updates this list.';

                trigger OnAction()
                var
                    InvRefSync: Codeunit "ADM Inventory Reference Sync";
                    ErrorText: Text;
                begin
                    if not InvRefSync.SyncAttributes(ErrorText) then
                        Error(ErrorText);
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
