  CREATE INDEX "LHHCOM"."OHI_POLBROK_AUD_START_DATE_IDX" ON "LHHCOM"."OHI_POLICY_BROKERS_AUDIT" ("EFFECTIVE_START_DATE" DESC) ;

  CREATE INDEX "LHHCOM"."OHI_POLBROK_AUD_UPDATEDATE_IDX" ON "LHHCOM"."OHI_POLICY_BROKERS_AUDIT" ("TRANSACTION_DATETIME" DESC) ;