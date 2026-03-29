pageextension 50100 "ADM Customer Card Ext" extends "Customer Card"
{
    layout
    {
        addafter(Name)
        {
            field("ADM Customer Type"; ADMCustomerTypeRec."Customer Type")
            {
                ApplicationArea = All;
                Caption = 'Manage Customer Type';
                Editable = false;
                ToolTip = 'Specifies whether this customer is a Client or Funder in AuditData Manage.';
            }
        }
    }

    actions
    {
        addlast(Navigation)
        {
            group(AuditdataManage)
            {
                Caption = 'AuditData Manage';
                Image = Setup;

                action(FunderTerms)
                {
                    ApplicationArea = All;
                    Caption = 'Funder Terms';
                    Image = PaymentTerms;
                    Visible = IsFunder;
                    ToolTip = 'Opens the funder payment terms for this customer, used to pre-populate order splits.';

                    trigger OnAction()
                    var
                        FunderTerms: Record "ADM Funder Terms";
                    begin
                        if not FunderTerms.Get(Rec."No.") then begin
                            FunderTerms.Init();
                            FunderTerms."Customer No." := Rec."No.";
                            FunderTerms.Insert(true);
                        end;
                        Page.Run(Page::"ADM Funder Terms Card", FunderTerms);
                    end;
                }
                action(CustomerMapping)
                {
                    ApplicationArea = All;
                    Caption = 'Manage Mapping';
                    Image = LinkWeb;
                    ToolTip = 'Shows the AuditData Manage mapping record linked to this customer.';

                    trigger OnAction()
                    var
                        CustomerMapping: Record "ADM Customer Mapping";
                    begin
                        CustomerMapping.SetRange("Customer No.", Rec."No.");
                        Page.Run(Page::"ADM Customer Mapping List", CustomerMapping);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        LoadADMData();
    end;

    local procedure LoadADMData()
    begin
        if not ADMCustomerTypeRec.Get(Rec."No.") then
            Clear(ADMCustomerTypeRec);
        IsFunder := ADMCustomerTypeRec."Customer Type" = "ADM Customer Type"::Funder;
    end;

    var
        ADMCustomerTypeRec: Record "ADM Customer Mapping";
        IsFunder: Boolean;
}
