  CREATE INDEX "LHHCOM"."CO_CONTACT_AUD_START_DATE_IDX" ON "LHHCOM"."COMPANY_CONTACT_AUDIT" ("EFFECTIVE_START_DATE" DESC) ;

  CREATE INDEX "LHHCOM"."CO_CONTACT_AUD_UPDATEDATE_IDX" ON "LHHCOM"."COMPANY_CONTACT_AUDIT" ("TRANSACTION_DATETIME" DESC) ;