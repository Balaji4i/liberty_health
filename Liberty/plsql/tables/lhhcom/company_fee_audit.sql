  CREATE TABLE "LHHCOM"."COMPANY_FEE_AUDIT" 
   (	
	"TRANSACTION_DATETIME" DATE, 
	"TRANSACTION_DESC" VARCHAR2(550 BYTE), 
	"TRANSACTION_USERNAME" VARCHAR2(50 BYTE),
	"COMPANY_ID_NO" NUMBER(9,0), 
	"COMPANY_FEE_TYPE_ID_NO" NUMBER(2,0), 
	"EFFECTIVE_START_DATE" DATE, 
	"EFFECTIVE_END_DATE" DATE, 
	"FEE_AMT" NUMBER(9,0), 
	"FEE_PERC" NUMBER(9,0), 
	"FEE_FREQ_NO" NUMBER(5,2), 
	"FEE_COMMENT_DESC" VARCHAR2(200 BYTE)
   ) 
   TABLESPACE "USERS" ;