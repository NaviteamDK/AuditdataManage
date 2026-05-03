page 80332 "ADM Supplier List"
{
    Caption = 'AuditData Manage Suppliers';
    PageType = List;
    SourceTable = "ADM Supplier";
    UsageCategory = Administration;
    ApplicationArea = All;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Suppliers)
            {
                field("Manage Supplier ID"; Rec."Manage Supplier ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier of this supplier in AuditData Manage.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the supplier.';
                }
                field("Is Active"; Rec."Is Active")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this supplier is active in AuditData Manage.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SyncSuppliers)
            {
                ApplicationArea = All;
                Caption = 'Sync Suppliers from Manage';
                Image = Refresh;
                ToolTip = 'Retrieves all available suppliers from AuditData Manage and updates this list.';

                trigger OnAction()
                var
                    InvRefSync: Codeunit "ADM Inventory Reference Sync";
                    ErrorText: Text;
                begin
                    if not InvRefSync.SyncSuppliers(ErrorText) then
                        Error(ErrorText);
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
