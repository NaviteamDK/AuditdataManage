codeunit 80305 "ADM Client Sync"
{
    trigger OnRun()
    begin
        SyncClients();
    end;

    procedure SyncClients()
    var
        IntegrationSetup: Record "ADM Integration Setup";
        SyncLogManager: Codeunit "ADM Sync Log Manager";
        LogEntryNo: Integer;
        Processed: Integer;
        Failed: Integer;
        ErrorText: Text;
    begin
        IntegrationSetup := IntegrationSetup.GetSetup();
        if not IntegrationSetup."Client Sync Enabled" then
            exit;

        LogEntryNo := SyncLogManager.StartLog("ADM Sync Direction"::Inbound, 'Client Sync');

        if not TrySyncClients(Processed, Failed, ErrorText) then begin
            SyncLogManager.FailLog(LogEntryNo, ErrorText);
            exit;
        end;

        IntegrationSetup."Last Client Sync" := CurrentDateTime();
        IntegrationSetup.Modify();

        SyncLogManager.FinishLog(LogEntryNo, Processed, Failed);
    end;

    local procedure TrySyncClients(var Processed: Integer; var Failed: Integer; var ErrorText: Text): Boolean
    var
        ClientBuffer: Record "ADM Client Buffer";
        ADMAPIClient: Codeunit "ADM API Client";
        AllResults: JsonArray;
        ClientToken: JsonToken;
        ClientObj: JsonObject;
        ManageID: Guid;
        ResponseText: Text;
    begin
        // The Manage API uses "patients" as the client endpoint concept
        // based on the hearing care domain. Adjust path if the actual
        // endpoint differs once confirmed with AuditData.
        if not ADMAPIClient.TryGet('api/v1/patients/last&hours=10000', ResponseText, ErrorText) then
            exit(false);

        ADMAPIClient.GetPaged('api/v1/patients/last&hours=10000', AllResults);

        foreach ClientToken in AllResults do begin
            ClientObj := ClientToken.AsObject();
            ManageID := ADMAPIClient.GetJsonGuid(ClientObj, 'id');

            if IsNullGuid(ManageID) then begin
                Failed += 1;
                continue;
            end;

            if not ClientBuffer.Get(ManageID) then begin
                ClientBuffer.Init();
                ClientBuffer."Manage ID" := ManageID;
                ClientBuffer."Imported At" := CurrentDateTime();
                ClientBuffer.Status := "ADM Buffer Status"::New;
                ClientBuffer.Insert();
            end else
                if ClientBuffer.Status = "ADM Buffer Status"::Processed then begin
                    Processed += 1;
                    continue;
                end;

            PopulateClientBuffer(ClientBuffer, ClientObj, ADMAPIClient);
            ClientBuffer.Modify();
            Processed += 1;
        end;

        exit(true);
    end;

    local procedure PopulateClientBuffer(var ClientBuffer: Record "ADM Client Buffer"; ClientObj: JsonObject; ADMAPIClient: Codeunit "ADM API Client")
    var
        AddressObj: JsonObject;
    begin
        ClientBuffer."First Name" := CopyStr(ADMAPIClient.GetJsonText(ClientObj, 'firstName'), 1, 100);
        ClientBuffer."Last Name" := CopyStr(ADMAPIClient.GetJsonText(ClientObj, 'lastName'), 1, 100);
        ClientBuffer."Full Name" := CopyStr(
            ADMAPIClient.GetJsonText(ClientObj, 'fullName'), 1, 200);
        if ClientBuffer."Full Name" = '' then
            ClientBuffer."Full Name" := CopyStr(
                ClientBuffer."First Name" + ' ' + ClientBuffer."Last Name", 1, 200);

        ClientBuffer.Email := CopyStr(ADMAPIClient.GetJsonText(ClientObj, 'email'), 1, 250);
        ClientBuffer.Phone := CopyStr(ADMAPIClient.GetJsonText(ClientObj, 'phone'), 1, 50);
        ClientBuffer.Mobile := CopyStr(ADMAPIClient.GetJsonText(ClientObj, 'mobile'), 1, 50);

        ClientBuffer."Manage Created At" := ADMAPIClient.ParseDateTime(
            ADMAPIClient.GetJsonText(ClientObj, 'createdAt'));
        ClientBuffer."Manage Updated At" := ADMAPIClient.ParseDateTime(
            ADMAPIClient.GetJsonText(ClientObj, 'updatedAt'));

        if ADMAPIClient.GetJsonObject(ClientObj, 'address', AddressObj) then begin
            ClientBuffer."Address Line 1" := CopyStr(
                ADMAPIClient.GetJsonText(AddressObj, 'line1'), 1, 100);
            ClientBuffer."Address Line 2" := CopyStr(
                ADMAPIClient.GetJsonText(AddressObj, 'line2'), 1, 100);
            ClientBuffer.City := CopyStr(
                ADMAPIClient.GetJsonText(AddressObj, 'city'), 1, 50);
            ClientBuffer."Post Code" := CopyStr(
                ADMAPIClient.GetJsonText(AddressObj, 'postCode'), 1, 20);
            ClientBuffer.Country := CopyStr(
                ADMAPIClient.GetJsonText(AddressObj, 'country'), 1, 50);
        end;
    end;
}
