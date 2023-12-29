  CREATE TABLE "LHHCOM"."OHI_POLICY_GROUPS_AUDIT" 
   (	
	  "TRANSACTION_DATETIME"    DATE 
	 ,"TRANSACTION_DESC"        VARCHAR2(550 BYTE) 
	 ,"TRANSACTION_USERNAME"    VARCHAR2(50 BYTE)
   ,"POGR_ID"                 NUMBER(14,0)       
   ,"POLI_ID"                 NUMBER(14,0)       
   ,"GRAC_ID"                 NUMBER(14,0)       
   ,"EFFECTIVE_START_DATE"    DATE               
   ,"EFFECTIVE_END_DATE"      DATE               
   );
