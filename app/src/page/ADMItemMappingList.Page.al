page 80303 "ADM Item Mapping List"
{
    Caption = 'AuditData Manage Product Catalog';
    PageType = List;
    SourceTable = "ADM Item Mapping";
    UsageCategory = Administration;
    ApplicationArea = All;
    InsertAllowed = false;
    DeleteAllowed = true;
    Editable = true;

    layout
    {
        area(Content)
        {
            repeater(MappingLines)
            {
                field("Manage SKU"; Rec."Manage SKU")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the SKU of the product in AuditData Manage.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the product name in AuditData Manage.';
                }
                field("Is Active"; Rec."Is Active")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the product is active in AuditData Manage.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the BC item number linked to this Manage product. Empty if not yet matched.';
                    StyleExpr = ItemLinkStyle;
                }
                field("Manage Product ID"; Rec."Manage Product ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the unique product ID in AuditData Manage.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(FetchManageProducts)
            {
                ApplicationArea = All;
                Caption = 'Fetch Products from Manage';
                Image = ImportDatabase;
                ToolTip = 'Retrieves all products from AuditData Manage into this catalog. Where the Manage SKU matches a BC item number, the item is automatically linked.';

                trigger OnAction()
                var
                    ProductSync: Codeunit "ADM Product Sync";
                    Linked: Integer;
                    Unmatched: Integer;
                    AlreadyLinked: Integer;
                    ErrorText: Text;
                    ResultMsg: Label 'Fetch complete.\Linked: %1\Already linked: %2\No BC item match (manual link required): %3', Comment = '%1 = linked count, %2 = already linked, %3 = unmatched';
                begin
                    if not ProductSync.FetchManageProducts(Linked, Unmatched, AlreadyLinked, ErrorText) then
                        Error('Failed to retrieve products from AuditData Manage:\%1', ErrorText);
                    CurrPage.Update(false);
                    Message(ResultMsg, Linked, AlreadyLinked, Unmatched);
                end;
            }
            action(LinkToBCItem)
            {
                ApplicationArea = All;
                Caption = 'Link to BC Item';
                Image = LinkWithExisting;
                ToolTip = 'Manually links the selected Manage product to a BC item. This writes the Manage Product ID onto the BC item so that sync can proceed.';

                trigger OnAction()
                var
                    Item: Record Item;
                    LinkedMsg: Label 'Manage product "%1" has been linked to BC item %2.', Comment = '%1 = Manage SKU, %2 = BC Item No.';
                begin
                    if IsNullGuid(Rec."Manage Product ID") then
                        exit;

                    if Page.RunModal(Page::"Item List", Item) <> Action::LookupOK then
                        exit;

                    Rec.Validate("Item No.", Item."No.");
                    Rec.Modify();
                    CurrPage.Update(false);
                    Message(LinkedMsg, Rec."Manage SKU", Item."No.");
                end;
            }
            action(FetchItemAssignments)
            {
                ApplicationArea = All;
                Caption = 'Fetch Color/Battery/Attribute Assignments';
                Image = Import;
                ToolTip = 'Retrieves the color, battery type and attribute assignments for the linked BC item from AuditData Manage.';

                trigger OnAction()
                var
                    InvRefSync: Codeunit "ADM Inventory Reference Sync";
                    FetchCompleteMsg: Label 'Color, battery type and attribute assignments fetched for item %1.', Comment = '%1 = item no.';
                begin
                    if Rec."Item No." = '' then
                        Error('This Manage product is not yet linked to a BC item. Use ''Link to BC Item'' first.');
                    InvRefSync.FetchItemAssignments(Rec."Item No.");
                    CurrPage.Update(false);
                    Message(FetchCompleteMsg, Rec."Item No.");
                end;
            }
            action(SyncAllReferenceData)
            {
                ApplicationArea = All;
                Caption = 'Sync Reference Data from Manage';
                Image = Refresh;
                ToolTip = 'Downloads all available product categories, manufacturers, suppliers, colors, battery types and attributes from AuditData Manage into BC.';

                trigger OnAction()
                var
                    InvRefSync: Codeunit "ADM Inventory Reference Sync";
                begin
                    InvRefSync.SyncAll();
                    CurrPage.Update(false);
                end;
            }
        }
        area(Navigation)
        {
            action(OpenItem)
            {
                ApplicationArea = All;
                Caption = 'Open BC Item';
                Image = Item;
                ToolTip = 'Opens the Business Central item card for the linked item.';

                trigger OnAction()
                var
                    Item: Record Item;
                begin
                    if Rec."Item No." = '' then
                        exit;
                    if Item.Get(Rec."Item No.") then
                        Page.Run(Page::"Item Card", Item);
                end;
            }
        }
        area(Promoted)
        {
            actionref(FetchManageProducts_Promoted; FetchManageProducts) { }
            actionref(LinkToBCItem_Promoted; LinkToBCItem) { }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if Rec."Item No." = '' then
            ItemLinkStyle := 'Unfavorable'
        else
            ItemLinkStyle := 'Favorable';
    end;

    var
        ItemLinkStyle: Text;
}
