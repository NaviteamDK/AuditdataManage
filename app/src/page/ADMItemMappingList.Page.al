page 80303 "ADM Item Mapping List"
{
    Caption = 'AuditData Manage Item Mappings';
    PageType = List;
    SourceTable = "ADM Item Mapping";
    UsageCategory = Administration;
    ApplicationArea = All;
    InsertAllowed = false;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(MappingLines)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Business Central item number.';

                    trigger OnDrillDown()
                    var
                        Item: Record Item;
                    begin
                        if Item.Get(Rec."Item No.") then
                            Page.Run(Page::"Item Card", Item);
                    end;
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the Business Central item.';

                    trigger OnDrillDown()
                    var
                        Item: Record Item;
                    begin
                        if Item.Get(Rec."Item No.") then
                            Page.Run(Page::"Item Card", Item);
                    end;
                }
                field("Manage Product ID"; Rec."Manage Product ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the product ID in AuditData Manage linked to this item.';
                }
                field("Manage SKU"; Rec."Manage SKU")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the SKU code in AuditData Manage for this item.';
                }
                field("Needs Sync"; Rec."Needs Sync")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this item is pending synchronisation to AuditData Manage.';
                }
                field("Last Pushed At"; Rec."Last Pushed At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when this item was last pushed to AuditData Manage.';
                }
                field("Last Push Status"; Rec."Last Push Status")
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyle;
                    ToolTip = 'Specifies the result of the last push attempt to AuditData Manage.';
                }
                field("Last Push Error"; Rec."Last Push Error")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the error message from the last failed push attempt.';
                }
                field("First VAT"; Rec."First VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the first VAT rate (0–1). First VAT + Second VAT must equal 1. Default is 1.';
                }
                field("Second VAT"; Rec."Second VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the second VAT rate (0–1). First VAT + Second VAT must equal 1. Default is 0.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(MarkAllNeedsSync)
            {
                ApplicationArea = All;
                Caption = 'Mark All for Sync';
                Image = Refresh;
                ToolTip = 'Marks all items as needing synchronisation to AuditData Manage.';

                trigger OnAction()
                var
                    ItemMapping: Record "ADM Item Mapping";
                begin
                    ItemMapping.ModifyAll("Needs Sync", true);
                    Message('All items have been marked for synchronisation.');
                end;
            }
            action(AddAllBCItems)
            {
                ApplicationArea = All;
                Caption = 'Add All BC Items';
                Image = ItemJournal;
                ToolTip = 'Adds all Business Central items to the item mapping table. Items already present in the table are not duplicated.';

                trigger OnAction()
                var
                    ProductSync: Codeunit "ADM Product Sync";
                    Added: Integer;
                    Skipped: Integer;
                    ResultMsg: Label '%1 item(s) added to the mapping table. %2 item(s) were already present and skipped.', Comment = '%1 = added count, %2 = skipped count';
                begin
                    ProductSync.AddAllBCItemsToMapping(Added, Skipped);
                    CurrPage.Update(false);
                    Message(ResultMsg, Added, Skipped);
                end;
            }
            action(FetchManageProducts)
            {
                ApplicationArea = All;
                Caption = 'Fetch Products from Manage';
                Image = ImportDatabase;
                ToolTip = 'Retrieves all products from AuditData Manage and creates item mappings for any product whose SKU matches an existing BC item number.';

                trigger OnAction()
                var
                    ProductSync: Codeunit "ADM Product Sync";
                    Linked: Integer;
                    Unmatched: Integer;
                    AlreadyMapped: Integer;
                    ErrorText: Text;
                    ResultMsg: Label 'Fetch complete.\Linked: %1\Already mapped: %2\No BC item match: %3', Comment = '%1 = linked count, %2 = already mapped, %3 = unmatched';
                begin
                    if not ProductSync.FetchManageProducts(Linked, Unmatched, AlreadyMapped, ErrorText) then begin
                        Error('Failed to retrieve products from AuditData Manage:\%1', ErrorText);
                        exit;
                    end;
                    CurrPage.Update(false);
                    Message(ResultMsg, Linked, AlreadyMapped, Unmatched);
                end;
            }
            action(FetchItemAssignments)
            {
                ApplicationArea = All;
                Caption = 'Fetch Color/Battery/Attribute Assignments';
                Image = Import;
                ToolTip = 'Retrieves the color, battery type and attribute assignments for the selected item from AuditData Manage.';

                trigger OnAction()
                var
                    InvRefSync: Codeunit "ADM Inventory Reference Sync";
                    FetchCompleteMsg: Label 'Color, battery type and attribute assignments fetched for item %1.', Comment = '%1 = item no.';
                begin
                    if Rec."Item No." = '' then
                        exit;
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
            action(SyncSingleItem)
            {
                ApplicationArea = All;
                Caption = 'Sync This Item';
                Image = SyncONPayroll;
                ToolTip = 'Pushes the selected item to AuditData Manage immediately, regardless of the Needs Sync flag.';

                trigger OnAction()
                var
                    ProductSync: Codeunit "ADM Product Sync";
                begin
                    if Rec."Item No." = '' then
                        exit;
                    ProductSync.SyncSingleItem(Rec."Item No.");
                    CurrPage.Update(false);
                end;
            }
            action(OpenItem)
            {
                ApplicationArea = All;
                Caption = 'Open Item';
                Image = Item;
                ToolTip = 'Opens the Business Central item card for the selected mapping.';

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
    }

    trigger OnAfterGetRecord()
    begin
        case Rec."Last Push Status" of
            "ADM Buffer Status"::Processed:
                StatusStyle := 'Favorable';
            "ADM Buffer Status"::Error:
                StatusStyle := 'Unfavorable';
            "ADM Buffer Status"::"In Progress":
                StatusStyle := 'Ambiguous';
            else
                StatusStyle := 'Standard';
        end;
    end;

    var
        StatusStyle: Text;
}
