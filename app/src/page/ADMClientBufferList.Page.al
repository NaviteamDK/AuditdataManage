page 50106 "ADM Client Buffer List"
{
    Caption = 'Client Buffer';
    PageType = List;
    SourceTable = "ADM Client Buffer";
    SourceTableView = sorting(Status, "Imported At");
    UsageCategory = Lists;
    ApplicationArea = All;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(ClientLines)
            {
                field("Manage ID"; Rec."Manage ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the unique identifier of this client in AuditData Manage.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyle;
                    ToolTip = 'Specifies the processing status of this client buffer record.';
                }
                field("Full Name"; Rec.GetFullName())
                {
                    ApplicationArea = All;
                    Caption = 'Full Name';
                    ToolTip = 'Specifies the full name of the client.';
                }
                field(Email; Rec.Email)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the email address of the client.';
                }
                field(Phone; Rec.Phone)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the phone number of the client.';
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the city of the client.';
                }
                field("BC Customer No."; Rec."BC Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Business Central customer number this client has been processed into.';
                }
                field("Imported At"; Rec."Imported At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when this client was imported from AuditData Manage.';
                }
                field("Processed At"; Rec."Processed At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when this client was processed into a Business Central customer.';
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    StyleExpr = 'Unfavorable';
                    ToolTip = 'Specifies the error message if processing this client failed.';
                }
            }
        }
        area(FactBoxes)
        {
            systempart(Notes; Notes) { }
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
                ToolTip = 'Processes the selected client buffer records into Business Central customers.';

                trigger OnAction()
                var
                    ClientBuffer: Record "ADM Client Buffer";
                    BufferProcessor: Codeunit "ADM Buffer Processor";
                begin
                    CurrPage.SetSelectionFilter(ClientBuffer);
                    if ClientBuffer.IsEmpty() then
                        Error('Please select one or more client records to process.');
                    BufferProcessor.ProcessClientBuffer(ClientBuffer);
                    CurrPage.Update(false);
                end;
            }
            action(ProcessAll)
            {
                ApplicationArea = All;
                Caption = 'Process All New';
                Image = ApplyEntries;
                ToolTip = 'Processes all client buffer records with status New into Business Central customers.';

                trigger OnAction()
                var
                    ClientBuffer: Record "ADM Client Buffer";
                    BufferProcessor: Codeunit "ADM Buffer Processor";
                begin
                    ClientBuffer.SetRange(Status, "ADM Buffer Status"::New);
                    if ClientBuffer.IsEmpty() then begin
                        Message('There are no new client records to process.');
                        exit;
                    end;
                    BufferProcessor.ProcessClientBuffer(ClientBuffer);
                    CurrPage.Update(false);
                end;
            }
            action(RetryErrors)
            {
                ApplicationArea = All;
                Caption = 'Retry Errors';
                Image = Restore;
                ToolTip = 'Retries processing of all client buffer records that previously failed.';

                trigger OnAction()
                var
                    ClientBuffer: Record "ADM Client Buffer";
                    BufferProcessor: Codeunit "ADM Buffer Processor";
                begin
                    ClientBuffer.SetRange(Status, "ADM Buffer Status"::Error);
                    if ClientBuffer.IsEmpty() then begin
                        Message('There are no error records to retry.');
                        exit;
                    end;
                    BufferProcessor.ProcessClientBuffer(ClientBuffer);
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
                ToolTip = 'Opens the Business Central customer card for the selected client.';

                trigger OnAction()
                var
                    Customer: Record Customer;
                begin
                    if Rec."BC Customer No." = '' then
                        Error('This client has not yet been processed into a Business Central customer.');
                    if Customer.Get(Rec."BC Customer No.") then
                        Page.Run(Page::"Customer Card", Customer);
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
