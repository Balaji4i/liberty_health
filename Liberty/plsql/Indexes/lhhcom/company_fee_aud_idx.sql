  CREATE INDEX "LHHCOM"."COMPANY_FEE_AUD_START_DATE_IDX" ON "LHHCOM"."COMPANY_FEE_AUDIT" ("EFFECTIVE_START_DATE" DESC) ;

  CREATE INDEX "LHHCOM"."COMPANY_FEE_AUD_UPDATEDATE_IDX" ON "LHHCOM"."COMPANY_FEE_AUDIT" ("TRANSACTION_DATETIME" DESC) ;