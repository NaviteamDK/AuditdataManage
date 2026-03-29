codeunit 50106 "ADM Funder Sync"
{
    Caption = 'ADM Funder Sync';

    procedure SyncFunders()
    var
        IntegrationSetup: Record "ADM Integration Setup";
        SyncLogManager: Codeunit "ADM Sync Log Manager";
        LogEntryNo: Integer;
        Processed: Integer;
        Failed: Integer;
    begin
        IntegrationSetup := IntegrationSetup.GetSetup();
        if not IntegrationSetup."Funder Sync Enabled" then
            exit;

        LogEntryNo := SyncLogManager.StartLog("ADM Sync Direction"::Inbound, 'Funder Sync');

        if not TrySyncFunders(IntegrationSetup, Processed, Failed) then begin
            SyncLogManager.FailLog(LogEntryNo, GetLastErrorText());
            exit;
        end;

        IntegrationSetup."Last Funder Sync" := CurrentDateTime();
        IntegrationSetup.Modify();

        SyncLogManager.FinishLog(LogEntryNo, Processed, Failed);
    end;

    local procedure TrySyncFunders(IntegrationSetup: Record "ADM Integration Setup"; var Processed: Integer; var Failed: Integer): Boolean
    var
        ADMAPIClient: Codeunit "ADM API Client";
        AllResults: JsonArray;
        FunderToken: JsonToken;
        FunderObj: JsonObject;
        FunderBuffer: Record "ADM Funder Buffer";
        ManageID: Guid;
    begin
        ADMAPIClient.GetPaged('api/v2/invoicing/funders', AllResults);

        foreach FunderToken in AllResults do begin
            FunderObj := FunderToken.AsObject();
            ManageID := ADMAPIClient.GetJsonGuid(FunderObj, 'id');

            if IsNullGuid(ManageID) then begin
                Failed += 1;
                continue;
            end;

            if not FunderBuffer.Get(ManageID) then begin
                FunderBuffer.Init();
                FunderBuffer."Manage ID" := ManageID;
                FunderBuffer."Imported At" := CurrentDateTime();
                FunderBuffer.Status := "ADM Buffer Status"::New;
                FunderBuffer.Insert();
            end else begin
                if FunderBuffer.Status = "ADM Buffer Status"::Processed then begin
                    Processed += 1;
                    continue;
                end;
            end;

            PopulateFunderBuffer(FunderBuffer, FunderObj, ADMAPIClient);
            FunderBuffer.Modify();
            Processed += 1;
        end;

        exit(true);
    end;

    local procedure PopulateFunderBuffer(var FunderBuffer: Record "ADM Funder Buffer"; FunderObj: JsonObject; ADMAPIClient: Codeunit "ADM API Client")
    var
        AddressObj: JsonObject;
    begin
        FunderBuffer.Name := CopyStr(ADMAPIClient.GetJsonText(FunderObj, 'name'), 1, 100);
        FunderBuffer."Short Name" := CopyStr(ADMAPIClient.GetJsonText(FunderObj, 'shortName'), 1, 50);
        FunderBuffer.Email := CopyStr(ADMAPIClient.GetJsonText(FunderObj, 'email'), 1, 250);
        FunderBuffer.Phone := CopyStr(ADMAPIClient.GetJsonText(FunderObj, 'phone'), 1, 50);
        FunderBuffer."VAT Registration No." := CopyStr(
            ADMAPIClient.GetJsonText(FunderObj, 'vatRegistrationNumber'), 1, 30);
        FunderBuffer."Is Active" := ADMAPIClient.GetJsonBoolean(FunderObj, 'isActive');

        FunderBuffer."Manage Created At" := ADMAPIClient.ParseDateTime(
            ADMAPIClient.GetJsonText(FunderObj, 'createdAt'));
        FunderBuffer."Manage Updated At" := ADMAPIClient.ParseDateTime(
            ADMAPIClient.GetJsonText(FunderObj, 'updatedAt'));

        if ADMAPIClient.GetJsonObject(FunderObj, 'address', AddressObj) then begin
            FunderBuffer."Address Line 1" := CopyStr(
                ADMAPIClient.GetJsonText(AddressObj, 'line1'), 1, 100);
            FunderBuffer."Address Line 2" := CopyStr(
                ADMAPIClient.GetJsonText(AddressObj, 'line2'), 1, 100);
            FunderBuffer.City := CopyStr(
                ADMAPIClient.GetJsonText(AddressObj, 'city'), 1, 50);
            FunderBuffer."Post Code" := CopyStr(
                ADMAPIClient.GetJsonText(AddressObj, 'postCode'), 1, 20);
            FunderBuffer.Country := CopyStr(
                ADMAPIClient.GetJsonText(AddressObj, 'country'), 1, 50);
        end;
    end;
}
