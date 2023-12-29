  CREATE TABLE "LHHCOM"."OHI_POLICYHOLDERS" 
   (
    "POHO_ID"                 NUMBER(14,0)       NOT NULL ENABLE
   ,"POLI_ID"                 NUMBER(14,0)       NOT NULL ENABLE
   ,"RELA_ID_PERS"            NUMBER(14,0)       NOT NULL ENABLE
   ,"TITLE"                   VARCHAR2(20 BYTE)
   ,"INITIALS"                VARCHAR2(20 BYTE)
   ,"FIRST_NAME"              VARCHAR2(30 BYTE)
   ,"SURNAME"                 VARCHAR2(100 BYTE)
   ,"EFFECTIVE_START_DATE"    DATE               DEFAULT '01-JAN-1900' NOT NULL ENABLE
   ,"EFFECTIVE_END_DATE"      DATE               DEFAULT '31-JAN-3100' NOT NULL ENABLE
   ,"LAST_UPDATE_DATETIME"    DATE               DEFAULT sysdate NOT NULL ENABLE
   ,"USERNAME"                VARCHAR2(20 BYTE)  DEFAULT 'USERNAME' NOT NULL ENABLE
   ,CONSTRAINT "OHI_POLICYHOLDERS_PK"
      PRIMARY KEY ("POHO_ID")
      ENABLE
   );
   
  ALTER TABLE "LHHCOM"."OHI_POLICYHOLDERS" 
    ADD
   ( 	
 	  CONSTRAINT "OHI_POLICYHOLDERS_POLICIES_FK" 
      FOREIGN KEY ("POLI_ID")
      REFERENCES "LHHCOM"."OHI_POLICIES" ("POLI_ID")
      ENABLE
   );
