  CREATE INDEX "LHHCOM"."OHI_POLICIES_GRAC_FK_IDX" ON "LHHCOM"."OHI_POLICIES" ("GRAC_ID") ;

  CREATE INDEX "LHHCOM"."OHI_POLICIES_UPDATEDATE_IDX" ON "LHHCOM"."OHI_POLICIES" ("LAST_UPDATE_DATETIME" DESC) ;