pageextension 80303 "ADM Vendor Card Ext" extends "Vendor Card"
{
    layout
    {
        addlast(General)
        {
            group(ADMManageVendorGroup)
            {
                Caption = 'AuditData Manage';

                field(ADMManufacturerName; ADMManufacturerName)
                {
                    Caption = 'Manage Manufacturer';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the AuditData Manage manufacturer linked to this vendor. Used to pre-populate item mappings.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ManufacturerRec: Record "ADM Manufacturer";
                    begin
                        if Page.RunModal(Page::"ADM Manufacturer List", ManufacturerRec) = Action::LookupOK then begin
                            EnsureVendorMapping();
                            VendorMappingRec."Manage Manufacturer ID" := ManufacturerRec."Manage Manufacturer ID";
                            VendorMappingRec.Modify();
                            ADMManufacturerName := ManufacturerRec.Name;
                            Text := ManufacturerRec.Name;
                            exit(true);
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        if ADMManufacturerName = '' then begin
                            EnsureVendorMapping();
                            Clear(VendorMappingRec."Manage Manufacturer ID");
                            VendorMappingRec.Modify();
                        end;
                    end;
                }
                field(ADMSupplierName; ADMSupplierName)
                {
                    Caption = 'Manage Supplier';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the AuditData Manage supplier linked to this vendor. Used to pre-populate item mappings.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        SupplierRec: Record "ADM Supplier";
                    begin
                        if Page.RunModal(Page::"ADM Supplier List", SupplierRec) = Action::LookupOK then begin
                            EnsureVendorMapping();
                            VendorMappingRec."Manage Supplier ID" := SupplierRec."Manage Supplier ID";
                            VendorMappingRec.Modify();
                            ADMSupplierName := SupplierRec.Name;
                            Text := SupplierRec.Name;
                            exit(true);
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        if ADMSupplierName = '' then begin
                            EnsureVendorMapping();
                            Clear(VendorMappingRec."Manage Supplier ID");
                            VendorMappingRec.Modify();
                        end;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        LoadVendorMapping();
    end;

    local procedure LoadVendorMapping()
    var
        ManufacturerRec: Record "ADM Manufacturer";
        SupplierRec: Record "ADM Supplier";
    begin
        Clear(ADMManufacturerName);
        Clear(ADMSupplierName);

        if not VendorMappingRec.Get(Rec."No.") then begin
            Clear(VendorMappingRec);
            VendorMappingRec."Vendor No." := Rec."No.";
            exit;
        end;

        if not IsNullGuid(VendorMappingRec."Manage Manufacturer ID") then
            if ManufacturerRec.Get(VendorMappingRec."Manage Manufacturer ID") then
                ADMManufacturerName := ManufacturerRec.Name;

        if not IsNullGuid(VendorMappingRec."Manage Supplier ID") then
            if SupplierRec.Get(VendorMappingRec."Manage Supplier ID") then
                ADMSupplierName := SupplierRec.Name;
    end;

    local procedure EnsureVendorMapping()
    begin
        if VendorMappingRec."Vendor No." = '' then
            VendorMappingRec."Vendor No." := Rec."No.";

        if not VendorMappingRec.Find('=') then begin
            VendorMappingRec.Init();
            VendorMappingRec."Vendor No." := Rec."No.";
            VendorMappingRec.Insert();
        end;
    end;

    var
        VendorMappingRec: Record "ADM Vendor Mapping";
        ADMManufacturerName: Text[200];
        ADMSupplierName: Text[200];
}
