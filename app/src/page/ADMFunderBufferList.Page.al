page 80307 "ADM Funder Buffer List"
{
    Caption = 'Funder Buffer';
    PageType = List;
    SourceTable = "ADM Funder Buffer";
    SourceTableView = sorting(Status, "Imported At");
    UsageCategory = Lists;
    ApplicationArea = All;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(FunderLines)
            {
                field("Manage ID"; Rec."Manage ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the unique identifier of this funder in AuditData Manage.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyle;
                    ToolTip = 'Specifies the processing status of this funder buffer record.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the funder.';
                }
                field("Short Name"; Rec."Short Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the short name of the funder.';
                }
                field(Email; Rec.Email)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the email address of the funder.';
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the city of the funder.';
                }
                field("Is Active"; Rec."Is Active")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this funder is marked as active in AuditData Manage.';
                }
                field("BC Customer No."; Rec."BC Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Business Central customer number this funder has been processed into.';
                }
                field("Imported At"; Rec."Imported At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when this funder was imported from AuditData Manage.';
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    StyleExpr = 'Unfavorable';
                    ToolTip = 'Specifies the error message if processing this funder failed.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ProcessSelected)
            {
                ApplicationArea = All;
                Caption = 'Process Selected';
                Image = Apply;
                ToolTip = 'Processes the selected funder buffer records into Business Central customers.';

                trigger OnAction()
                var
                    FunderBuffer: Record "ADM Funder Buffer";
                    BufferProcessor: Codeunit "ADM Buffer Processor";
                begin
                    CurrPage.SetSelectionFilter(FunderBuffer);
                    if FunderBuffer.IsEmpty() then
                        Error('Please select one or more funder records to process.');
                    BufferProcessor.ProcessFunderBuffer(FunderBuffer);
                    CurrPage.Update(false);
                end;
            }
            action(ProcessAll)
            {
                ApplicationArea = All;
                Caption = 'Process All New';
                Image = ApplyEntries;
                ToolTip = 'Processes all funder buffer records with status New into Business Central customers.';

                trigger OnAction()
                var
                    FunderBuffer: Record "ADM Funder Buffer";
                    BufferProcessor: Codeunit "ADM Buffer Processor";
                begin
                    FunderBuffer.SetRange(Status, "ADM Buffer Status"::New);
                    if FunderBuffer.IsEmpty() then begin
                        Message('There are no new funder records to process.');
                        exit;
                    end;
                    BufferProcessor.ProcessFunderBuffer(FunderBuffer);
                    CurrPage.Update(false);
                end;
            }
            action(RetryErrors)
            {
                ApplicationArea = All;
                Caption = 'Retry Errors';
                Image = Restore;
                ToolTip = 'Retries processing of all funder buffer records that previously failed.';

                trigger OnAction()
                var
                    FunderBuffer: Record "ADM Funder Buffer";
                    BufferProcessor: Codeunit "ADM Buffer Processor";
                begin
                    FunderBuffer.SetRange(Status, "ADM Buffer Status"::Error);
                    if FunderBuffer.IsEmpty() then begin
                        Message('There are no error records to retry.');
                        exit;
                    end;
                    BufferProcessor.ProcessFunderBuffer(FunderBuffer);
                    CurrPage.Update(false);
                end;
            }
            action(SyncFromManage)
            {
                ApplicationArea = All;
                Caption = 'Sync from AuditData Manage';
                Image = RefreshLines;
                ToolTip = 'Fetches the latest funders from AuditData Manage and imports them into the buffer.';

                trigger OnAction()
                var
                    FunderSync: Codeunit "ADM Funder Sync";
                begin
                    FunderSync.SyncFunders();
                    CurrPage.Update(false);
                end;
            }
        }
        area(Navigation)
        {
            action(OpenCustomer)
            {
                ApplicationArea = All;
                Caption = 'Open Customer';
                Image = Customer;
                ToolTip = 'Opens the Business Central customer card for the selected funder.';

                trigger OnAction()
                var
                    Customer: Record Customer;
                begin
                    if Rec."BC Customer No." = '' then
                        Error('This funder has not yet been processed into a Business Central customer.');
                    if Customer.Get(Rec."BC Customer No.") then
                        Page.Run(Page::"Customer Card", Customer);
                end;
            }
            action(OpenFunderTerms)
            {
                ApplicationArea = All;
                Caption = 'Funder Terms';
                Image = Navigate;
                Enabled = Rec."BC Customer No." <> '';
                ToolTip = 'Opens the funder payment terms for the Business Central customer linked to this funder.';

                trigger OnAction()
                var
                    FunderTerms: Record "ADM Funder Terms";
                begin
                    if Rec."BC Customer No." = '' then
                        Error('This funder has not yet been processed into a Business Central customer.');
                    if not FunderTerms.Get(Rec."BC Customer No.") then begin
                        FunderTerms.Init();
                        FunderTerms."Customer No." := Rec."BC Customer No.";
                        FunderTerms.Insert(true);
                    end;
                    Page.Run(Page::"ADM Funder Terms Card", FunderTerms);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        case Rec.Status of
            "ADM Buffer Status"::New:
                StatusStyle := 'Standard';
            "ADM Buffer Status"::"In Progress":
                StatusStyle := 'Ambiguous';
            "ADM Buffer Status"::Processed:
                StatusStyle := 'Favorable';
            "ADM Buffer Status"::Error:
                StatusStyle := 'Unfavorable';
        end;
    end;

    var
        StatusStyle: Text;
}
