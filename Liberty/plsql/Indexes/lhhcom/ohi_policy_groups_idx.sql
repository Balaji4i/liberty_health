  CREATE INDEX "LHHCOM"."OHI_POLICY_GRP_POLI_FK_IDX" ON "LHHCOM"."OHI_POLICY_GROUPS" ("POLI_ID") ;
  
  CREATE INDEX "LHHCOM"."OHI_POLICY_GRP_GRAC_FK_IDX" ON "LHHCOM"."OHI_POLICY_GROUPS" ("GRAC_ID") ;
  
  CREATE INDEX "LHHCOM"."OHI_POL_GRP_START_DATE_IDX" ON "LHHCOM"."OHI_POLICY_GROUPS" ("EFFECTIVE_START_DATE" DESC) ;
  
  CREATE INDEX "LHHCOM"."OHI_POL_GRP_UPDATEDATE_IDX" ON "LHHCOM"."OHI_POLICY_GROUPS" ("LAST_UPDATE_DATETIME" DESC) ;