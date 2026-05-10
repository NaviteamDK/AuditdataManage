tableextension 80300 "ADM Item Ext" extends Item
{
    fields
    {
        field(80300; "ADM Manage Category ID"; Guid)
        {
            Caption = 'Manage Category ID';
            DataClassification = CustomerContent;
            TableRelation = "ADM Product Category";
        }
        field(80301; "ADM Manage Manufacturer ID"; Guid)
        {
            Caption = 'Manage Manufacturer ID';
            DataClassification = CustomerContent;
            TableRelation = "ADM Manufacturer";
        }
        field(80302; "ADM Manage Supplier ID"; Guid)
        {
            Caption = 'Manage Supplier ID';
            DataClassification = CustomerContent;
            TableRelation = "ADM Supplier";
        }
        field(80303; "ADM Manage Hearing Aid Type ID"; Guid)
        {
            Caption = 'Manage Hearing Aid Type ID';
            DataClassification = CustomerContent;
            TableRelation = "ADM Hearing Aid Type";
        }
        field(80304; "ADM Manage Product ID"; Guid)
        {
            Caption = 'Manage Product ID';
            DataClassification = CustomerContent;
        }
        field(80305; "ADM Needs Sync"; Boolean)
        {
            Caption = 'Needs Manage Sync';
            DataClassification = CustomerContent;
        }
        field(80306; "ADM Last Pushed At"; DateTime)
        {
            Caption = 'Last Pushed to Manage';
            DataClassification = CustomerContent;
        }
        field(80307; "ADM Last Push Status"; Enum "ADM Buffer Status")
        {
            Caption = 'Last Push Status';
            DataClassification = CustomerContent;
        }
        field(80308; "ADM Last Push Error"; Text[500])
        {
            Caption = 'Last Push Error';
            DataClassification = CustomerContent;
        }
        field(80309; "ADM First VAT"; Decimal)
        {
            Caption = 'Manage First VAT';
            DataClassification = CustomerContent;
            InitValue = 1;
            MinValue = 0;
            MaxValue = 1;
            DecimalPlaces = 0 : 4;
        }
        field(80310; "ADM Second VAT"; Decimal)
        {
            Caption = 'Manage Second VAT';
            DataClassification = CustomerContent;
            InitValue = 0;
            MinValue = 0;
            MaxValue = 1;
            DecimalPlaces = 0 : 4;
        }
    }

    trigger OnInsert()
    var
        IntegrationSetup: Record "ADM Integration Setup";
    begin
        if not IntegrationSetup.Get() then
            exit;
        if not IntegrationSetup."Item Sync Enabled" then
            exit;
        Rec."ADM Needs Sync" := true;
    end;

    trigger OnModify()
    var
        IntegrationSetup: Record "ADM Integration Setup";
    begin
        if Rec."ADM Needs Sync" then
            exit;
        if not IntegrationSetup.Get() then
            exit;
        if not IntegrationSetup."Item Sync Enabled" then
            exit;
        Rec."ADM Needs Sync" := true;
    end;
}
