page 50116 "ADM Headline Part"
{
    Caption = 'AuditData Manage';
    PageType = HeadlinePart;
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(Headlines)
            {
                field(NewClientsHeadline; NewClientsText)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
                field(NewFundersHeadline; NewFundersText)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
                field(NewSalesHeadline; NewSalesText)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
                field(PendingSplitsHeadline; PendingSplitsText)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        CalculateHeadlines();
    end;

    local procedure CalculateHeadlines()
    var
        ClientBuffer: Record "ADM Client Buffer";
        FunderBuffer: Record "ADM Funder Buffer";
        SaleBufferHeader: Record "ADM Sale Buffer Header";
        MasterOrderHeader: Record "ADM Master Order Header";
        NewClientsLbl: Label 'You have %1 new client(s) to process', Comment = '%1 = count';
        NewFundersLbl: Label 'You have %1 new funder(s) to process', Comment = '%1 = count';
        NewSalesLbl: Label 'You have %1 new sale(s) to review', Comment = '%1 = count';
        PendingSplitsLbl: Label '%1 master order(s) awaiting split confirmation', Comment = '%1 = count';
        AllClearLbl: Label 'All buffers are clear - great work!';
        ClientCount: Integer;
        FunderCount: Integer;
        SaleCount: Integer;
        SplitCount: Integer;
    begin
        ClientBuffer.SetRange(Status, "ADM Buffer Status"::New);
        ClientCount := ClientBuffer.Count();

        FunderBuffer.SetRange(Status, "ADM Buffer Status"::New);
        FunderCount := FunderBuffer.Count();

        SaleBufferHeader.SetRange(Status, "ADM Buffer Status"::New);
        SaleCount := SaleBufferHeader.Count();

        MasterOrderHeader.SetFilter("Split Status", '%1|%2',
            MasterOrderHeader."Split Status"::"Not Split",
            MasterOrderHeader."Split Status"::"Split Suggested");
        MasterOrderHeader.SetRange(Status, "ADM Buffer Status"::New);
        SplitCount := MasterOrderHeader.Count();

        if ClientCount > 0 then
            NewClientsText := StrSubstNo(NewClientsLbl, ClientCount)
        else
            NewClientsText := '';

        if FunderCount > 0 then
            NewFundersText := StrSubstNo(NewFundersLbl, FunderCount)
        else
            NewFundersText := '';

        if SaleCount > 0 then
            NewSalesText := StrSubstNo(NewSalesLbl, SaleCount)
        else
            NewSalesText := '';

        if SplitCount > 0 then
            PendingSplitsText := StrSubstNo(PendingSplitsLbl, SplitCount)
        else
            if (ClientCount + FunderCount + SaleCount + SplitCount) = 0 then
                PendingSplitsText := AllClearLbl
            else
                PendingSplitsText := '';
    end;

    var
        NewClientsText: Text;
        NewFundersText: Text;
        NewSalesText: Text;
        PendingSplitsText: Text;
}
