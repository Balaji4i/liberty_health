  CREATE INDEX "LHHCOM"."BR_ACCRED_BROKER_IDX" ON "LHHCOM"."BROKER_ACCREDITATION" ("BROKER_ID_NO") ; 
   
  CREATE INDEX "LHHCOM"."BR_ACCRED_TYPE_IDX" ON "LHHCOM"."BROKER_ACCREDITATION" ("ACCREDITATION_TYPE_ID_NO") ;  

  CREATE INDEX "LHHCOM"."BR_ACCRED_START_DATE_IDX" ON "LHHCOM"."BROKER_ACCREDITATION" ("EFFECTIVE_START_DATE" DESC) ;

  CREATE INDEX "LHHCOM"."BR_ACCRED_UPDATEDATE_IDX" ON "LHHCOM"."BROKER_ACCREDITATION" ("LAST_UPDATE_DATETIME" DESC) ;
  
  CREATE INDEX "LHHCOM"."BR_ACCRED_STRT_DT_IDX" ON "LHHCOM"."BROKER_ACCREDITATION" ("BROKER_ACCRED_START_DATE" DESC) ;