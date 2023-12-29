  CREATE TABLE "LHHCOM"."OHI_HOLD_IND_AUDIT" 
   (	
	  "TRANSACTION_DATETIME"    DATE               DEFAULT SYSDATE
	 ,"TRANSACTION_DESC"        VARCHAR2(550 BYTE) 
	 ,"TRANSACTION_USERNAME"    VARCHAR2(50 BYTE)  DEFAULT USER
   ,"PRODUCT_CODE"            VARCHAR2(30 BYTE) 
   ,"POEP_ID"                 NUMBER(14,0)       
   ,"INSE_CODE"               VARCHAR2(30 BYTE)  
   ,"POLICY_CODE"             VARCHAR2(30 BYTE)  
   ,"GROUP_CODE"              VARCHAR2(30 BYTE)  
   ,"BROKER_ID_NO"            NUMBER(9,0)       
   ,"COMPANY_ID_NO"           NUMBER(9,0)       
   ,"HOLD_IND"                VARCHAR2(1 BYTE)   
   ,"HOLD_REASON"             VARCHAR2(100 BYTE)
   ,"EFFECTIVE_START_DATE"    DATE               
   ,"EFFECTIVE_END_DATE"      DATE               
   );
