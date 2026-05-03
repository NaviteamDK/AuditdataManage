pageextension 80302 "ADM Item Card Ext" extends "Item Card"
{
    layout
    {
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
    begin
        if Rec."No." = '' then
            exit;
        InvRefSync.PopulateItemColorLinks(Rec."No.");
        InvRefSync.PopulateItemBatteryTypeLinks(Rec."No.");
        InvRefSync.PopulateItemAttributeLinks(Rec."No.");
    end;
}
