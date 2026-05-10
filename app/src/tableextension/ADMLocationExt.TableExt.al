tableextension 80301 "ADM Location Ext" extends Location
{
    fields
    {
        field(80300; "ADM Manage Location ID"; Guid)
        {
            Caption = 'Manage Location ID';
            DataClassification = CustomerContent;
            TableRelation = "ADM Manage Location"."Manage Location ID";
        }
    }
}
