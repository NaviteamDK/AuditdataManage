page 50100 "ADM Integration Setup"
{
    Caption = 'AuditData Manage Integration Setup';
    PageType = Card;
    SourceTable = "ADM Integration Setup";
    UsageCategory = Administration;
    ApplicationArea = All;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            group(APIConnection)
            {
                Caption = 'API Connection';

                field("API Base URL"; Rec."API Base URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the base URL for the AuditData Manage API. Example: https://eu-prod-manageapigateway.auditdata.app/';
                }
                field("API Key"; Rec."API Key")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the API key used to authenticate with AuditData Manage.';
                }
                field("EDI Scheme"; Rec."EDI Scheme")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the EDI scheme header value required by the AuditData Manage API.';
                }
                field(ConnectionStatus; GetConnectionStatusText())
                {
                    ApplicationArea = All;
                    Caption = 'Connection Status';
                    Editable = false;
                    StyleExpr = ConnectionStatusStyle;
                    ToolTip = 'Shows whether the API connection is configured.';
                }
            }
            group(SyncSettings)
            {
                Caption = 'Synchronisation Settings';

                group(ClientGroup)
                {
                    Caption = 'Clients';
                    ShowCaption = true;

                    field("Client Sync Enabled"; Rec."Client Sync Enabled")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies whether client synchronisation from AuditData Manage is enabled.';
                    }
                    field("Client Sync Interval (Min)"; Rec."Client Sync Interval (Min)")
                    {
                        ApplicationArea = All;
                        Enabled = Rec."Client Sync Enabled";
                        ToolTip = 'Specifies how often (in minutes) clients are synchronised from AuditData Manage.';
                    }
                    field("Last Client Sync"; Rec."Last Client Sync")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Shows when clients were last synchronised from AuditData Manage.';
                    }
                }
                group(FunderGroup)
                {
                    Caption = 'Funders';
                    ShowCaption = true;

                    field("Funder Sync Enabled"; Rec."Funder Sync Enabled")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies whether funder synchronisation from AuditData Manage is enabled.';
                    }
                    field("Funder Sync Interval (Min)"; Rec."Funder Sync Interval (Min)")
                    {
                        ApplicationArea = All;
                        Enabled = Rec."Funder Sync Enabled";
                        ToolTip = 'Specifies how often (in minutes) funders are synchronised from AuditData Manage.';
                    }
                    field("Last Funder Sync"; Rec."Last Funder Sync")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Shows when funders were last synchronised from AuditData Manage.';
                    }
                }
                group(SaleGroup)
                {
                    Caption = 'Sales';
                    ShowCaption = true;

                    field("Sale Sync Enabled"; Rec."Sale Sync Enabled")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies whether sale synchronisation from AuditData Manage is enabled.';
                    }
                    field("Sale Sync Interval (Min)"; Rec."Sale Sync Interval (Min)")
                    {
                        ApplicationArea = All;
                        Enabled = Rec."Sale Sync Enabled";
                        ToolTip = 'Specifies how often (in minutes) sales are synchronised from AuditData Manage.';
                    }
                    field("Last Sale Sync"; Rec."Last Sale Sync")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Shows when sales were last synchronised from AuditData Manage.';
                    }
                }
                group(ItemGroup)
                {
                    Caption = 'Items';
                    ShowCaption = true;

                    field("Item Sync Enabled"; Rec."Item Sync Enabled")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies whether item synchronisation to AuditData Manage is enabled.';
                    }
                    field("Item Sync Interval (Min)"; Rec."Item Sync Interval (Min)")
                    {
                        ApplicationArea = All;
                        Enabled = Rec."Item Sync Enabled";
                        ToolTip = 'Specifies how often (in minutes) items are pushed to AuditData Manage.';
                    }
                    field("Last Item Sync"; Rec."Last Item Sync")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Shows when items were last pushed to AuditData Manage.';
                    }
                }
                field("Page Size"; Rec."Page Size")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how many records to retrieve per API page call. Default is 100.';
                }
            }
            group(CustomerSetup)
            {
                Caption = 'Customer Defaults';

                field("Client Customer Posting Group"; Rec."Client Customer Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Customer Posting Group assigned to customers created from AuditData Manage clients.';
                }
                field("Funder Customer Posting Group"; Rec."Funder Customer Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Customer Posting Group assigned to customers created from AuditData Manage funders.';
                }
                field("Default Customer Template"; Rec."Default Customer Template")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the configuration template used when creating new customers from AuditData Manage.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(TestConnection)
            {
                ApplicationArea = All;
                Caption = 'Test Connection';
                Image = ValidateEmailLoggingSetup;
                ToolTip = 'Tests the connection to the AuditData Manage API using the configured credentials.';

                trigger OnAction()
                var
                    ADMAPIClient: Codeunit "ADM API Client";
                begin
                    ADMAPIClient.TestConnection();
                end;
            }
            action(SetupJobQueues)
            {
                ApplicationArea = All;
                Caption = 'Setup Job Queues';
                Image = Job;
                ToolTip = 'Creates or updates all Job Queue Entries for the AuditData Manage synchronisation jobs.';

                trigger OnAction()
                var
                    ADMJobQueueManager: Codeunit "ADM Job Queue Manager";
                begin
                    ADMJobQueueManager.SetupAllJobQueues();
                    Message('Job queues have been set up successfully.');
                end;
            }
        }
        area(Navigation)
        {
            action(SyncLog)
            {
                ApplicationArea = All;
                Caption = 'Sync Log';
                Image = Log;
                RunObject = page "ADM Sync Log List";
                ToolTip = 'Opens the synchronisation log to review recent sync activity and errors.';
            }
            action(ItemMappings)
            {
                ApplicationArea = All;
                Caption = 'Item Mappings';
                Image = ItemLedger;
                RunObject = page "ADM Item Mapping List";
                ToolTip = 'Opens the item mapping list to review BC Item to AuditData Manage Product mappings.';
            }
            action(FunderTerms)
            {
                ApplicationArea = All;
                Caption = 'Funder Terms';
                Image = Navigate;
                RunObject = page "ADM Funder Terms List";
                ToolTip = 'Opens the funder terms list to manage default payment split settings for all funders.';
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetOrCreate();
    end;

    local procedure GetConnectionStatusText(): Text
    begin
        if Rec.HasValidAPIConfig() then begin
            ConnectionStatusStyle := 'Favorable';
            exit('Configured');
        end else begin
            ConnectionStatusStyle := 'Unfavorable';
            exit('Not Configured');
        end;
    end;

    var
        ConnectionStatusStyle: Text;
}
