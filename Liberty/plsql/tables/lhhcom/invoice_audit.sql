CREATE TABLE "LHHCOM"."INVOICE_AUDIT" 
   ("TRANSACTION_DATETIME" DATE, 
	"TRANSACTION_DESC" VARCHAR2(250 BYTE), 
	"TRANSACTION_USERNAME" VARCHAR2(50 BYTE),
	"INVOICE_NO" NUMBER(9,0) , 
	"INVOICE_DATE" DATE , 
	"PAYMENT_RECEIVE_DATE" DATE , 
	"COUNTRY_CODE" VARCHAR2(4 BYTE) , 
	"COMPANY_ID_NO" NUMBER(9,0) , 
	"INVOICE_TYPE_ID_NO" NUMBER(2,0),
-- Helen LS-1361 add INV_TAX_CODES 
  "INVOICE_TAX_CODES" VARCHAR2(50 BYTE),
-- Helen LS-1361    
	"RELEASE_DATE" DATE, 
	"RELEASE_HOLD_REASON" VARCHAR2(250 BYTE), 
	"PAYMENT_DATE" DATE, 
	"PAYMENT_AMT" NUMBER(22,9), 
	"PAYMENT_EXCH_RATE" NUMBER(15,9), 
	"CURRENCY_CODE" VARCHAR2(4 BYTE),
	"PAYMENT_REJECT_DATE" DATE, 
	"PAYMENT_REJECT_DESC" VARCHAR2(500 BYTE),
  "INVOICE_TAX_CODES" VARCHAR2(50 BYTE))
   TABLESPACE "USERS" ;