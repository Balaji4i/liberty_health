  CREATE TABLE "LHHCOM"."OHI_INSURED_ENTITIES_AUDIT" 
   (	
	  "TRANSACTION_DATETIME"    DATE 
	 ,"TRANSACTION_DESC"        VARCHAR2(550 BYTE) 
	 ,"TRANSACTION_USERNAME"    VARCHAR2(50 BYTE)
   ,"INSE_ID"                 NUMBER(14,0)       
   ,"INSE_CODE"               VARCHAR2(30 BYTE)  
   ,"RELA_ID_PERS"            NUMBER(14,0)       
   ,"TITLE"                   VARCHAR2(20 BYTE)
   ,"INITIALS"                VARCHAR2(20 BYTE)
   ,"FIRST_NAME"              VARCHAR2(30 BYTE)
   ,"SURNAME"                 VARCHAR2(100 BYTE)
   ,"GENDER"                  VARCHAR2(1 BYTE)
   );
