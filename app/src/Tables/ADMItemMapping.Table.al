table 50102 "ADM Item Mapping"
{
    Caption = 'AuditData Manage Item Mapping';
    DataClassification = CustomerContent;
    LookupPageId = "ADM Item Mapping List";
    DrillDownPageId = "ADM Item Mapping List";

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(10; "Manage Product ID"; Guid)
        {
            Caption = 'Manage Product ID';
            DataClassification = CustomerContent;
        }
        field(20; "Manage SKU"; Text[100])
        {
            Caption = 'Manage SKU';
            DataClassification = CustomerContent;
        }
        field(21; "Last Pushed At"; DateTime)
        {
            Caption = 'Last Pushed At';
            DataClassification = CustomerContent;
        }
        field(22; "Last Push Status"; Enum "ADM Buffer Status")
        {
            Caption = 'Last Push Status';
            DataClassification = CustomerContent;
        }
        field(23; "Last Push Error"; Text[500])
        {
            Caption = 'Last Push Error';
            DataClassification = CustomerContent;
        }
        field(24; "Needs Sync"; Boolean)
        {
            Caption = 'Needs Sync';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Item No.")
        {
            Clustered = true;
        }
        key(ManageProductID; "Manage Product ID") { }
        key(NeedsSync; "Needs Sync") { }
    }

    procedure FindByManageProductID(ManageProductID: Guid): Code[20]
    var
        ItemMapping: Record "ADM Item Mapping";
    begin
        ItemMapping.SetRange("Manage Product ID", ManageProductID);
        if ItemMapping.FindFirst() then
            exit(ItemMapping."Item No.");
        exit('');
    end;

    procedure MarkNeedsSync(ItemNo: Code[20])
    var
        ItemMapping: Record "ADM Item Mapping";
    begin
        if not ItemMapping.Get(ItemNo) then begin
            ItemMapping.Init();
            ItemMapping."Item No." := ItemNo;
            ItemMapping."Needs Sync" := true;
            ItemMapping.Insert();
        end else begin
            ItemMapping."Needs Sync" := true;
            ItemMapping.Modify();
        end;
    end;

    procedure MarkSynced(ItemNo: Code[20]; ManageProductID: Guid; ManageSKU: Text[100])
    var
        ItemMapping: Record "ADM Item Mapping";
    begin
        if not ItemMapping.Get(ItemNo) then begin
            ItemMapping.Init();
            ItemMapping."Item No." := ItemNo;
            ItemMapping.Insert();
        end;
        ItemMapping."Manage Product ID" := ManageProductID;
        ItemMapping."Manage SKU" := ManageSKU;
        ItemMapping."Last Pushed At" := CurrentDateTime();
        ItemMapping."Last Push Status" := "ADM Buffer Status"::Processed;
        ItemMapping."Last Push Error" := '';
        ItemMapping."Needs Sync" := false;
        ItemMapping.Modify();
    end;

    procedure MarkSyncError(ItemNo: Code[20]; ErrorText: Text)
    var
        ItemMapping: Record "ADM Item Mapping";
    begin
        if not ItemMapping.Get(ItemNo) then begin
            ItemMapping.Init();
            ItemMapping."Item No." := ItemNo;
            ItemMapping.Insert();
        end;
        ItemMapping."Last Pushed At" := CurrentDateTime();
        ItemMapping."Last Push Status" := "ADM Buffer Status"::Error;
        ItemMapping."Last Push Error" := CopyStr(ErrorText, 1, 500);
        ItemMapping."Needs Sync" := true;
        ItemMapping.Modify();
    end;
}
