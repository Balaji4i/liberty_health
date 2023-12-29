  CREATE INDEX "LHHCOM"."OHI_POLICY_BROK_BROK_FK_IDX" ON "LHHCOM"."OHI_POLICY_BROKERS" ("BROKER_ID_NO") ;
  
  CREATE INDEX "LHHCOM"."OHI_POLICY_BROK_COMP_FK_IDX" ON "LHHCOM"."OHI_POLICY_BROKERS" ("COMPANY_ID_NO") ;
  
  CREATE INDEX "LHHCOM"."OHI_POLICY_BROK_POLI_FK_IDX" ON "LHHCOM"."OHI_POLICY_BROKERS" ("POLI_ID") ;
  
  CREATE INDEX "LHHCOM"."OHI_POL_BROK_START_DATE_IDX" ON "LHHCOM"."OHI_POLICY_BROKERS" ("EFFECTIVE_START_DATE" DESC) ;
  
  CREATE INDEX "LHHCOM"."OHI_POL_BROK_UPDATEDATE_IDX" ON "LHHCOM"."OHI_POLICY_BROKERS" ("LAST_UPDATE_DATETIME" DESC) ;