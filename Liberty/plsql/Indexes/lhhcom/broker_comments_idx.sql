  CREATE INDEX "LHHCOM"."BROKER_COMMENTS_FK_IDX" ON "LHHCOM"."BROKER_COMMENTS" ("BROKER_ID_NO") ;
   
  CREATE INDEX "LHHCOM"."BROKER_COMMENTS_DATE_IDX" ON "LHHCOM"."BROKER_COMMENTS" ("COMMENT_DATETIME" DESC) ; 
   
  CREATE INDEX "LHHCOM"."BROK_COMM_UPDATEDATE_IDX" ON "LHHCOM"."BROKER_COMMENTS" ("LAST_UPDATE_DATETIME" DESC) ;