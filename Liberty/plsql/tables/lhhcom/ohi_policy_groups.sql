  CREATE TABLE "LHHCOM"."OHI_POLICY_GROUPS" 
   (
    "POGR_ID"                 NUMBER(14,0)       NOT NULL ENABLE
   ,"POLI_ID"                 NUMBER(14,0)       
   ,"GRAC_ID"                 NUMBER(14,0)       
   ,"EFFECTIVE_START_DATE"    DATE               DEFAULT '01-JAN-1900' NOT NULL ENABLE
   ,"EFFECTIVE_END_DATE"      DATE               DEFAULT '31-JAN-3100' NOT NULL ENABLE
   ,"LAST_UPDATE_DATETIME"    DATE               DEFAULT sysdate NOT NULL ENABLE
   ,"USERNAME"                VARCHAR2(20 BYTE)  DEFAULT USER NOT NULL ENABLE
   ,CONSTRAINT "OHI_POLICY_GROUPS_PK"
      PRIMARY KEY ("POGR_ID")
      ENABLE
   );
   
  ALTER TABLE "LHHCOM"."OHI_POLICY_GROUPS" 
    ADD
   ( 	
 	  CONSTRAINT "OHI_POLICY_GROUPS_POLICIES_FK"
      FOREIGN KEY ("POLI_ID")
      REFERENCES "LHHCOM"."OHI_POLICIES" ("POLI_ID")
      ENABLE
   ,CONSTRAINT "OHI_POLICY_GROUPS_GROUPS_FK"
      FOREIGN KEY ("GRAC_ID")
      REFERENCES "LHHCOM"."OHI_GROUPS" ("GRAC_ID")
      ENABLE
   );
