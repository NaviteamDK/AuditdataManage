pageextension 80302 "ADM Item Card Ext" extends "Item Card"
{
    layout
    {
        addlast(Item)
        {
            group("ADM ADMManageItemGroup")
            {
                Caption = 'AuditData Manage';

                field("ADM ADMCategoryName"; ADMCategoryName)
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
                            Rec.Modify();
                            ADMCategoryName := CopyStr(ProdCat.Name + ' (' + ProdCat.Code + ')', 1, 150);
                            Text := ADMCategoryName;
                            exit(true);
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        if ADMCategoryName = '' then begin
                            Clear(Rec."ADM Manage Category ID");
                            Rec.Modify();
                        end;
                    end;
                }
                field("ADM ADMManufacturerName"; ADMManufacturerName)
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
                            Rec.Modify();
                            ADMManufacturerName := ManufacturerRec.Name;
                            Text := ManufacturerRec.Name;
                            exit(true);
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        if ADMManufacturerName = '' then begin
                            Clear(Rec."ADM Manage Manufacturer ID");
                            Rec.Modify();
                        end;
                    end;
                }
                field("ADM ADMSupplierName"; ADMSupplierName)
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
                            Rec.Modify();
                            ADMSupplierName := SupplierRec.Name;
                            Text := SupplierRec.Name;
                            exit(true);
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        if ADMSupplierName = '' then begin
                            Clear(Rec."ADM Manage Supplier ID");
                            Rec.Modify();
                        end;
                    end;
                }
                field("ADM ADMHearingAidTypeName"; ADMHearingAidTypeName)
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
                            Rec.Modify();
                            ADMHearingAidTypeName := HearingAidTypeRec.Name;
                            Text := HearingAidTypeRec.Name;
                            exit(true);
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        if ADMHearingAidTypeName = '' then begin
                            Clear(Rec."ADM Manage Hearing Aid Type ID");
                            Rec.Modify();
                        end;
                    end;
                }
            }
        }
        addlast(factboxes)
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

    trigger OnAfterGetCurrRecord()
    var
        InvRefSync: Codeunit "ADM Inventory Reference Sync";
        ProdCat: Record "ADM Product Category";
        ManufacturerRec: Record "ADM Manufacturer";
        SupplierRec: Record "ADM Supplier";
        HearingAidTypeRec: Record "ADM Hearing Aid Type";
    begin
        if Rec."No." = '' then
            exit;

        // Populate link tables for factboxes
        InvRefSync.PopulateItemColorLinks(Rec."No.");
        InvRefSync.PopulateItemBatteryTypeLinks(Rec."No.");
        InvRefSync.PopulateItemAttributeLinks(Rec."No.");

        // Load mapping names for the AuditData Manage group
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

