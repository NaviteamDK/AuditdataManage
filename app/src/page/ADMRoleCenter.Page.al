page 80315 "ADM Role Center"
{
    Caption = 'AuditData Manage Integration';
    PageType = RoleCenter;
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(RoleCenter)
        {
            part(ADMHeadlinePart; "ADM Headline Part")
            {
                ApplicationArea = All;
            }
            part(ADMBufferStatusPart; "ADM Buffer Status Part")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Sections)
        {
            group(Buffers)
            {
                Caption = 'Import Buffers';

                action(ClientBuffer)
                {
                    ApplicationArea = All;
                    Caption = 'Client Buffer';
                    RunObject = page "ADM Client Buffer List";
                    ToolTip = 'Review and process clients imported from AuditData Manage.';
                }
                action(FunderBuffer)
                {
                    ApplicationArea = All;
                    Caption = 'Funder Buffer';
                    RunObject = page "ADM Funder Buffer List";
                    ToolTip = 'Review and process funders imported from AuditData Manage.';
                }
                action(SaleBuffer)
                {
                    ApplicationArea = All;
                    Caption = 'Sale Buffer';
                    RunObject = page "ADM Sale Buffer List";
                    ToolTip = 'Review and promote sales imported from AuditData Manage.';
                }
            }
            group(Orders)
            {
                Caption = 'Orders';

                action(MasterOrders)
                {
                    ApplicationArea = All;
                    Caption = 'Master Orders';
                    RunObject = page "ADM Master Order List";
                    ToolTip = 'Manage master orders and configure payment splits before creating sales orders.';
                }
                action(SalesOrders)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Orders';
                    RunObject = page "Sales Order List";
                    ToolTip = 'View all Business Central sales orders including those generated from AuditData Manage.';
                }
            }
            group(ReferenceData)
            {
                Caption = 'Reference Data';

                action(Colors)
                {
                    ApplicationArea = All;
                    Caption = 'Colors';
                    RunObject = page "ADM Color List";
                    ToolTip = 'View and sync available product colors from AuditData Manage.';
                }
                action(BatteryTypes)
                {
                    ApplicationArea = All;
                    Caption = 'Battery Types';
                    RunObject = page "ADM Battery Type List";
                    ToolTip = 'View and sync available battery types from AuditData Manage.';
                }
                action(Attributes)
                {
                    ApplicationArea = All;
                    Caption = 'Attributes';
                    RunObject = page "ADM Attribute List";
                    ToolTip = 'View and sync available product attributes and their values from AuditData Manage.';
                }
            }
            group(Setup)
            {
                Caption = 'Setup';
                Image = Setup;

                action(IntegrationSetup)
                {
                    ApplicationArea = All;
                    Caption = 'Integration Setup';
                    RunObject = page "ADM Integration Setup";
                    ToolTip = 'Configure API credentials, sync intervals and customer defaults.';
                }
                action(FunderTerms)
                {
                    ApplicationArea = All;
                    Caption = 'Funder Terms';
                    RunObject = page "ADM Funder Terms List";
                    ToolTip = 'Manage global funder payment split defaults and priorities.';
                }
                action(ItemMappings)
                {
                    ApplicationArea = All;
                    Caption = 'Item Mappings';
                    RunObject = page "ADM Item Mapping List";
                    ToolTip = 'View and manage BC Item to AuditData Manage Product mappings.';
                }
                action(CustomerMappings)
                {
                    ApplicationArea = All;
                    Caption = 'Customer Mappings';
                    RunObject = page "ADM Customer Mapping List";
                    ToolTip = 'View customer mappings between AuditData Manage and Business Central.';
                }
            }
            group(History)
            {
                Caption = 'History & Log';
                Image = History;

                action(SyncLog)
                {
                    ApplicationArea = All;
                    Caption = 'Sync Log';
                    RunObject = page "ADM Sync Log List";
                    ToolTip = 'Review synchronisation history, errors and record counts.';
                }
                action(JobQueueEntries)
                {
                    ApplicationArea = All;
                    Caption = 'Job Queue Entries';
                    RunObject = page "Job Queue Entries";
                    ToolTip = 'View and manage the scheduled job queue entries for AuditData Manage synchronisation.';
                }
            }
        }
    }
}
