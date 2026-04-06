codeunit 50104 "ADM Order Splitter"
{
    procedure CreateSalesOrders(var MasterOrderHeader: Record "ADM Master Order Header")
    var
        OrderSplitLine: Record "ADM Order Split Line";
        SyncLogManager: Codeunit "ADM Sync Log Manager";
        LogEntryNo: Integer;
        Processed: Integer;
        Failed: Integer;
        NotConfirmedErr: Label 'Master Order %1 is not confirmed for splitting. Please confirm the split before creating sales orders.', Comment = '%1 = Master Order No.';
        AlreadyCreatedErr: Label 'Sales orders have already been created for Master Order %1.', Comment = '%1 = Master Order No.';
    begin
        if MasterOrderHeader."Split Status" <> MasterOrderHeader."Split Status"::"Split Confirmed" then
            Error(NotConfirmedErr, MasterOrderHeader."No.");

        if MasterOrderHeader."Split Status" = MasterOrderHeader."Split Status"::"Orders Created" then
            Error(AlreadyCreatedErr, MasterOrderHeader."No.");

        LogEntryNo := SyncLogManager.StartLog("ADM Sync Direction"::Inbound, 'Sales Order Creation');

        OrderSplitLine.SetRange("Master Order No.", MasterOrderHeader."No.");
        OrderSplitLine.SetRange("Order Created", false);
        OrderSplitLine.SetCurrentKey(Priority);

        if OrderSplitLine.FindSet(true) then
            repeat
                if CreateSalesOrderForSplitLine(MasterOrderHeader, OrderSplitLine) then
                    Processed += 1
                else
                    Failed += 1;
                Commit();
            until OrderSplitLine.Next() = 0;

        if Failed = 0 then begin
            MasterOrderHeader."Split Status" := MasterOrderHeader."Split Status"::"Orders Created";
            MasterOrderHeader.Status := "ADM Buffer Status"::Processed;
            MasterOrderHeader."Orders Created At" := CurrentDateTime();
            MasterOrderHeader.Modify();
        end;

        SyncLogManager.FinishLog(LogEntryNo, Processed, Failed);

        if Failed > 0 then
            Message('%1 sales order(s) created. %2 failed. Check the split lines for details.', Processed, Failed)
        else
            Message('%1 sales order(s) created successfully.', Processed);
    end;

    local procedure CreateSalesOrderForSplitLine(MasterOrderHeader: Record "ADM Master Order Header"; var OrderSplitLine: Record "ADM Order Split Line"): Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        MasterOrderLine: Record "ADM Master Order Line";
        Customer: Record Customer;
        SalesLineNo: Integer;
    begin
        if OrderSplitLine."Customer No." = '' then
            exit(false);

        if not Customer.Get(OrderSplitLine."Customer No.") then
            exit(false);

        // Create Sales Header
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := '';
        SalesHeader.Insert(true);

        SalesHeader.Validate("Sell-to Customer No.", OrderSplitLine."Customer No.");
        SalesHeader."Order Date" := MasterOrderHeader."Order Date";
        SalesHeader."External Document No." :=
            CopyStr(MasterOrderHeader."Manage Sale No.", 1, 35);

        if MasterOrderHeader."Currency Code" <> '' then
            SalesHeader.Validate("Currency Code", MasterOrderHeader."Currency Code");

        // Store reference to master order in Posting Description
        SalesHeader."Posting Description" :=
            CopyStr('ADM Master Order: ' + MasterOrderHeader."No.", 1, 100);

        SalesHeader.Modify(true);

        // Create Sales Lines proportionally based on the split amount vs total
        SalesLineNo := 10000;
        MasterOrderLine.SetRange("Master Order No.", MasterOrderHeader."No.");
        if MasterOrderLine.FindSet() then
            repeat
                if MasterOrderLine."BC Item No." <> '' then begin
                    SalesLine.Init();
                    SalesLine."Document Type" := SalesHeader."Document Type";
                    SalesLine."Document No." := SalesHeader."No.";
                    SalesLine."Line No." := SalesLineNo;
                    SalesLine.Validate(Type, SalesLine.Type::Item);
                    SalesLine.Validate("No.", MasterOrderLine."BC Item No.");
                    SalesLine.Validate(Quantity, MasterOrderLine.Quantity);

                    // Apply proportional unit price based on split amount / total amount
                    if MasterOrderHeader."Total Amount" <> 0 then
                        SalesLine.Validate("Unit Price",
                            Round(MasterOrderLine."Unit Price" *
                                OrderSplitLine."Calculated Amount" / MasterOrderHeader."Total Amount", 0.01))
                    else
                        SalesLine.Validate("Unit Price", MasterOrderLine."Unit Price");
                    /*
                                        if MasterOrderLine."Serial No." <> '' then
                                            SalesLine."Serial No." := CopyStr(MasterOrderLine."Serial No.", 1, 50);
                    */
                    SalesLine.Insert(true);
                    SalesLineNo += 10000;
                end;
            until MasterOrderLine.Next() = 0;

        // Mark split line as done
        OrderSplitLine."BC Sales Order No." := SalesHeader."No.";
        OrderSplitLine."Order Created" := true;
        OrderSplitLine.Modify();

        exit(true);
    end;
}
