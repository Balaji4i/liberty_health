  CREATE INDEX "LHHCOM"."COM_CALC_TY_START_DATE_IDX" ON "LHHCOM"."COMMS_CALC_TYPE" ("EFFECTIVE_START_DATE" DESC) ;

  CREATE INDEX "LHHCOM"."COM_CALC_TY_UPDATEDATE_IDX" ON "LHHCOM"."COMMS_CALC_TYPE" ("LAST_UPDATE_DATETIME" DESC) ;