  CREATE INDEX "LHHCOM"."COMP_CNTRY_AUD_START_DATE_IDX" ON "LHHCOM"."COMPANY_COUNTRY_AUDIT" ("EFFECTIVE_START_DATE" DESC) ;

  CREATE INDEX "LHHCOM"."COMP_CNTRY_AUD_UPDATEDATE_IDX" ON "LHHCOM"."COMPANY_COUNTRY_AUDIT" ("TRANSACTION_DATETIME" DESC) ;