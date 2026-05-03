table 80322 "ADM Vendor Mapping"
{
    Caption = 'AuditData Manage Vendor Mapping';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
        }
        field(10; "Manage Manufacturer ID"; Guid)
        {
            Caption = 'Manage Manufacturer ID';
            DataClassification = CustomerContent;
            TableRelation = "ADM Manufacturer";
        }
        field(11; "Manage Supplier ID"; Guid)
        {
            Caption = 'Manage Supplier ID';
            DataClassification = CustomerContent;
            TableRelation = "ADM Supplier";
        }
    }

    keys
    {
        key(PK; "Vendor No.")
        {
            Clustered = true;
        }
        key(ManageManufacturerID; "Manage Manufacturer ID") { }
        key(ManageSupplierID; "Manage Supplier ID") { }
    }
}
