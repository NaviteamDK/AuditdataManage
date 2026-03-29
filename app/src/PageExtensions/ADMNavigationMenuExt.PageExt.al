pageextension 50101 "ADM Navigation Menu Ext" extends "Navigation Menu"
{
    actions
    {
        addlast(Sections)
        {
            group(AuditDataManage)
            {
                Caption = 'AuditData Manage';
                Image = Setup;

                group(ImportBuffers)
                {
                    Caption = 'Import Buffers';

                    action(NavClientBuffer)
                    {
                        ApplicationArea = All;
                        Caption = 'Client Buffer';
                        RunObject = page "ADM Client Buffer List";
                        ToolTip = 'Review and process clients imported from AuditData Manage.';
                    }
                    action(NavFunderBuffer)
                    {
                        ApplicationArea = All;
                        Caption = 'Funder Buffer';
                        RunObject = page "ADM Funder Buffer List";
                        ToolTip = 'Review and process funders imported from AuditData Manage.';
                    }
                    action(NavSaleBuffer)
                    {
                        ApplicationArea = All;
                        Caption = 'Sale Buffer';
                        RunObject = page "ADM Sale Buffer List";
                        ToolTip = 'Review and promote sales imported from AuditData Manage.';
                    }
                }
                group(NavOrders)
                {
                    Caption = 'Orders';

                    action(NavMasterOrders)
                    {
                        ApplicationArea = All;
                        Caption = 'Master Orders';
                        RunObject = page "ADM Master Order List";
                        ToolTip = 'Manage master orders and payment splits before creating individual sales orders.';
                    }
                }
                group(NavSetup)
                {
                    Caption = 'Setup';

                    action(NavIntegrationSetup)
                    {
                        ApplicationArea = All;
                        Caption = 'Integration Setup';
                        RunObject = page "ADM Integration Setup";
                        ToolTip = 'Configure API credentials, sync intervals and customer defaults.';
                    }
                    action(NavFunderTerms)
                    {
                        ApplicationArea = All;
                        Caption = 'Funder Terms';
                        RunObject = page "ADM Funder Terms List";
                        ToolTip = 'Manage global funder payment split defaults and priorities.';
                    }
                    action(NavItemMappings)
                    {
                        ApplicationArea = All;
                        Caption = 'Item Mappings';
                        RunObject = page "ADM Item Mapping List";
                        ToolTip = 'View and manage BC Item to AuditData Manage Product mappings.';
                    }
                    action(NavSyncLog)
                    {
                        ApplicationArea = All;
                        Caption = 'Sync Log';
                        RunObject = page "ADM Sync Log List";
                        ToolTip = 'Review synchronisation history and errors.';
                    }
                }
            }
        }
    }
}
