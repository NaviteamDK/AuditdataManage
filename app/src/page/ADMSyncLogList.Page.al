page 50101 "ADM Sync Log List"
{
    Caption = 'AuditData Manage Sync Log';
    PageType = List;
    SourceTable = "ADM Sync Log";
    UsageCategory = History;
    ApplicationArea = All;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = true;
    SourceTableView = order(descending);

    layout
    {
        area(Content)
        {
            repeater(SyncLogLines)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique entry number of this sync log record.';
                }
                field("Started At"; Rec."Started At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when this sync job started.';
                }
                field("Finished At"; Rec."Finished At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when this sync job finished.';
                }
                field(Direction; Rec.Direction)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this was an inbound or outbound sync.';
                }
                field("Sync Type"; Rec."Sync Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of data that was synchronised.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyle;
                    ToolTip = 'Specifies the result status of this sync job.';
                }
                field("Records Processed"; Rec."Records Processed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how many records were successfully processed.';
                }
                field("Records Failed"; Rec."Records Failed")
                {
                    ApplicationArea = All;
                    StyleExpr = FailedStyle;
                    ToolTip = 'Specifies how many records failed during this sync job.';
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the error message if this sync job failed.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CleanupLog)
            {
                ApplicationArea = All;
                Caption = 'Cleanup Old Entries';
                Image = Delete;
                ToolTip = 'Deletes sync log entries older than 30 days.';

                trigger OnAction()
                var
                    ADMSyncLogManager: Codeunit "ADM Sync Log Manager";
                begin
                    ADMSyncLogManager.CleanupOldLogs(30);
                    Message('Old sync log entries have been deleted.');
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        case Rec.Status of
            "ADM Buffer Status"::Processed:
                StatusStyle := 'Favorable';
            "ADM Buffer Status"::Error:
                StatusStyle := 'Unfavorable';
            "ADM Buffer Status"::"In Progress":
                StatusStyle := 'Ambiguous';
            else
                StatusStyle := 'Standard';
        end;
        if Rec."Records Failed" > 0 then
            FailedStyle := 'Unfavorable'
        else
            FailedStyle := 'Standard';
    end;

    var
        StatusStyle: Text;
        FailedStyle: Text;
}
