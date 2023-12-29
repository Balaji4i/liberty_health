  CREATE TABLE "LHHCOM"."OHI_ENROLLMENT_PRODUCTS_AUDIT" 
   (	
	  "TRANSACTION_DATETIME"    DATE 
	 ,"TRANSACTION_DESC"        VARCHAR2(550 BYTE) 
	 ,"TRANSACTION_USERNAME"    VARCHAR2(50 BYTE)
   ,"POEP_ID"                 NUMBER(14,0)      
   ,"POEN_ID"                 NUMBER(14,0)      
   ,"ENPR_ID"                 NUMBER(14,0)      
   ,"EFFECTIVE_START_DATE"    DATE              
   ,"EFFECTIVE_END_DATE"      DATE              
   );
