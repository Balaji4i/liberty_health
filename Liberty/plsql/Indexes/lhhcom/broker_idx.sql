  CREATE INDEX "LHHCOM"."BROKER_COMPANY_IDX" ON "LHHCOM"."BROKER" ("COMPANY_ID_NO") ;
  
  CREATE INDEX "LHHCOM"."BROKER_START_DATE_IDX" ON "LHHCOM"."BROKER" ("EFFECTIVE_START_DATE" DESC) ;

  CREATE INDEX "LHHCOM"."BROKER_UPDATEDATE_IDX" ON "LHHCOM"."BROKER" ("LAST_UPDATE_DATETIME" DESC) ;