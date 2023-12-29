  CREATE TABLE "LHHCOM"."OHI_POLICY_BROKERS_AUDIT" 
   (	
	  "TRANSACTION_DATETIME"    DATE  DEFAULT SYSDATE
	 ,"TRANSACTION_DESC"        VARCHAR2(550 BYTE) 
	 ,"TRANSACTION_USERNAME"    VARCHAR2(50 BYTE) DEFAULT USER
   ,"POLI_ID"                 NUMBER(14,0)       
   ,"POBR_ID"                 NUMBER(14,0)       
   ,"BROKER_ID_NO"            NUMBER(9,0)       
   ,"COMPANY_ID_NO"           NUMBER(9,0)       
   ,"EFFECTIVE_START_DATE"    DATE               
   ,"EFFECTIVE_END_DATE"      DATE               
   );
