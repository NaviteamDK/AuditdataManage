tableextension 80300 "ADM Item Ext" extends Item
{
    fields
    {
        field(80300; "ADM Manage Category ID"; Guid)
        {
            Caption = 'Manage Category ID';
            DataClassification = CustomerContent;
            TableRelation = "ADM Product Category";
        }
        field(80301; "ADM Manage Manufacturer ID"; Guid)
        {
            Caption = 'Manage Manufacturer ID';
            DataClassification = CustomerContent;
            TableRelation = "ADM Manufacturer";
        }
        field(80302; "ADM Manage Supplier ID"; Guid)
        {
            Caption = 'Manage Supplier ID';
            DataClassification = CustomerContent;
            TableRelation = "ADM Supplier";
        }
        field(80303; "ADM Manage Hearing Aid Type ID"; Guid)
        {
            Caption = 'Manage Hearing Aid Type ID';
            DataClassification = CustomerContent;
            TableRelation = "ADM Hearing Aid Type";
        }
    }
}
