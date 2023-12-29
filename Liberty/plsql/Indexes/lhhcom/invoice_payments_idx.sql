  CREATE INDEX "LHHCOM"."INV_PMNTS_BUS_UNIT_IDX"    ON "LHHCOM"."INVOICE_PAYMENTS" ("P_BUSINESS_UNIT"       ASC) ;
  CREATE INDEX "LHHCOM"."INV_PMNTS_SUPP_NUM_IDX"    ON "LHHCOM"."INVOICE_PAYMENTS" ("SUPPLIER_NUMBER"       ASC) ;
  CREATE INDEX "LHHCOM"."INV_PMNTS_INV_ID_IDX"      ON "LHHCOM"."INVOICE_PAYMENTS" ("INVOICE_ID"            DESC) ;
  CREATE INDEX "LHHCOM"."INV_PMNTS_VENDOR_IDX"      ON "LHHCOM"."INVOICE_PAYMENTS" ("VENDOR_SITE_CODE"      ASC) ;
  CREATE INDEX "LHHCOM"."INV_PMNTS_INV_NUM_IDX"     ON "LHHCOM"."INVOICE_PAYMENTS" ("INVOICE_NUM"           ASC) ;
  CREATE INDEX "LHHCOM"."INV_PMNTS_LINE_NUM_IDX"    ON "LHHCOM"."INVOICE_PAYMENTS" ("LINE_NUMBER"           ASC) ;
  CREATE INDEX "LHHCOM"."INV_PMNTS_LINE_TYPE_IDX"   ON "LHHCOM"."INVOICE_PAYMENTS" ("LINE_TYPE_LOOKUP_CODE" ASC) ;
  CREATE INDEX "LHHCOM"."INV_PMNTS_REV_FLAG_IDX"    ON "LHHCOM"."INVOICE_PAYMENTS" ("REVERSAL_FLAG"         ASC) ;
  CREATE INDEX "LHHCOM"."INV_PMNTS_RATE_TYPE_IDX"   ON "LHHCOM"."INVOICE_PAYMENTS" ("EXCHANGE_RATE_TYPE"    ASC) ;
  CREATE INDEX "LHHCOM"."INV_PMNTS_INV_CURR_IDX"    ON "LHHCOM"."INVOICE_PAYMENTS" ("INVOICE_CURRENCY_CODE" ASC) ;
  CREATE INDEX "LHHCOM"."INV_PMNTS_PAY_CURR_IDX"    ON "LHHCOM"."INVOICE_PAYMENTS" ("PAYMENT_CURRENCY_CODE" ASC) ;
  CREATE INDEX "LHHCOM"."INV_PMNTS_ACT_DATE_IDX"    ON "LHHCOM"."INVOICE_PAYMENTS" ("DATE_ACTIONED"         DESC) ;
  CREATE INDEX "LHHCOM"."INV_PMNTS_DATE_STAMP_IDX"  ON "LHHCOM"."INVOICE_PAYMENTS" ("DATE_STAMP"            DESC) ;
  CREATE INDEX "LHHCOM"."INV_PMNTS_UPD_DATE_IDX"    ON "LHHCOM"."INVOICE_PAYMENTS" ("LAST_UPDATE_DATETIME"  DESC) ;
