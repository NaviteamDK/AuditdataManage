codeunit 50109 "ADM Item Event Subscriber"
{
    Caption = 'ADM Item Event Subscriber';

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterItemModify(var Rec: Record Item; var xRec: Record Item; RunTrigger: Boolean)
    var
        ItemMapping: Record "ADM Item Mapping";
        IntegrationSetup: Record "ADM Integration Setup";
    begin
        if Rec.IsTemporary() then
            exit;

        // Only mark for sync if item sync is enabled
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
