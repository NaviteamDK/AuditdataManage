codeunit 80301 "ADM API Client"
{
    var
        IntegrationSetup: Record "ADM Integration Setup";
        SetupLoaded: Boolean;
        ApiNotConfiguredErr: Label 'AuditData Manage API is not configured. Please open the Integration Setup page.';
        HttpRequestErr: Label 'API request failed. Status: %1. Response: %2', Comment = '%1 = HTTP status code, %2 = response body';
        ConnectionTestOkMsg: Label 'Connection to AuditData Manage API was successful.';
        ConnectionTestFailedMsg: Label 'Connection test failed. Status: %1\%2', Comment = '%1 = HTTP status code, %2 = error detail';

    local procedure EnsureSetup()
    begin
        if SetupLoaded then
            exit;
        IntegrationSetup := IntegrationSetup.GetSetup();
        if not IntegrationSetup.HasValidAPIConfig() then
            Error(ApiNotConfiguredErr);
        SetupLoaded := true;
    end;

    local procedure BuildUrl(RelativePath: Text): Text
    begin
        EnsureSetup();
        exit(IntegrationSetup."API Base URL" + RelativePath);
    end;

    local procedure AddAuthHeaders(var HttpRequestMessage: HttpRequestMessage)
    var
        Headers: HttpHeaders;
    begin
        EnsureSetup();
        HttpRequestMessage.GetHeaders(Headers);
        Headers.Add('ApiKey', IntegrationSetup."API Key");
        if IntegrationSetup."EDI Scheme" <> '' then
            Headers.Add('EdiScheme', IntegrationSetup."EDI Scheme");
        Headers.Add('Accept', 'application/json');
        // Headers.Add('Content-Type', 'application/json');
    end;

    procedure Get(RelativePath: Text; var ResponseText: Text): Boolean
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
    begin
        EnsureSetup();
        HttpRequestMessage.Method := 'GET';
        HttpRequestMessage.SetRequestUri(BuildUrl(RelativePath));
        AddAuthHeaders(HttpRequestMessage);

        if not HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then
            Error(HttpRequestErr, 0, 'No response from server');

        HttpResponseMessage.Content.ReadAs(ResponseText);

        if not HttpResponseMessage.IsSuccessStatusCode() then
            Error(HttpRequestErr, HttpResponseMessage.HttpStatusCode(), ResponseText);

        exit(true);
    end;

    procedure TryGet(RelativePath: Text; var ResponseText: Text; var ErrorText: Text): Boolean
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
    begin
        EnsureSetup();
        HttpRequestMessage.Method := 'GET';
        HttpRequestMessage.SetRequestUri(BuildUrl(RelativePath));
        AddAuthHeaders(HttpRequestMessage);

        if not HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            ErrorText := 'No response from server';
            exit(false);
        end;

        HttpResponseMessage.Content.ReadAs(ResponseText);

        if not HttpResponseMessage.IsSuccessStatusCode() then begin
            ErrorText := StrSubstNo(HttpRequestErr, HttpResponseMessage.HttpStatusCode(), ResponseText);
            exit(false);
        end;

        exit(true);
    end;

    procedure Post(RelativePath: Text; RequestBody: Text; var ResponseText: Text): Boolean
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        HttpContent: HttpContent;
        ContentHeaders: HttpHeaders;
    begin
        EnsureSetup();
        HttpContent.WriteFrom(RequestBody);
        HttpContent.GetHeaders(ContentHeaders);
        if ContentHeaders.Contains('Content-Type') then
            ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');

        HttpRequestMessage.Method := 'POST';
        HttpRequestMessage.SetRequestUri(BuildUrl(RelativePath));
        HttpRequestMessage.Content := HttpContent;
        AddAuthHeaders(HttpRequestMessage);

        if not HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then
            Error(HttpRequestErr, 0, 'No response from server');

        HttpResponseMessage.Content.ReadAs(ResponseText);

        if not HttpResponseMessage.IsSuccessStatusCode() then
            Error(HttpRequestErr, HttpResponseMessage.HttpStatusCode(), ResponseText);

        exit(true);
    end;

    procedure TryPost(RelativePath: Text; RequestBody: Text; var ResponseText: Text; var ErrorText: Text): Boolean
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        HttpContent: HttpContent;
        ContentHeaders: HttpHeaders;
    begin
        EnsureSetup();
        HttpContent.WriteFrom(RequestBody);
        HttpContent.GetHeaders(ContentHeaders);
        if ContentHeaders.Contains('Content-Type') then
            ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');

        HttpRequestMessage.Method := 'POST';
        HttpRequestMessage.SetRequestUri(BuildUrl(RelativePath));
        HttpRequestMessage.Content := HttpContent;
        AddAuthHeaders(HttpRequestMessage);

        if not HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            ErrorText := 'No response from server';
            exit(false);
        end;

        HttpResponseMessage.Content.ReadAs(ResponseText);

        if not HttpResponseMessage.IsSuccessStatusCode() then begin
            ErrorText := StrSubstNo(HttpRequestErr, HttpResponseMessage.HttpStatusCode(), ResponseText);
            exit(false);
        end;

        exit(true);
    end;

    procedure Put(RelativePath: Text; RequestBody: Text; var ResponseText: Text): Boolean
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        HttpContent: HttpContent;
        ContentHeaders: HttpHeaders;
    begin
        EnsureSetup();
        HttpContent.WriteFrom(RequestBody);
        HttpContent.GetHeaders(ContentHeaders);
        if ContentHeaders.Contains('Content-Type') then
            ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');

        HttpRequestMessage.Method := 'PUT';
        HttpRequestMessage.SetRequestUri(BuildUrl(RelativePath));
        HttpRequestMessage.Content := HttpContent;
        AddAuthHeaders(HttpRequestMessage);

        if not HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then
            Error(HttpRequestErr, 0, 'No response from server');

        HttpResponseMessage.Content.ReadAs(ResponseText);

        if not HttpResponseMessage.IsSuccessStatusCode() then
            Error(HttpRequestErr, HttpResponseMessage.HttpStatusCode(), ResponseText);

        exit(true);
    end;

    procedure TryPut(RelativePath: Text; RequestBody: Text; var ResponseText: Text; var ErrorText: Text): Boolean
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        HttpContent: HttpContent;
        ContentHeaders: HttpHeaders;
    begin
        EnsureSetup();
        HttpContent.WriteFrom(RequestBody);
        HttpContent.GetHeaders(ContentHeaders);
        if ContentHeaders.Contains('Content-Type') then
            ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');

        HttpRequestMessage.Method := 'PUT';
        HttpRequestMessage.SetRequestUri(BuildUrl(RelativePath));
        HttpRequestMessage.Content := HttpContent;
        AddAuthHeaders(HttpRequestMessage);

        if not HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            ErrorText := 'No response from server';
            exit(false);
        end;

        HttpResponseMessage.Content.ReadAs(ResponseText);

        if not HttpResponseMessage.IsSuccessStatusCode() then begin
            ErrorText := StrSubstNo(HttpRequestErr, HttpResponseMessage.HttpStatusCode(), ResponseText);
            exit(false);
        end;

        exit(true);
    end;

    procedure GetPaged(BaseRelativePath: Text; var AllResults: JsonArray)
    var
        ResponseText: Text;
        ResponseToken: JsonToken;
        ResponseJson: JsonObject;
        DataToken: JsonToken;
        ItemsToken: JsonToken;
        TotalPagesToken: JsonToken;
        ItemArray: JsonArray;
        Item: JsonToken;
        Page: Integer;
        TotalPages: Integer;
        PageSize: Integer;
        RelativePath: Text;
        PageSuffixAndLbl: Label '&Page=%1&PerPage=%2', Comment = '%1 = page number, %2 = page size';
        PageSuffixQuestLbl: Label '?Page=%1&PerPage=%2', Comment = '%1 = page number, %2 = page size';
    begin
        EnsureSetup();
        PageSize := IntegrationSetup."Page Size";
        if PageSize = 0 then
            PageSize := 100;
        Page := 1;
        TotalPages := 1;

        repeat
            RelativePath := BaseRelativePath;
            if RelativePath.Contains('?') then
                RelativePath += StrSubstNo(PageSuffixAndLbl, Page, PageSize)
            else
                RelativePath += StrSubstNo(PageSuffixQuestLbl, Page, PageSize);
            Get(RelativePath, ResponseText);

            ResponseToken.ReadFrom(ResponseText);

            if ResponseToken.IsArray() then begin
                // Direct top-level array — no paging info, treat as single page
                ItemArray := ResponseToken.AsArray();
                TotalPages := Page;
            end else begin
                ResponseJson := ResponseToken.AsObject();

                if ResponseJson.Get('data', DataToken) then begin
                    // Wrapped: {data: [...]} or {data: {items: [...]}}
                    if DataToken.IsArray() then
                        ItemArray := DataToken.AsArray()
                    else
                        if DataToken.AsObject().Get('items', ItemsToken) then
                            ItemArray := ItemsToken.AsArray();

                    if DataToken.AsObject().Get('totalPages', TotalPagesToken) then
                        TotalPages := TotalPagesToken.AsValue().AsInteger()
                    else
                        TotalPages := Page;
                end else
                    if ResponseJson.Get('items', ItemsToken) then begin
                        // Root-level {items: [...]}
                        ItemArray := ItemsToken.AsArray();
                        TotalPages := Page;
                    end else
                        TotalPages := Page; // Unknown structure — stop paging
            end;

            foreach Item in ItemArray do
                AllResults.Add(Item);

            Page += 1;
        until Page > TotalPages;
    end;

    procedure TestConnection()
    var
        ResponseText: Text;
        ErrorText: Text;
    begin
        EnsureSetup();
        if TryGet('api/v2/inventory/product-categories', ResponseText, ErrorText) then
            Message(ConnectionTestOkMsg)
        else
            Message(ConnectionTestFailedMsg, '', ErrorText);
    end;

    procedure ParseGuid(GuidText: Text): Guid
    var
        NullGuid: Guid;
    begin
        if GuidText = '' then
            exit(NullGuid);
        if Evaluate(NullGuid, GuidText) then
            exit(NullGuid);
        exit(NullGuid);
    end;

    procedure ParseDate(DateText: Text): Date
    var
        ResultDate: Date;
    begin
        if DateText = '' then
            exit(0D);
        if Evaluate(ResultDate, CopyStr(DateText, 1, 10)) then
            exit(ResultDate);
        exit(0D);
    end;

    procedure ParseDateTime(DateTimeText: Text): DateTime
    var
        ResultDateTime: DateTime;
    begin
        if DateTimeText = '' then
            exit(0DT);
        if Evaluate(ResultDateTime, DateTimeText) then
            exit(ResultDateTime);
        exit(0DT);
    end;

    procedure ParseDecimal(DecimalText: Text): Decimal
    var
        Result: Decimal;
    begin
        if DecimalText = '' then
            exit(0);
        if Evaluate(Result, DecimalText) then
            exit(Result);
        exit(0);
    end;

    procedure GetJsonText(JsonObj: JsonObject; FieldName: Text): Text
    var
        Token: JsonToken;
    begin
        if JsonObj.Get(FieldName, Token) then
            if not Token.AsValue().IsNull() then
                exit(Token.AsValue().AsText());
        exit('');
    end;

    procedure GetJsonDecimal(JsonObj: JsonObject; FieldName: Text): Decimal
    var
        Token: JsonToken;
    begin
        if JsonObj.Get(FieldName, Token) then
            if not Token.AsValue().IsNull() then
                exit(Token.AsValue().AsDecimal());
        exit(0);
    end;

    procedure GetJsonBoolean(JsonObj: JsonObject; FieldName: Text): Boolean
    var
        Token: JsonToken;
    begin
        if JsonObj.Get(FieldName, Token) then
            if not Token.AsValue().IsNull() then
                exit(Token.AsValue().AsBoolean());
        exit(false);
    end;

    procedure GetJsonInteger(JsonObj: JsonObject; FieldName: Text): Integer
    var
        Token: JsonToken;
    begin
        if JsonObj.Get(FieldName, Token) then
            if not Token.AsValue().IsNull() then
                exit(Token.AsValue().AsInteger());
        exit(0);
    end;

    procedure GetJsonGuid(JsonObj: JsonObject; FieldName: Text): Guid
    var
        Token: JsonToken;
        NullGuid: Guid;
    begin
        if JsonObj.Get(FieldName, Token) then
            if not Token.AsValue().IsNull() then
                exit(ParseGuid(Token.AsValue().AsText()));
        exit(NullGuid);
    end;

    procedure GetJsonObject(JsonObj: JsonObject; FieldName: Text; var ChildObj: JsonObject): Boolean
    var
        Token: JsonToken;
    begin
        if JsonObj.Get(FieldName, Token) then
            if Token.IsObject() then begin
                ChildObj := Token.AsObject();
                exit(true);
            end;
        exit(false);
    end;
}
