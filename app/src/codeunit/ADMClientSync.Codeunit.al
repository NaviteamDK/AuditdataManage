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
        if not ADMAPIClient.TryGet('api/v1/patients/last?hours=10000', ResponseText, ErrorText) then
            exit(false);

        ADMAPIClient.GetPaged('api/v1/patients/last?hours=10000', AllResults);

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
        FirstName: Text;
        MiddleName: Text;
        LastName: Text;
        FlatNo: Text;
        Street: Text;
    begin
        FirstName := ADMAPIClient.GetJsonText(ClientObj, 'firstName');
        MiddleName := ADMAPIClient.GetJsonText(ClientObj, 'middleName');
        LastName := ADMAPIClient.GetJsonText(ClientObj, 'lastName');

        ClientBuffer."First Name" := CopyStr(FirstName, 1, 100);
        ClientBuffer."Last Name" := CopyStr(LastName, 1, 100);

        if MiddleName <> '' then
            ClientBuffer."Full Name" := CopyStr(FirstName + ' ' + MiddleName + ' ' + LastName, 1, 200)
        else
            ClientBuffer."Full Name" := CopyStr(FirstName + ' ' + LastName, 1, 200);

        ClientBuffer.Email := CopyStr(ADMAPIClient.GetJsonText(ClientObj, 'emailAddress'), 1, 250);
        ClientBuffer.Phone := CopyStr(ADMAPIClient.GetJsonText(ClientObj, 'homePhone'), 1, 50);
        ClientBuffer.Mobile := CopyStr(ADMAPIClient.GetJsonText(ClientObj, 'mobilePhone'), 1, 50);

        ClientBuffer."Date of Birth" := ADMAPIClient.ParseDate(
            ADMAPIClient.GetJsonText(ClientObj, 'dateOfBirth'));

        // Address fields are flat (not nested)
        FlatNo := ADMAPIClient.GetJsonText(ClientObj, 'homeFlatNumber');
        Street := ADMAPIClient.GetJsonText(ClientObj, 'street');
        if FlatNo <> '' then
            ClientBuffer."Address Line 1" := CopyStr(FlatNo + ' ' + Street, 1, 100)
        else
            ClientBuffer."Address Line 1" := CopyStr(Street, 1, 100);

        ClientBuffer."Address Line 2" := CopyStr(ADMAPIClient.GetJsonText(ClientObj, 'county'), 1, 100);
        ClientBuffer.City := CopyStr(ADMAPIClient.GetJsonText(ClientObj, 'city'), 1, 50);
        ClientBuffer."Post Code" := CopyStr(ADMAPIClient.GetJsonText(ClientObj, 'postcode'), 1, 20);
        ClientBuffer.Country := CopyStr(ADMAPIClient.GetJsonText(ClientObj, 'country'), 1, 50);
    end;
}
