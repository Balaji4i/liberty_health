  CREATE INDEX "LHHCOM"."OHI_POLHOLD_POLI_IDX" ON "LHHCOM"."OHI_POLICYHOLDERS" ("POLI_ID") ;
  
  CREATE INDEX "LHHCOM"."OHI_POLHOLD_START_DATE_IDX" ON "LHHCOM"."OHI_POLICYHOLDERS" ("EFFECTIVE_START_DATE" DESC) ;

  CREATE INDEX "LHHCOM"."OHI_POLHOLD_UPDATEDATE_IDX" ON "LHHCOM"."OHI_POLICYHOLDERS" ("LAST_UPDATE_DATETIME" DESC) ;