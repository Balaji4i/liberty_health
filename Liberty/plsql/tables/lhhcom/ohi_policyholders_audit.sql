  CREATE TABLE "LHHCOM"."OHI_POLICYHOLDERS_AUDIT" 
   (	
	  "TRANSACTION_DATETIME"    DATE 
	 ,"TRANSACTION_DESC"        VARCHAR2(550 BYTE) 
	 ,"TRANSACTION_USERNAME"    VARCHAR2(50 BYTE)
   ,"POHO_ID"                 NUMBER(14,0)       
   ,"POLI_ID"                 NUMBER(14,0)       
   ,"RELA_ID_PERS"            NUMBER(14,0)       
   ,"TITLE"                   VARCHAR2(20 BYTE)
   ,"INITIALS"                VARCHAR2(20 BYTE)
   ,"FIRST_NAME"              VARCHAR2(30 BYTE)
   ,"SURNAME"                 VARCHAR2(100 BYTE)
   ,"EFFECTIVE_START_DATE"    DATE               
   ,"EFFECTIVE_END_DATE"      DATE               
   );
