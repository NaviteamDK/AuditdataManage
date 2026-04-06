page 50103 "ADM Item Mapping List"
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
        }
        area(Navigation)
        {
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
