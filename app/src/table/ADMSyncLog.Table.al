table 80303 "ADM Sync Log"
{
    Caption = 'AuditData Manage Sync Log';
    DataClassification = CustomerContent;
    LookupPageId = "ADM Sync Log List";
    DrillDownPageId = "ADM Sync Log List";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(10; "Started At"; DateTime)
        {
            Caption = 'Started At';
            DataClassification = CustomerContent;
        }
        field(11; "Finished At"; DateTime)
        {
            Caption = 'Finished At';
            DataClassification = CustomerContent;
        }
        field(12; Direction; Enum "ADM Sync Direction")
        {
            Caption = 'Direction';
            DataClassification = CustomerContent;
        }
        field(13; "Sync Type"; Text[50])
        {
            Caption = 'Sync Type';
            DataClassification = CustomerContent;
        }
        field(20; Status; Enum "ADM Buffer Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(21; "Records Processed"; Integer)
        {
            Caption = 'Records Processed';
            DataClassification = CustomerContent;
        }
        field(22; "Records Failed"; Integer)
        {
            Caption = 'Records Failed';
            DataClassification = CustomerContent;
        }
        field(30; "Error Message"; Text[2048])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
        }
        field(31; "Job Queue Entry ID"; Guid)
        {
            Caption = 'Job Queue Entry ID';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(StartedAt; "Started At") { }
        key(Status; Status) { }
        key(SyncType; "Sync Type") { }
    }
}
