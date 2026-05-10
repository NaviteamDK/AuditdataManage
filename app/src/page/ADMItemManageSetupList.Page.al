page 80335 "ADM Item Manage Setup List"
{
    Caption = 'Items – AuditData Manage Setup';
    PageType = List;
    SourceTable = Item;
    UsageCategory = Administration;
    ApplicationArea = All;
    InsertAllowed = false;
    DeleteAllowed = false;
    CardPageId = "Item Card";

    layout
    {
        area(Content)
        {
            repeater(Items)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the item number.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the item description.';
                }
                field(ADMCategoryName; ADMCategoryName)
                {
                    Caption = 'Manage Category';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the AuditData Manage product category for this item. Required before the item can be synced to Manage.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ProdCat: Record "ADM Product Category";
                    begin
                        if Page.RunModal(Page::"ADM Product Category List", ProdCat) = Action::LookupOK then begin
                            Rec."ADM Manage Category ID" := ProdCat."Manage Category ID";
                            Rec.Modify(true);
                            ADMCategoryName := CopyStr(ProdCat.Name + ' (' + ProdCat.Code + ')', 1, 150);
                            Text := ADMCategoryName;
                            exit(true);
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        if ADMCategoryName = '' then begin
                            Clear(Rec."ADM Manage Category ID");
                            Rec.Modify(true);
                        end;
                    end;
                }
                field(ADMManufacturerName; ADMManufacturerName)
                {
                    Caption = 'Manage Manufacturer';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the AuditData Manage manufacturer for this item.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ManufacturerRec: Record "ADM Manufacturer";
                    begin
                        if Page.RunModal(Page::"ADM Manufacturer List", ManufacturerRec) = Action::LookupOK then begin
                            Rec."ADM Manage Manufacturer ID" := ManufacturerRec."Manage Manufacturer ID";
                            Rec.Modify(true);
                            ADMManufacturerName := ManufacturerRec.Name;
                            Text := ManufacturerRec.Name;
                            exit(true);
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        if ADMManufacturerName = '' then begin
                            Clear(Rec."ADM Manage Manufacturer ID");
                            Rec.Modify(true);
                        end;
                    end;
                }
                field(ADMSupplierName; ADMSupplierName)
                {
                    Caption = 'Manage Supplier';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the AuditData Manage supplier for this item.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        SupplierRec: Record "ADM Supplier";
                    begin
                        if Page.RunModal(Page::"ADM Supplier List", SupplierRec) = Action::LookupOK then begin
                            Rec."ADM Manage Supplier ID" := SupplierRec."Manage Supplier ID";
                            Rec.Modify(true);
                            ADMSupplierName := SupplierRec.Name;
                            Text := SupplierRec.Name;
                            exit(true);
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        if ADMSupplierName = '' then begin
                            Clear(Rec."ADM Manage Supplier ID");
                            Rec.Modify(true);
                        end;
                    end;
                }
                field(ADMHearingAidTypeName; ADMHearingAidTypeName)
                {
                    Caption = 'Manage Hearing Aid Type';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the AuditData Manage hearing aid type for this item. Required when the category is Hearing Aids.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        HearingAidTypeRec: Record "ADM Hearing Aid Type";
                    begin
                        if Page.RunModal(Page::"ADM Hearing Aid Type List", HearingAidTypeRec) = Action::LookupOK then begin
                            Rec."ADM Manage Hearing Aid Type ID" := HearingAidTypeRec."Manage Hearing Aid Type ID";
                            Rec.Modify(true);
                            ADMHearingAidTypeName := HearingAidTypeRec.Name;
                            Text := HearingAidTypeRec.Name;
                            exit(true);
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        if ADMHearingAidTypeName = '' then begin
                            Clear(Rec."ADM Manage Hearing Aid Type ID");
                            Rec.Modify(true);
                        end;
                    end;
                }
                field("ADM First VAT"; Rec."ADM First VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the first VAT rate (0–1) sent to AuditData Manage. Default is 1.';
                }
                field("ADM Second VAT"; Rec."ADM Second VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the second VAT rate (0–1) sent to AuditData Manage. Default is 0.';
                }
                field("ADM Manage Product ID"; Rec."ADM Manage Product ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the product ID in AuditData Manage linked to this item.';
                }
                field("ADM Needs Sync"; Rec."ADM Needs Sync")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this item has pending changes to be pushed to AuditData Manage.';
                }
                field("ADM Last Pushed At"; Rec."ADM Last Pushed At")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies when this item was last pushed to AuditData Manage.';
                }
                field("ADM Last Push Status"; Rec."ADM Last Push Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the result of the last push attempt to AuditData Manage.';
                }
                field("ADM Last Push Error"; Rec."ADM Last Push Error")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the error from the last failed push attempt to AuditData Manage.';
                }
            }
        }
        area(FactBoxes)
        {
            part(ADMItemColors; "ADM Item Color Subpage")
            {
                ApplicationArea = All;
                Caption = 'Manage Colors';
                SubPageLink = "Item No." = field("No.");
            }
            part(ADMItemBatteryTypes; "ADM Item Battery Type Subpage")
            {
                ApplicationArea = All;
                Caption = 'Manage Battery Types';
                SubPageLink = "Item No." = field("No.");
                SubPageView = where("Is Active" = const(true));
            }
            part(ADMItemAttributes; "ADM Item Attribute Subpage")
            {
                ApplicationArea = All;
                Caption = 'Manage Attributes';
                SubPageLink = "Item No." = field("No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SyncItem)
            {
                ApplicationArea = All;
                Caption = 'Sync Item to Manage';
                Image = Refresh;
                ToolTip = 'Pushes the selected item to AuditData Manage immediately.';

                trigger OnAction()
                var
                    ProductSync: Codeunit "ADM Product Sync";
                    SyncedMsg: Label 'Item %1 has been pushed to AuditData Manage.', Comment = '%1 = item no.';
                begin
                    ProductSync.SyncSingleItem(Rec."No.");
                    Rec.Get(Rec."No.");
                    CurrPage.Update(false);
                    Message(SyncedMsg, Rec."No.");
                end;
            }
        }
        area(Promoted)
        {
            actionref(SyncItem_Promoted; SyncItem) { }
        }
    }

    trigger OnAfterGetRecord()
    var
        ProdCat: Record "ADM Product Category";
        ManufacturerRec: Record "ADM Manufacturer";
        SupplierRec: Record "ADM Supplier";
        HearingAidTypeRec: Record "ADM Hearing Aid Type";
    begin
        Clear(ADMCategoryName);
        Clear(ADMManufacturerName);
        Clear(ADMSupplierName);
        Clear(ADMHearingAidTypeName);

        if not IsNullGuid(Rec."ADM Manage Category ID") then
            if ProdCat.Get(Rec."ADM Manage Category ID") then
                ADMCategoryName := CopyStr(ProdCat.Name + ' (' + ProdCat.Code + ')', 1, 150);

        if not IsNullGuid(Rec."ADM Manage Manufacturer ID") then
            if ManufacturerRec.Get(Rec."ADM Manage Manufacturer ID") then
                ADMManufacturerName := ManufacturerRec.Name;

        if not IsNullGuid(Rec."ADM Manage Supplier ID") then
            if SupplierRec.Get(Rec."ADM Manage Supplier ID") then
                ADMSupplierName := SupplierRec.Name;

        if not IsNullGuid(Rec."ADM Manage Hearing Aid Type ID") then
            if HearingAidTypeRec.Get(Rec."ADM Manage Hearing Aid Type ID") then
                ADMHearingAidTypeName := HearingAidTypeRec.Name;
    end;

    var
        ADMCategoryName: Text[150];
        ADMManufacturerName: Text[200];
        ADMSupplierName: Text[200];
        ADMHearingAidTypeName: Text[200];
}
