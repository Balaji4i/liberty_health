  CREATE TABLE "LHHCOM"."OHI_POLICIES_AUDIT" 
   (	
	  "TRANSACTION_DATETIME"    DATE  DEFAULT SYSDATE
	 ,"TRANSACTION_DESC"        VARCHAR2(550 BYTE) 
	 ,"TRANSACTION_USERNAME"    VARCHAR2(50 BYTE) DEFAULT USER
   ,"POLI_ID"                 NUMBER(14,0)       
   ,"POLICY_CODE"             VARCHAR2(30 BYTE)  
   );