codeunit 80309 "ADM Item Event Subscriber"
{
    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterItemModify(var Rec: Record Item; var xRec: Record Item; RunTrigger: Boolean)
    var
        ItemMapping: Record "ADM Item Mapping";
        IntegrationSetup: Record "ADM Integration Setup";
    begin
        if Rec.IsTemporary() then
            exit;

        // Always mark for sync when Manage-specific fields change, regardless of setup
        if (Rec."ADM Manage Category ID" <> xRec."ADM Manage Category ID") or
           (Rec."ADM Manage Manufacturer ID" <> xRec."ADM Manage Manufacturer ID") or
           (Rec."ADM Manage Supplier ID" <> xRec."ADM Manage Supplier ID") or
           (Rec."ADM Manage Hearing Aid Type ID" <> xRec."ADM Manage Hearing Aid Type ID")
        then begin
            ItemMapping.MarkNeedsSync(Rec."No.");
            exit;
        end;

        // For all other item changes, only mark for sync if item sync is enabled
        if not IntegrationSetup.Get() then
            exit;
        if not IntegrationSetup."Item Sync Enabled" then
            exit;

        ItemMapping.MarkNeedsSync(Rec."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterItemInsert(var Rec: Record Item; RunTrigger: Boolean)
    var
        ItemMapping: Record "ADM Item Mapping";
        IntegrationSetup: Record "ADM Integration Setup";
    begin
        if Rec.IsTemporary() then
            exit;

        if not IntegrationSetup.Get() then
            exit;
        if not IntegrationSetup."Item Sync Enabled" then
            exit;

        ItemMapping.MarkNeedsSync(Rec."No.");
    end;
}
