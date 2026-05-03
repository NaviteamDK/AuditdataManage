page 80331 "ADM Manufacturer List"
{
    Caption = 'AuditData Manage Manufacturers';
    PageType = List;
    SourceTable = "ADM Manufacturer";
    UsageCategory = Administration;
    ApplicationArea = All;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Manufacturers)
            {
                field("Manage Manufacturer ID"; Rec."Manage Manufacturer ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier of this manufacturer in AuditData Manage.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the manufacturer.';
                }
                field("Is Active"; Rec."Is Active")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this manufacturer is active in AuditData Manage.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SyncManufacturers)
            {
                ApplicationArea = All;
                Caption = 'Sync Manufacturers from Manage';
                Image = Refresh;
                ToolTip = 'Retrieves all available manufacturers from AuditData Manage and updates this list.';

                trigger OnAction()
                var
                    InvRefSync: Codeunit "ADM Inventory Reference Sync";
                    ErrorText: Text;
                begin
                    if not InvRefSync.SyncManufacturers(ErrorText) then
                        Error(ErrorText);
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
