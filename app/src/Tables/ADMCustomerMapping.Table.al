table 50101 "ADM Customer Mapping"
{
    Caption = 'AuditData Manage Customer Mapping';
    DataClassification = CustomerContent;
    LookupPageId = "ADM Customer Mapping List";
    DrillDownPageId = "ADM Customer Mapping List";

    fields
    {
        field(1; "Manage ID"; Guid)
        {
            Caption = 'Manage ID';
            DataClassification = CustomerContent;
        }
        field(2; "Customer Type"; Enum "ADM Customer Type")
        {
            Caption = 'Customer Type';
            DataClassification = CustomerContent;
        }
        field(10; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(20; "Manage Name"; Text[100])
        {
            Caption = 'Manage Name';
            DataClassification = CustomerContent;
        }
        field(21; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = CustomerContent;
        }
        field(22; "Last Synced At"; DateTime)
        {
            Caption = 'Last Synced At';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Manage ID")
        {
            Clustered = true;
        }
        key(CustomerNo; "Customer No.") { }
        key(CustomerType; "Customer Type") { }
    }

    procedure FindByManageID(ManageID: Guid; var CustomerMapping: Record "ADM Customer Mapping"): Boolean
    begin
        exit(CustomerMapping.Get(ManageID));
    end;

    procedure FindCustomerNo(ManageID: Guid): Code[20]
    var
        CustomerMapping: Record "ADM Customer Mapping";
    begin
        if CustomerMapping.Get(ManageID) then
            exit(CustomerMapping."Customer No.");
        exit('');
    end;

    procedure CreateOrUpdate(ManageID: Guid; CustomerNo: Code[20]; CustomerType: Enum "ADM Customer Type"; ManageName: Text[100])
    var
        CustomerMapping: Record "ADM Customer Mapping";
    begin
        if CustomerMapping.Get(ManageID) then begin
            CustomerMapping."Customer No." := CustomerNo;
            CustomerMapping."Customer Type" := CustomerType;
            CustomerMapping."Manage Name" := ManageName;
            CustomerMapping."Last Synced At" := CurrentDateTime();
            CustomerMapping.Modify();
        end else begin
            CustomerMapping.Init();
            CustomerMapping."Manage ID" := ManageID;
            CustomerMapping."Customer No." := CustomerNo;
            CustomerMapping."Customer Type" := CustomerType;
            CustomerMapping."Manage Name" := ManageName;
            CustomerMapping."Created At" := CurrentDateTime();
            CustomerMapping."Last Synced At" := CurrentDateTime();
            CustomerMapping.Insert();
        end;
    end;
}
