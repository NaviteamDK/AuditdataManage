pageextension 80301 "ADM Navigation Menu Ext" extends "Finance Manager Role Center"
{
    actions
    {
        addlast(Sections)
        {
            group("ADM AuditDataManage")
            {
                Caption = 'AuditData Manage';
                Image = Setup;

                group("ADM ImportBuffers")
                {
                    Caption = 'Import Buffers';

                    action("ADM NavClientBuffer")
                    {
                        ApplicationArea = All;
                        Caption = 'Client Buffer';
                        RunObject = page "ADM Client Buffer List";
                        ToolTip = 'Review and process clients imported from AuditData Manage.';
                    }
                    action("ADM NavFunderBuffer")
                    {
                        ApplicationArea = All;
                        Caption = 'Funder Buffer';
                        RunObject = page "ADM Funder Buffer List";
                        ToolTip = 'Review and process funders imported from AuditData Manage.';
                    }
                    action("ADM NavSaleBuffer")
                    {
                        ApplicationArea = All;
                        Caption = 'Sale Buffer';
                        RunObject = page "ADM Sale Buffer List";
                        ToolTip = 'Review and promote sales imported from AuditData Manage.';
                    }
                }
                group("ADM NavOrders")
                {
                    Caption = 'Orders';

                    action("ADM NavMasterOrders")
                    {
                        ApplicationArea = All;
                        Caption = 'Master Orders';
                        RunObject = page "ADM Master Order List";
                        ToolTip = 'Manage master orders and payment splits before creating individual sales orders.';
                    }
                }
                group("ADM NavSetup")
                {
                    Caption = 'Setup';

                    action("ADM NavIntegrationSetup")
                    {
                        ApplicationArea = All;
                        Caption = 'Integration Setup';
                        RunObject = page "ADM Integration Setup";
                        ToolTip = 'Configure API credentials, sync intervals and customer defaults.';
                    }
                    action("ADM NavFunderTerms")
                    {
                        ApplicationArea = All;
                        Caption = 'Funder Terms';
                        RunObject = page "ADM Funder Terms List";
                        ToolTip = 'Manage global funder payment split defaults and priorities.';
                    }
                    action("ADM NavItemMappings")
                    {
                        ApplicationArea = All;
                        Caption = 'Item Mappings';
                        RunObject = page "ADM Item Mapping List";
                        ToolTip = 'View and manage BC Item to AuditData Manage Product mappings.';
                    }
                    action("ADM NavSyncLog")
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
