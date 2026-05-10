codeunit 80309 "ADM Item Event Subscriber"
{
    [EventSubscriber(ObjectType::Table, Database::Item, OnAfterModifyEvent, '', false, false)]
    local procedure OnAfterItemModify(var Rec: Record Item; var xRec: Record Item; RunTrigger: Boolean)
    var
        IntegrationSetup: Record "ADM Integration Setup";
        Item: Record Item;
    begin
        if Rec.IsTemporary() then
            exit;

        // Avoid recursion — if already marked, nothing to do
        if Rec."ADM Needs Sync" then
            exit;

        if not IntegrationSetup.Get() then
            exit;
        if not IntegrationSetup."Item Sync Enabled" then
            exit;

        // Use a separate record variable to avoid modifying Rec in the after-event
        if not Item.Get(Rec."No.") then
            exit;
        Item."ADM Needs Sync" := true;
        Item.Modify();
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterItemInsert(var Rec: Record Item; RunTrigger: Boolean)
    var
        IntegrationSetup: Record "ADM Integration Setup";
        Item: Record Item;
    begin
        if Rec.IsTemporary() then
            exit;

        if not IntegrationSetup.Get() then
            exit;
        if not IntegrationSetup."Item Sync Enabled" then
            exit;

        if not Item.Get(Rec."No.") then
            exit;
        Item."ADM Needs Sync" := true;
        Item.Modify();
    end;
}
