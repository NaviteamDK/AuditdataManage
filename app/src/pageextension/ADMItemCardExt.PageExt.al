pageextension 80302 "ADM Item Card Ext" extends "Item Card"
{
    layout
    {
        addlast(General)
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
                            EnsureItemMapping();
                            ItemMappingRec."Manage Category ID" := ProdCat."Manage Category ID";
                            ItemMappingRec.Modify();
                            ADMCategoryName := CopyStr(ProdCat.Name + ' (' + ProdCat.Code + ')', 1, 150);
                            Text := ADMCategoryName;
                            exit(true);
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        if ADMCategoryName = '' then begin
                            EnsureItemMapping();
                            Clear(ItemMappingRec."Manage Category ID");
                            ItemMappingRec.Modify();
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
                            EnsureItemMapping();
                            ItemMappingRec."Manage Manufacturer ID" := ManufacturerRec."Manage Manufacturer ID";
                            ItemMappingRec.Modify();
                            ADMManufacturerName := ManufacturerRec.Name;
                            Text := ManufacturerRec.Name;
                            exit(true);
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        if ADMManufacturerName = '' then begin
                            EnsureItemMapping();
                            Clear(ItemMappingRec."Manage Manufacturer ID");
                            ItemMappingRec.Modify();
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
                            EnsureItemMapping();
                            ItemMappingRec."Manage Supplier ID" := SupplierRec."Manage Supplier ID";
                            ItemMappingRec.Modify();
                            ADMSupplierName := SupplierRec.Name;
                            Text := SupplierRec.Name;
                            exit(true);
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        if ADMSupplierName = '' then begin
                            EnsureItemMapping();
                            Clear(ItemMappingRec."Manage Supplier ID");
                            ItemMappingRec.Modify();
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

        if ItemMappingRec.Get(Rec."No.") then begin
            if not IsNullGuid(ItemMappingRec."Manage Category ID") then
                if ProdCat.Get(ItemMappingRec."Manage Category ID") then
                    ADMCategoryName := CopyStr(ProdCat.Name + ' (' + ProdCat.Code + ')', 1, 150);

            if not IsNullGuid(ItemMappingRec."Manage Manufacturer ID") then
                if ManufacturerRec.Get(ItemMappingRec."Manage Manufacturer ID") then
                    ADMManufacturerName := ManufacturerRec.Name;

            if not IsNullGuid(ItemMappingRec."Manage Supplier ID") then
                if SupplierRec.Get(ItemMappingRec."Manage Supplier ID") then
                    ADMSupplierName := SupplierRec.Name;
        end else
            Clear(ItemMappingRec);
    end;

    local procedure EnsureItemMapping()
    begin
        if ItemMappingRec."Item No." = '' then
            ItemMappingRec."Item No." := Rec."No.";

        if not ItemMappingRec.Find('=') then begin
            ItemMappingRec.Init();
            ItemMappingRec."Item No." := Rec."No.";
            ItemMappingRec.Insert();
        end;
    end;

    var
        ItemMappingRec: Record "ADM Item Mapping";
        ADMCategoryName: Text[150];
        ADMManufacturerName: Text[200];
        ADMSupplierName: Text[200];
}

