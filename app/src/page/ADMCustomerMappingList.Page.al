page 80302 "ADM Customer Mapping List"
{
    Caption = 'AuditData Manage Customer Mappings';
    PageType = List;
    SourceTable = "ADM Customer Mapping";
    UsageCategory = Administration;
    ApplicationArea = All;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(MappingLines)
            {
                field("Manage ID"; Rec."Manage ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier of the record in AuditData Manage.';
                }
                field("Manage Name"; Rec."Manage Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name as it appears in AuditData Manage.';
                }
                field("Customer Type"; Rec."Customer Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this mapping is for a Client or a Funder.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Business Central customer number linked to this AuditData Manage record.';
                }
                field("Created At"; Rec."Created At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when this mapping was first created.';
                }
                field("Last Synced At"; Rec."Last Synced At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when this mapping was last updated from AuditData Manage.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(OpenCustomer)
            {
                ApplicationArea = All;
                Caption = 'Open Customer';
                Image = Customer;
                ToolTip = 'Opens the linked Business Central customer card.';

                trigger OnAction()
                var
                    Customer: Record Customer;
                begin
                    if Rec."Customer No." = '' then
                        exit;
                    if Customer.Get(Rec."Customer No.") then
                        Page.Run(Page::"Customer Card", Customer);
                end;
            }
        }
    }
}
