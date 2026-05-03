page 80330 "ADM Product Category List"
{
    Caption = 'AuditData Manage Product Categories';
    PageType = List;
    SourceTable = "ADM Product Category";
    UsageCategory = Administration;
    ApplicationArea = All;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Categories)
            {
                field("Manage Category ID"; Rec."Manage Category ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier of this product category in AuditData Manage.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the display name of this product category.';
                }
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the category code as defined in AuditData Manage (e.g. HearingAids, Batteries).';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SyncProductCategories)
            {
                ApplicationArea = All;
                Caption = 'Sync Categories from Manage';
                Image = Refresh;
                ToolTip = 'Retrieves all available product categories from AuditData Manage and updates this list.';

                trigger OnAction()
                var
                    InvRefSync: Codeunit "ADM Inventory Reference Sync";
                    ErrorText: Text;
                begin
                    if not InvRefSync.SyncProductCategories(ErrorText) then
                        Error(ErrorText);
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
