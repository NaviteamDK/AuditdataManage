codeunit 50110 "ADM Job Queue Manager"
{
    var
        ClientSyncJobDescTxt: Label 'ADM: Sync Clients from AuditData Manage', Locked = true;
        FunderSyncJobDescTxt: Label 'ADM: Sync Funders from AuditData Manage', Locked = true;
        SaleSyncJobDescTxt: Label 'ADM: Sync Sales from AuditData Manage', Locked = true;
        ItemSyncJobDescTxt: Label 'ADM: Push Items to AuditData Manage', Locked = true;

    procedure SetupAllJobQueues()
    var
        IntegrationSetup: Record "ADM Integration Setup";
    begin
        IntegrationSetup := IntegrationSetup.GetSetup();

        SetupJobQueue(
            Codeunit::"ADM Client Sync",
            ClientSyncJobDescTxt,
            IntegrationSetup."Client Sync Interval (Min)",
            IntegrationSetup."Client Sync Enabled");

        SetupJobQueue(
            Codeunit::"ADM Funder Sync",
            FunderSyncJobDescTxt,
            IntegrationSetup."Funder Sync Interval (Min)",
            IntegrationSetup."Funder Sync Enabled");

        SetupJobQueue(
            Codeunit::"ADM Sale Sync",
            SaleSyncJobDescTxt,
            IntegrationSetup."Sale Sync Interval (Min)",
            IntegrationSetup."Sale Sync Enabled");

        SetupJobQueue(
            Codeunit::"ADM Product Sync",
            ItemSyncJobDescTxt,
            IntegrationSetup."Item Sync Interval (Min)",
            IntegrationSetup."Item Sync Enabled");
    end;

    local procedure SetupJobQueue(CodeunitID: Integer; Description: Text[250]; IntervalMinutes: Integer; IsEnabled: Boolean)
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueFound: Boolean;
    begin
        // Find existing job queue entry for this codeunit
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", CodeunitID);
        JobQueueFound := JobQueueEntry.FindFirst();

        if not JobQueueFound then begin
            JobQueueEntry.Init();
            JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
            JobQueueEntry."Object ID to Run" := CodeunitID;
            JobQueueEntry.Insert(true);
        end;

        JobQueueEntry.Description := Description;
        JobQueueEntry."Run on Mondays" := true;
        JobQueueEntry."Run on Tuesdays" := true;
        JobQueueEntry."Run on Wednesdays" := true;
        JobQueueEntry."Run on Thursdays" := true;
        JobQueueEntry."Run on Fridays" := true;
        JobQueueEntry."Run on Saturdays" := false;
        JobQueueEntry."Run on Sundays" := false;
        JobQueueEntry."No. of Minutes between Runs" := IntervalMinutes;
        JobQueueEntry."Rerun Delay (sec.)" := 60;
        JobQueueEntry."Maximum No. of Attempts to Run" := 3;

        if IsEnabled then
            JobQueueEntry.Status := JobQueueEntry.Status::Ready
        else
            JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";

        JobQueueEntry.Modify(true);
    end;

    procedure EnableJobQueue(CodeunitID: Integer)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", CodeunitID);
        if JobQueueEntry.FindFirst() then begin
            JobQueueEntry.Status := JobQueueEntry.Status::Ready;
            JobQueueEntry.Modify(true);
        end;
    end;

    procedure DisableJobQueue(CodeunitID: Integer)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", CodeunitID);
        if JobQueueEntry.FindFirst() then begin
            JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
            JobQueueEntry.Modify(true);
        end;
    end;

    procedure GetJobQueueStatus(CodeunitID: Integer): Text
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", CodeunitID);
        if not JobQueueEntry.FindFirst() then
            exit('Not configured');
        exit(Format(JobQueueEntry.Status));
    end;
}
