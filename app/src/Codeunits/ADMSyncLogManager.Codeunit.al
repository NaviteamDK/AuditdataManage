codeunit 50100 "ADM Sync Log Manager"
{
    Caption = 'ADM Sync Log Manager';

    procedure StartLog(Direction: Enum "ADM Sync Direction"; SyncType: Text[50]): Integer
    var
        SyncLog: Record "ADM Sync Log";
    begin
        SyncLog.Init();
        SyncLog."Started At" := CurrentDateTime();
        SyncLog.Direction := Direction;
        SyncLog."Sync Type" := SyncType;
        SyncLog.Status := "ADM Buffer Status"::"In Progress";
        SyncLog.Insert();
        exit(SyncLog."Entry No.");
    end;

    procedure FinishLog(EntryNo: Integer; RecordsProcessed: Integer; RecordsFailed: Integer)
    var
        SyncLog: Record "ADM Sync Log";
    begin
        if not SyncLog.Get(EntryNo) then
            exit;
        SyncLog."Finished At" := CurrentDateTime();
        SyncLog."Records Processed" := RecordsProcessed;
        SyncLog."Records Failed" := RecordsFailed;
        if RecordsFailed = 0 then
            SyncLog.Status := "ADM Buffer Status"::Processed
        else
            SyncLog.Status := "ADM Buffer Status"::Error;
        SyncLog.Modify();
    end;

    procedure FailLog(EntryNo: Integer; ErrorMessage: Text)
    var
        SyncLog: Record "ADM Sync Log";
    begin
        if not SyncLog.Get(EntryNo) then
            exit;
        SyncLog."Finished At" := CurrentDateTime();
        SyncLog.Status := "ADM Buffer Status"::Error;
        SyncLog."Error Message" := CopyStr(ErrorMessage, 1, 2048);
        SyncLog.Modify();
    end;

    procedure SetJobQueueEntryID(EntryNo: Integer; JobQueueEntryID: Guid)
    var
        SyncLog: Record "ADM Sync Log";
    begin
        if not SyncLog.Get(EntryNo) then
            exit;
        SyncLog."Job Queue Entry ID" := JobQueueEntryID;
        SyncLog.Modify();
    end;

    procedure CleanupOldLogs(DaysToKeep: Integer)
    var
        SyncLog: Record "ADM Sync Log";
        CutoffDate: DateTime;
    begin
        if DaysToKeep <= 0 then
            DaysToKeep := 30;
        CutoffDate := CreateDateTime(CalcDate(StrSubstNo('<-%1D>', DaysToKeep), Today()), 0T);
        SyncLog.SetFilter("Started At", '<%1', CutoffDate);
        SyncLog.DeleteAll();
    end;
}
