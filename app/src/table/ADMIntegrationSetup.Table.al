table 50100 "ADM Integration Setup"
{
    Caption = 'AuditData Manage Integration Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(10; "API Base URL"; Text[250])
        {
            Caption = 'API Base URL';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "API Base URL" <> '' then
                    if not "API Base URL".EndsWith('/') then
                        "API Base URL" := CopyStr("API Base URL" + '/', 1, MaxStrLen("API Base URL"));
            end;
        }
        field(11; "API Key"; Text[250])
        {
            Caption = 'API Key';
            DataClassification = CustomerContent;
        }
        field(12; "EDI Scheme"; Text[100])
        {
            Caption = 'EDI Scheme';
            DataClassification = CustomerContent;
        }
        field(20; "Client Sync Enabled"; Boolean)
        {
            Caption = 'Client Sync Enabled';
            DataClassification = CustomerContent;
        }
        field(21; "Funder Sync Enabled"; Boolean)
        {
            Caption = 'Funder Sync Enabled';
            DataClassification = CustomerContent;
        }
        field(22; "Sale Sync Enabled"; Boolean)
        {
            Caption = 'Sale Sync Enabled';
            DataClassification = CustomerContent;
        }
        field(23; "Item Sync Enabled"; Boolean)
        {
            Caption = 'Item Sync Enabled';
            DataClassification = CustomerContent;
        }
        field(30; "Client Sync Interval (Min)"; Integer)
        {
            Caption = 'Client Sync Interval (Min)';
            DataClassification = CustomerContent;
            InitValue = 60;
            MinValue = 5;
        }
        field(31; "Funder Sync Interval (Min)"; Integer)
        {
            Caption = 'Funder Sync Interval (Min)';
            DataClassification = CustomerContent;
            InitValue = 60;
            MinValue = 5;
        }
        field(32; "Sale Sync Interval (Min)"; Integer)
        {
            Caption = 'Sale Sync Interval (Min)';
            DataClassification = CustomerContent;
            InitValue = 30;
            MinValue = 5;
        }
        field(33; "Item Sync Interval (Min)"; Integer)
        {
            Caption = 'Item Sync Interval (Min)';
            DataClassification = CustomerContent;
            InitValue = 60;
            MinValue = 5;
        }
        field(40; "Client Customer Posting Group"; Code[20])
        {
            Caption = 'Client Customer Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Customer Posting Group";
        }
        field(41; "Funder Customer Posting Group"; Code[20])
        {
            Caption = 'Funder Customer Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Customer Posting Group";
        }
        field(42; "Default Customer Template"; Code[20])
        {
            Caption = 'Default Customer Template';
            DataClassification = CustomerContent;
            TableRelation = "Config. Template Header" where("Table ID" = const(18));
        }
        field(50; "Last Client Sync"; DateTime)
        {
            Caption = 'Last Client Sync';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(51; "Last Funder Sync"; DateTime)
        {
            Caption = 'Last Funder Sync';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(52; "Last Sale Sync"; DateTime)
        {
            Caption = 'Last Sale Sync';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(53; "Last Item Sync"; DateTime)
        {
            Caption = 'Last Item Sync';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(60; "Page Size"; Integer)
        {
            Caption = 'Page Size';
            DataClassification = CustomerContent;
            InitValue = 100;
            MinValue = 10;
            MaxValue = 500;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure GetSetup(): Record "ADM Integration Setup"
    var
        IntegrationSetup: Record "ADM Integration Setup";
        SetupNotFoundErr: Label 'AuditData Manage Integration Setup has not been configured. Please open the Integration Setup page.';
    begin
        if not IntegrationSetup.Get() then
            Error(SetupNotFoundErr);
        exit(IntegrationSetup);
    end;

    procedure GetOrCreate(): Record "ADM Integration Setup"
    var
        IntegrationSetup: Record "ADM Integration Setup";
    begin
        if not IntegrationSetup.Get() then begin
            IntegrationSetup.Init();
            IntegrationSetup.Insert();
        end;
        exit(IntegrationSetup);
    end;

    procedure HasValidAPIConfig(): Boolean
    begin
        exit(("API Base URL" <> '') and ("API Key" <> ''));
    end;
}
