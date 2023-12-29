  CREATE INDEX "LHHCOM"."COMPANY_REG_START_DATE_IDX" ON "LHHCOM"."COMPANY_REG" ("EFFECTIVE_START_DATE" DESC) ;

  CREATE INDEX "LHHCOM"."COMPANY_REG_UPDATEDATE_IDX" ON "LHHCOM"."COMPANY_REG" ("LAST_UPDATE_DATETIME" DESC) ;
  
  CREATE INDEX "LHHCOM"."COMPANY_REG_APP_DATE_IDX" ON "LHHCOM"."COMPANY_REG" ("APPLICATION_DATE" DESC) ;

  CREATE INDEX "LHHCOM"."COMPANY_REG_AUTH_DATE_IDX" ON "LHHCOM"."COMPANY_REG" ("AUTHORISE_DATE" DESC) ;