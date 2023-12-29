  CREATE INDEX "LHHCOM"."COUNTRY_TAXES_COUNTRY_FK_IDX"   ON "LHHCOM"."COUNTRY_TAXES" ("COUNTRY_CODE") ;
  
  CREATE INDEX "LHHCOM"."COUNTRY_TAXES_START_DATE_IDX"   ON "LHHCOM"."COUNTRY_TAXES" ("EFFECTIVE_START_DATE" DESC) ;
  
  CREATE INDEX "LHHCOM"."COUNTRY_TAXES_UPDATEDATE_IDX"   ON "LHHCOM"."COUNTRY_TAXES" ("LAST_UPDATE_DATETIME" DESC) ;