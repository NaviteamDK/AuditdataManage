codeunit 50103 "ADM Split Suggester"
{
    procedure SuggestSplitLines(var MasterOrderHeader: Record "ADM Master Order Header")
    var
        FunderTerms: Record "ADM Funder Terms";
        OrderSplitLine: Record "ADM Order Split Line";
        LineNo: Integer;
        SplitAlreadyExistsQst: Label 'Split lines already exist for this order. Do you want to replace them?';
    begin
        // Check if split lines already exist
        OrderSplitLine.SetRange("Master Order No.", MasterOrderHeader."No.");
        if not OrderSplitLine.IsEmpty() then begin
            if not Confirm(SplitAlreadyExistsQst, false) then
                exit;
            OrderSplitLine.DeleteAll();
        end;

        LineNo := 10000;

        // Add all active funders ordered by priority
        FunderTerms.SetRange(Active, true);
        FunderTerms.SetCurrentKey(Priority);
        if FunderTerms.FindSet() then
            repeat
                OrderSplitLine.Init();
                OrderSplitLine."Master Order No." := MasterOrderHeader."No.";
                OrderSplitLine."Line No." := LineNo;
                OrderSplitLine.Priority := FunderTerms.Priority;
                OrderSplitLine."Customer No." := FunderTerms."Customer No.";
                OrderSplitLine."Customer Name" := CopyStr(FunderTerms."Funder Name", 1, 100);
                OrderSplitLine."Is Client" := false;
                OrderSplitLine."Split Type" := FunderTerms."Split Type";
                if FunderTerms."Split Type" = "ADM Split Type"::"Fixed Amount" then
                    OrderSplitLine."Split Amount" := FunderTerms."Default Amount"
                else
                    OrderSplitLine."Split Percentage" := FunderTerms."Default Percentage";
                OrderSplitLine.Insert();
                LineNo += 10000;
            until FunderTerms.Next() = 0;

        // Add client as residual payer (always last)
        OrderSplitLine.Init();
        OrderSplitLine."Master Order No." := MasterOrderHeader."No.";
        OrderSplitLine."Line No." := LineNo;
        OrderSplitLine.Priority := 9999;
        OrderSplitLine."Customer No." := MasterOrderHeader."Client Customer No.";
        OrderSplitLine."Customer Name" := CopyStr(MasterOrderHeader."Client Name", 1, 100);
        OrderSplitLine."Is Client" := true;
        OrderSplitLine."Split Type" := "ADM Split Type"::"Percentage of Remaining";
        OrderSplitLine."Split Percentage" := 100;
        OrderSplitLine.Insert();

        // Calculate amounts
        RecalculateSplitAmounts(MasterOrderHeader);

        MasterOrderHeader."Split Status" := MasterOrderHeader."Split Status"::"Split Suggested";
        MasterOrderHeader.Modify();
    end;

    procedure RecalculateSplitAmounts(var MasterOrderHeader: Record "ADM Master Order Header")
    var
        OrderSplitLine: Record "ADM Order Split Line";
        RemainingAmount: Decimal;
        CalculatedAmount: Decimal;
    begin
        RemainingAmount := MasterOrderHeader."Total Amount";

        // Process in priority order
        OrderSplitLine.SetRange("Master Order No.", MasterOrderHeader."No.");
        OrderSplitLine.SetCurrentKey(Priority);
        if OrderSplitLine.FindSet(true) then
            repeat
                if OrderSplitLine."Is Client" then
                    // Client always gets the remainder
                    CalculatedAmount := RemainingAmount
                else
                    case OrderSplitLine."Split Type" of
                        "ADM Split Type"::"Fixed Amount":
                            begin
                                CalculatedAmount := OrderSplitLine."Split Amount";
                                // Cap at remaining amount
                                if CalculatedAmount > RemainingAmount then
                                    CalculatedAmount := RemainingAmount;
                            end;
                        "ADM Split Type"::"Percentage of Remaining":
                            CalculatedAmount := Round(
                                RemainingAmount * OrderSplitLine."Split Percentage" / 100, 0.01);
                    end;

                CalculatedAmount := Round(CalculatedAmount, 0.01);
                RemainingAmount := Round(RemainingAmount - CalculatedAmount, 0.01);

                OrderSplitLine."Calculated Amount" := CalculatedAmount;
                OrderSplitLine.Modify();
            until OrderSplitLine.Next() = 0;
    end;

    procedure ConfirmSplit(var MasterOrderHeader: Record "ADM Master Order Header")
    var
        OrderSplitLine: Record "ADM Order Split Line";
        SplitTotal: Decimal;
        SplitNotBalancedErr: Label 'The split total (%1) does not match the order total (%2). Please adjust the split lines before confirming.', Comment = '%1 = split total, %2 = order total';
        NoSplitLinesErr: Label 'There are no split lines to confirm. Please use Suggest Split first.';
    begin
        OrderSplitLine.SetRange("Master Order No.", MasterOrderHeader."No.");
        if OrderSplitLine.IsEmpty() then
            Error(NoSplitLinesErr);

        // Recalculate before confirming
        RecalculateSplitAmounts(MasterOrderHeader);

        SplitTotal := MasterOrderHeader.GetSplitTotal();

        if Abs(SplitTotal - MasterOrderHeader."Total Amount") > 0.01 then
            Error(SplitNotBalancedErr,
                Format(SplitTotal, 0, '<Precision,2:2><Standard Format,0>'),
                Format(MasterOrderHeader."Total Amount", 0, '<Precision,2:2><Standard Format,0>'));

        MasterOrderHeader."Split Status" := MasterOrderHeader."Split Status"::"Split Confirmed";
        MasterOrderHeader.Modify();
    end;
}
