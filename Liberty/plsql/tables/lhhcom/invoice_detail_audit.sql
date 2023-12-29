
  CREATE TABLE "LHHCOM"."INVOICE_DETAIL_AUDIT" 
   ("TRANSACTION_DATETIME" DATE, 
	"TRANSACTION_DESC" VARCHAR2(550 BYTE), 
	"TRANSACTION_USERNAME" VARCHAR2(50 BYTE),
	"INVOICE_NO" NUMBER(9,0) , 
	"FEE_TYPE_ID_NO" NUMBER(9,0) , 
	"FEE_TYPE_AMT" NUMBER(22,9) , 
	"FEE_TYPE_DESC" VARCHAR2(200 BYTE),
	"FEE_TYPE_EXCH_AMT" NUMBER(22,9)
   ) 
   TABLESPACE "USERS" ;