  CREATE INDEX "LHHCOM"."OHI_GROUPS_AUD_START_DATE_IDX" ON "LHHCOM"."OHI_GROUPS_AUDIT" ("EFFECTIVE_START_DATE" DESC) ;

  CREATE INDEX "LHHCOM"."OHI_GROUPS_AUD_UPDATEDATE_IDX" ON "LHHCOM"."OHI_GROUPS_AUDIT" ("TRANSACTION_DATETIME" DESC) ;