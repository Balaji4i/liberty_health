  CREATE INDEX "LHHCOM"."COMPANY_CONT_TY_STRT_DATE_IDX" ON "LHHCOM"."COMPANY_CONTACT_TYPE" ("EFFECTIVE_START_DATE" DESC) ; 
   
  CREATE INDEX "LHHCOM"."COMPANY_CONT_TY_UPDATEDATE_IDX" ON "LHHCOM"."COMPANY_CONTACT_TYPE" ("LAST_UPDATE_DATETIME" DESC) ;