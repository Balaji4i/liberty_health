  CREATE INDEX "LHHCOM"."COMP_TAB_AUD_TP_START_DATE_IDX" ON "LHHCOM"."COMPANY_TABLE_TYPE_AUDIT" ("EFFECTIVE_START_DATE" DESC) ;

  CREATE INDEX "LHHCOM"."COMP_TAB_AUD_TP_UPDATEDATE_IDX" ON "LHHCOM"."COMPANY_TABLE_TYPE_AUDIT" ("TRANSACTION_DATETIME" DESC) ;