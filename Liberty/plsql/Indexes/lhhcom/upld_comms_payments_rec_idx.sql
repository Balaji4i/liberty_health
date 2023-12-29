  CREATE INDEX "LHHCOM"."UPLD_COMS_PAY_CONTRIB_DATE_IDX" ON "LHHCOM"."UPLD_COMMS_PAYMENTS_RECEIVED" ("CONTRIBUTION_DATE" DESC) ;

  CREATE INDEX "LHHCOM"."UPLD_COMS_PAY_REC_DTE_IDX" ON "LHHCOM"."UPLD_COMMS_PAYMENTS_RECEIVED" ("FINANCE_RECEIPT_DATE" DESC) ;
  
  CREATE INDEX "LHHCOM"."UPLD_COMS_PAY_INV_DTE_IDX" ON "LHHCOM"."UPLD_COMMS_PAYMENTS_RECEIVED" ("FINANCE_INVOICE_DATE" DESC) ;