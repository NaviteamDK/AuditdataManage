page 80317 "ADM Buffer Status Part"
{
    Caption = 'Integration Status';
    PageType = CardPart;
    RefreshOnActivate = true;
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            cuegroup(ClientCues)
            {
                Caption = 'Clients';

                field(NewClients; NewClientCount)
                {
                    ApplicationArea = All;
                    Caption = 'New Clients';
                    DrillDownPageId = "ADM Client Buffer List";
                    StyleExpr = NewClientStyle;
                    ToolTip = 'Shows the number of client records imported from AuditData Manage that have not yet been processed into Business Central customers.';
                }
                field(ErrorClients; ErrorClientCount)
                {
                    ApplicationArea = All;
                    Caption = 'Client Errors';
                    DrillDownPageId = "ADM Client Buffer List";
                    StyleExpr = ErrorStyle;
                    ToolTip = 'Shows the number of client buffer records that encountered errors during processing.';
                }
            }
            cuegroup(FunderCues)
            {
                Caption = 'Funders';

                field(NewFunders; NewFunderCount)
                {
                    ApplicationArea = All;
                    Caption = 'New Funders';
                    DrillDownPageId = "ADM Funder Buffer List";
                    StyleExpr = NewFunderStyle;
                    ToolTip = 'Shows the number of funder records imported from AuditData Manage that have not yet been processed into Business Central customers.';
                }
                field(ErrorFunders; ErrorFunderCount)
                {
                    ApplicationArea = All;
                    Caption = 'Funder Errors';
                    DrillDownPageId = "ADM Funder Buffer List";
                    StyleExpr = ErrorStyle;
                    ToolTip = 'Shows the number of funder buffer records that encountered errors during processing.';
                }
            }
            cuegroup(SaleCues)
            {
                Caption = 'Sales';

                field(NewSales; NewSaleCount)
                {
                    ApplicationArea = All;
                    Caption = 'New Sales';
                    DrillDownPageId = "ADM Sale Buffer List";
                    StyleExpr = NewSaleStyle;
                    ToolTip = 'Shows the number of sale records imported from AuditData Manage awaiting promotion to master orders.';
                }
                field(ErrorSales; ErrorSaleCount)
                {
                    ApplicationArea = All;
                    Caption = 'Sale Errors';
                    DrillDownPageId = "ADM Sale Buffer List";
                    StyleExpr = ErrorStyle;
                    ToolTip = 'Shows the number of sale buffer records that encountered errors during processing.';
                }
            }
            cuegroup(MasterOrderCues)
            {
                Caption = 'Master Orders';

                field(PendingSplit; PendingSplitCount)
                {
                    ApplicationArea = All;
                    Caption = 'Awaiting Split';
                    DrillDownPageId = "ADM Master Order List";
                    StyleExpr = PendingSplitStyle;
                    ToolTip = 'Shows the number of master orders that have not yet had their payment split confirmed.';
                }
                field(SplitConfirmed; SplitConfirmedCount)
                {
                    ApplicationArea = All;
                    Caption = 'Ready for Orders';
                    DrillDownPageId = "ADM Master Order List";
                    StyleExpr = SplitConfirmedStyle;
                    ToolTip = 'Shows the number of master orders with a confirmed split that are ready for sales order creation.';
                }
                field(OrdersCreated; OrdersCreatedCount)
                {
                    ApplicationArea = All;
                    Caption = 'Orders Created';
                    DrillDownPageId = "ADM Master Order List";
                    StyleExpr = 'Favorable';
                    ToolTip = 'Shows the number of master orders for which sales orders have been created.';
                }
            }
            cuegroup(ItemCues)
            {
                Caption = 'Items';

                field(ItemsNeedingSync; ItemNeedsSyncCount)
                {
                    ApplicationArea = All;
                    Caption = 'Pending Item Sync';
                    DrillDownPageId = "ADM Item Mapping List";
                    StyleExpr = ItemSyncStyle;
                    ToolTip = 'Shows the number of Business Central items that have been modified and are pending synchronisation to AuditData Manage.';
                }
                field(ItemSyncErrors; ItemSyncErrorCount)
                {
                    ApplicationArea = All;
                    Caption = 'Item Sync Errors';
                    DrillDownPageId = "ADM Item Mapping List";
                    StyleExpr = ErrorStyle;
                    ToolTip = 'Shows the number of items whose last push to AuditData Manage failed.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        CalculateCues();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CalculateCues();
    end;

    local procedure CalculateCues()
    var
        ClientBuffer: Record "ADM Client Buffer";
        FunderBuffer: Record "ADM Funder Buffer";
        SaleBufferHeader: Record "ADM Sale Buffer Header";
        MasterOrderHeader: Record "ADM Master Order Header";
        ItemMapping: Record "ADM Item Mapping";
    begin
        // Client counts
        ClientBuffer.SetRange(Status, "ADM Buffer Status"::New);
        NewClientCount := ClientBuffer.Count();
        ClientBuffer.SetRange(Status, "ADM Buffer Status"::Error);
        ErrorClientCount := ClientBuffer.Count();

        // Funder counts
        FunderBuffer.SetRange(Status, "ADM Buffer Status"::New);
        NewFunderCount := FunderBuffer.Count();
        FunderBuffer.SetRange(Status, "ADM Buffer Status"::Error);
        ErrorFunderCount := FunderBuffer.Count();

        // Sale counts
        SaleBufferHeader.SetRange(Status, "ADM Buffer Status"::New);
        NewSaleCount := SaleBufferHeader.Count();
        SaleBufferHeader.SetRange(Status, "ADM Buffer Status"::Error);
        ErrorSaleCount := SaleBufferHeader.Count();

        // Master order counts
        MasterOrderHeader.SetRange(Status, "ADM Buffer Status"::New);
        MasterOrderHeader.SetFilter("Split Status", '%1|%2',
            MasterOrderHeader."Split Status"::"Not Split",
            MasterOrderHeader."Split Status"::"Split Suggested");
        PendingSplitCount := MasterOrderHeader.Count();

        MasterOrderHeader.SetRange("Split Status",
            MasterOrderHeader."Split Status"::"Split Confirmed");
        SplitConfirmedCount := MasterOrderHeader.Count();

        MasterOrderHeader.SetRange("Split Status",
            MasterOrderHeader."Split Status"::"Orders Created");
        OrdersCreatedCount := MasterOrderHeader.Count();

        // Item sync counts
        ItemMapping.SetRange("Needs Sync", true);
        ItemNeedsSyncCount := ItemMapping.Count();

        ItemMapping.SetRange("Needs Sync", false);
        ItemMapping.SetRange("Last Push Status", "ADM Buffer Status"::Error);
        ItemSyncErrorCount := ItemMapping.Count();

        // Set styles
        if NewClientCount > 0 then NewClientStyle := 'Ambiguous' else NewClientStyle := 'Favorable';
        if NewFunderCount > 0 then NewFunderStyle := 'Ambiguous' else NewFunderStyle := 'Favorable';
        if NewSaleCount > 0 then NewSaleStyle := 'Ambiguous' else NewSaleStyle := 'Favorable';
        if PendingSplitCount > 0 then PendingSplitStyle := 'Ambiguous' else PendingSplitStyle := 'Favorable';
        if SplitConfirmedCount > 0 then SplitConfirmedStyle := 'Favorable' else SplitConfirmedStyle := 'Standard';
        if ItemNeedsSyncCount > 0 then ItemSyncStyle := 'Ambiguous' else ItemSyncStyle := 'Favorable';
        ErrorStyle := 'Unfavorable';
    end;

    var
        NewClientCount: Integer;
        ErrorClientCount: Integer;
        NewFunderCount: Integer;
        ErrorFunderCount: Integer;
        NewSaleCount: Integer;
        ErrorSaleCount: Integer;
        PendingSplitCount: Integer;
        SplitConfirmedCount: Integer;
        OrdersCreatedCount: Integer;
        ItemNeedsSyncCount: Integer;
        ItemSyncErrorCount: Integer;
        NewClientStyle: Text;
        NewFunderStyle: Text;
        NewSaleStyle: Text;
        PendingSplitStyle: Text;
        SplitConfirmedStyle: Text;
        ItemSyncStyle: Text;
        ErrorStyle: Text;
}
