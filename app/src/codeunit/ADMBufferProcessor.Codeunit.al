codeunit 80302 "ADM Buffer Processor"
{
    procedure ProcessClientBuffer(var ClientBuffer: Record "ADM Client Buffer")
    var
        IntegrationSetup: Record "ADM Integration Setup";
        SyncLogManager: Codeunit "ADM Sync Log Manager";
        LogEntryNo: Integer;
        Processed: Integer;
        Failed: Integer;
    begin
        IntegrationSetup := IntegrationSetup.GetSetup();
        LogEntryNo := SyncLogManager.StartLog("ADM Sync Direction"::Inbound, 'Client Buffer Processing');

        if ClientBuffer.FindSet(true) then
            repeat
                ClientBuffer.Status := "ADM Buffer Status"::"In Progress";
                ClientBuffer.Modify();
                Commit();

                if ProcessSingleClient(ClientBuffer, IntegrationSetup) then
                    Processed += 1
                else
                    Failed += 1;
            until ClientBuffer.Next() = 0;

        SyncLogManager.FinishLog(LogEntryNo, Processed, Failed);
    end;

    local procedure ProcessSingleClient(var ClientBuffer: Record "ADM Client Buffer"; IntegrationSetup: Record "ADM Integration Setup"): Boolean
    var
        Customer: Record Customer;
        CustomerMapping: Record "ADM Customer Mapping";
        CustomerNo: Code[20];
    begin
        // Check if already mapped
        CustomerNo := CustomerMapping.FindCustomerNo(ClientBuffer."Manage ID");

        if CustomerNo <> '' then
            if Customer.Get(CustomerNo) then begin
                UpdateCustomerFromClientBuffer(Customer, ClientBuffer);
                Customer.Modify(true);
                CustomerMapping.CreateOrUpdate(
                    ClientBuffer."Manage ID", CustomerNo,
                    "ADM Customer Type"::Client,
                    CopyStr(ClientBuffer.GetFullName(), 1, 100));
                ClientBuffer.MarkProcessed(CustomerNo);
                exit(true);
            end;

        // Create new customer
        Customer.Init();
        Customer."No." := '';
        Customer.Insert(true);
        UpdateCustomerFromClientBuffer(Customer, ClientBuffer);
        if IntegrationSetup."Client Customer Posting Group" <> '' then
            Customer."Customer Posting Group" := IntegrationSetup."Client Customer Posting Group";
        Customer.Modify(true);

        CustomerMapping.CreateOrUpdate(
            ClientBuffer."Manage ID", Customer."No.",
            "ADM Customer Type"::Client,
            CopyStr(ClientBuffer.GetFullName(), 1, 100));

        ClientBuffer.MarkProcessed(Customer."No.");
        exit(true);
    end;

    local procedure UpdateCustomerFromClientBuffer(var Customer: Record Customer; ClientBuffer: Record "ADM Client Buffer")
    begin
        Customer.Name := CopyStr(ClientBuffer.GetFullName(), 1, 100);
        Customer."E-Mail" := CopyStr(ClientBuffer.Email, 1, 80);
        Customer."Phone No." := CopyStr(ClientBuffer.Phone, 1, 30);
        Customer.Address := CopyStr(ClientBuffer."Address Line 1", 1, 100);
        Customer."Address 2" := CopyStr(ClientBuffer."Address Line 2", 1, 50);
        Customer.City := CopyStr(ClientBuffer.City, 1, 30);
        Customer."Post Code" := CopyStr(ClientBuffer."Post Code", 1, 20);
    end;

    procedure ProcessFunderBuffer(var FunderBuffer: Record "ADM Funder Buffer")
    var
        IntegrationSetup: Record "ADM Integration Setup";
        SyncLogManager: Codeunit "ADM Sync Log Manager";
        LogEntryNo: Integer;
        Processed: Integer;
        Failed: Integer;
    begin
        IntegrationSetup := IntegrationSetup.GetSetup();
        LogEntryNo := SyncLogManager.StartLog("ADM Sync Direction"::Inbound, 'Funder Buffer Processing');

        if FunderBuffer.FindSet(true) then
            repeat
                FunderBuffer.Status := "ADM Buffer Status"::"In Progress";
                FunderBuffer.Modify();
                Commit();

                if ProcessSingleFunder(FunderBuffer, IntegrationSetup) then
                    Processed += 1
                else
                    Failed += 1;
            until FunderBuffer.Next() = 0;

        SyncLogManager.FinishLog(LogEntryNo, Processed, Failed);
    end;

    local procedure ProcessSingleFunder(var FunderBuffer: Record "ADM Funder Buffer"; IntegrationSetup: Record "ADM Integration Setup"): Boolean
    var
        Customer: Record Customer;
        CustomerMapping: Record "ADM Customer Mapping";
        FunderTerms: Record "ADM Funder Terms";
        CustomerNo: Code[20];
    begin
        CustomerNo := CustomerMapping.FindCustomerNo(FunderBuffer."Manage ID");

        if CustomerNo <> '' then
            if Customer.Get(CustomerNo) then begin
                UpdateCustomerFromFunderBuffer(Customer, FunderBuffer);
                Customer.Modify(true);
                CustomerMapping.CreateOrUpdate(
                    FunderBuffer."Manage ID", CustomerNo,
                    "ADM Customer Type"::Funder,
                    CopyStr(FunderBuffer.Name, 1, 100));
                FunderBuffer.MarkProcessed(CustomerNo);
                exit(true);
            end;

        // Create new customer
        Customer.Init();
        Customer."No." := '';
        Customer.Insert(true);
        UpdateCustomerFromFunderBuffer(Customer, FunderBuffer);
        if IntegrationSetup."Funder Customer Posting Group" <> '' then
            Customer."Customer Posting Group" := IntegrationSetup."Funder Customer Posting Group";
        Customer.Modify(true);

        CustomerMapping.CreateOrUpdate(
            FunderBuffer."Manage ID", Customer."No.",
            "ADM Customer Type"::Funder,
            CopyStr(FunderBuffer.Name, 1, 100));

        // Auto-create Funder Terms record if it doesn't exist
        if not FunderTerms.Get(Customer."No.") then begin
            FunderTerms.Init();
            FunderTerms."Customer No." := Customer."No.";
            FunderTerms.Active := FunderBuffer."Is Active";
            FunderTerms.Insert(true);
        end;

        FunderBuffer.MarkProcessed(Customer."No.");
        exit(true);
    end;

    local procedure UpdateCustomerFromFunderBuffer(var Customer: Record Customer; FunderBuffer: Record "ADM Funder Buffer")
    begin
        Customer.Name := CopyStr(FunderBuffer.Name, 1, 100);
        Customer."E-Mail" := CopyStr(FunderBuffer.Email, 1, 80);
        Customer."Phone No." := CopyStr(FunderBuffer.Phone, 1, 30);
        Customer.Address := CopyStr(FunderBuffer."Address Line 1", 1, 100);
        Customer."Address 2" := CopyStr(FunderBuffer."Address Line 2", 1, 50);
        Customer.City := CopyStr(FunderBuffer.City, 1, 30);
        Customer."Post Code" := CopyStr(FunderBuffer."Post Code", 1, 20);
        Customer."VAT Registration No." := CopyStr(FunderBuffer."VAT Registration No.", 1, 20);
    end;

    procedure ProcessSaleBuffer(var SaleBufferHeader: Record "ADM Sale Buffer Header")
    var
        SyncLogManager: Codeunit "ADM Sync Log Manager";
        LogEntryNo: Integer;
        Processed: Integer;
        Failed: Integer;
    begin
        LogEntryNo := SyncLogManager.StartLog("ADM Sync Direction"::Inbound, 'Sale Buffer Processing');

        if SaleBufferHeader.FindSet(true) then
            repeat
                SaleBufferHeader.Status := "ADM Buffer Status"::"In Progress";
                SaleBufferHeader.Modify();
                Commit();

                if ProcessSingleSale(SaleBufferHeader) then
                    Processed += 1
                else
                    Failed += 1;
            until SaleBufferHeader.Next() = 0;

        SyncLogManager.FinishLog(LogEntryNo, Processed, Failed);
    end;

    local procedure ProcessSingleSale(var SaleBufferHeader: Record "ADM Sale Buffer Header"): Boolean
    var
        MasterOrderHeader: Record "ADM Master Order Header";
        MasterOrderLine: Record "ADM Master Order Line";
        SaleBufferLine: Record "ADM Sale Buffer Line";
        SplitSuggester: Codeunit "ADM Split Suggester";
        LineNo: Integer;
    begin
        // Validate client is mapped
        if SaleBufferHeader."BC Client Customer No." = '' then begin
            SaleBufferHeader.MarkError('Client has not been mapped to a BC customer. Process the client buffer first.');
            exit(false);
        end;

        // Create Master Order Header
        MasterOrderHeader.Init();
        MasterOrderHeader."No." := '';
        MasterOrderHeader.Insert(true);
        MasterOrderHeader."Manage Sale ID" := SaleBufferHeader."Manage Sale ID";
        MasterOrderHeader."Manage Sale No." := CopyStr(SaleBufferHeader."Sale No.", 1, 50);
        MasterOrderHeader."Client Customer No." := SaleBufferHeader."BC Client Customer No.";
        MasterOrderHeader."Client Name" := CopyStr(SaleBufferHeader."Client Name", 1, 100);
        MasterOrderHeader."Order Date" := SaleBufferHeader."Sale Date";
        MasterOrderHeader."Location Name" := CopyStr(SaleBufferHeader."Location Name", 1, 100);
        MasterOrderHeader."External Doc. No." := CopyStr(SaleBufferHeader."External Doc. No.", 1, 50);
        MasterOrderHeader."Total Amount" := SaleBufferHeader."Total Amount";
        MasterOrderHeader."Amount Excluding VAT" := SaleBufferHeader."Amount Excluding VAT";
        MasterOrderHeader."VAT Amount" := SaleBufferHeader."VAT Amount";
        MasterOrderHeader."Currency Code" := CopyStr(SaleBufferHeader."Currency Code", 1, 10);
        MasterOrderHeader.Notes := CopyStr(SaleBufferHeader.Notes, 1, 2048);
        MasterOrderHeader.Modify();

        // Copy Sale Buffer Lines to Master Order Lines
        SaleBufferLine.SetRange("Manage Sale ID", SaleBufferHeader."Manage Sale ID");
        LineNo := 10000;
        if SaleBufferLine.FindSet() then
            repeat
                MasterOrderLine.Init();
                MasterOrderLine."Master Order No." := MasterOrderHeader."No.";
                MasterOrderLine."Line No." := LineNo;
                MasterOrderLine."Manage Product ID" := SaleBufferLine."Manage Product ID";
                MasterOrderLine."BC Item No." := SaleBufferLine."BC Item No.";
                MasterOrderLine.Description := CopyStr(SaleBufferLine."Product Name", 1, 200);
                MasterOrderLine."Product SKU" := CopyStr(SaleBufferLine."Product SKU", 1, 100);
                MasterOrderLine."Product Category" := CopyStr(SaleBufferLine."Product Category", 1, 100);
                MasterOrderLine.Quantity := SaleBufferLine.Quantity;
                MasterOrderLine."Unit Price" := SaleBufferLine."Unit Price";
                MasterOrderLine."Discount Percentage" := SaleBufferLine."Discount Percentage";
                MasterOrderLine."Discount Amount" := SaleBufferLine."Discount Amount";
                MasterOrderLine."Line Amount" := SaleBufferLine."Line Amount";
                MasterOrderLine."VAT Amount" := SaleBufferLine."VAT Amount";
                MasterOrderLine."Serial No." := CopyStr(SaleBufferLine."Serial No.", 1, 50);
                MasterOrderLine."Is Serialized" := SaleBufferLine."Is Serialized";
                MasterOrderLine.Insert();
                LineNo += 10000;
            until SaleBufferLine.Next() = 0;

        // Auto-suggest split lines
        SplitSuggester.SuggestSplitLines(MasterOrderHeader);

        SaleBufferHeader.MarkProcessed(MasterOrderHeader."No.");
        exit(true);
    end;
}
