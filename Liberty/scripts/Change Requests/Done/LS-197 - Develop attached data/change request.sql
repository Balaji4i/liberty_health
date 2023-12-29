/**
* Steps
*   1) Drop foreign key constraint on INVOICE_DETAIL in order to drop INVOICE table
*   2) Create temporary table with all INVOICE table data
*   3) Drop and recreate INVOICE table (Add new columns)
*   4) Re-populate data into INVOICE table from temp table
*   5) Enable foreign key constraint on INVOICE_DETAIL again
*   6) Compile Triggers
*   7) Compile comms_calc_package
*   8) Cleanup 
*
* Sarel to run this putlive
**/

--  1) Drop foreign key constraint on INVOICE_DETAIL in order to drop INVOICE table
ALTER TABLE INVOICE_DETAIL
DROP CONSTRAINT INVOICE_DETAIL_FK;

--  2) Create temporary table with all INVOICE table data
create table temp_invoice as
select *
from invoice;

create table temp_invoice_audit as
select *
from invoice_audit;


-- 3) Drop and recreate INVOICE table (Add new columns)
DROP TABLE invoice;
CREATE TABLE "LHHCOM"."INVOICE" 
   ("INVOICE_NO" NUMBER(9,0) NOT NULL ENABLE, 
	"INVOICE_DATE" DATE NOT NULL ENABLE, 
	"PAYMENT_RECEIVE_DATE" DATE NOT NULL ENABLE, 
	"COUNTRY_CODE" VARCHAR2(4 BYTE) NOT NULL ENABLE, 
	"COMPANY_ID_NO" NUMBER(9,0) NOT NULL ENABLE, 
	"INVOICE_TYPE_ID_NO" NUMBER(2,0) NOT NULL ENABLE,
	"RELEASE_DATE" DATE, 
	"RELEASE_HOLD_REASON" VARCHAR2(250 BYTE), 
	"PAYMENT_DATE" DATE, 
	"PAYMENT_REJECT_DATE" DATE, 
	"PAYMENT_REJECT_DESC" VARCHAR2(500 BYTE),
	"PAYMENT_AMT" NUMBER(15,9), 
	"PAYMENT_EXCH_RATE" NUMBER(15,9), 
	"CURRENCY_CODE" VARCHAR2(4 BYTE), 
	"LAST_UPDATE_DATETIME" DATE NOT NULL ENABLE, 
	"USERNAME" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	 CONSTRAINT "INVOICE_PK" PRIMARY KEY ("INVOICE_NO")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 
  TABLESPACE "USERS"  ENABLE,
   CONSTRAINT "INVOICE_COMPANY_FK" FOREIGN KEY ("COMPANY_ID_NO")
	  REFERENCES "LHHCOM"."COMPANY" ("COMPANY_ID_NO") ENABLE,
      CONSTRAINT "INVOICE_INV_TYPE_FK" FOREIGN KEY ("INVOICE_TYPE_ID_NO")
	  REFERENCES "LHHCOM"."INVOICE_TYPE" ("INVOICE_TYPE_ID_NO") ENABLE
   ) SEGMENT CREATION DEFERRED 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
TABLESPACE "USERS" ;

DROP TABLE INVOICE_AUDIT;
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
	"RELEASE_DATE" DATE, 
	"RELEASE_HOLD_REASON" VARCHAR2(250 BYTE), 
	"PAYMENT_DATE" DATE, 
	"PAYMENT_AMT" NUMBER(15,9), 
	"PAYMENT_EXCH_RATE" NUMBER(15,9), 
	"CURRENCY_CODE" VARCHAR2(4 BYTE),
	"PAYMENT_REJECT_DATE" DATE, 
	"PAYMENT_REJECT_DESC" VARCHAR2(500 BYTE)) 
   TABLESPACE "USERS" ;
   
-- 4) Re-populate data into INVOICE table from temp table
insert into invoice (INVOICE_NO           ,
INVOICE_DATE         ,
PAYMENT_RECEIVE_DATE ,
COUNTRY_CODE         ,
COMPANY_ID_NO        ,
INVOICE_TYPE_ID_NO   ,
RELEASE_DATE         ,
RELEASE_HOLD_REASON  ,
PAYMENT_DATE         ,
PAYMENT_AMT          ,
PAYMENT_EXCH_RATE    ,
CURRENCY_CODE        ,
LAST_UPDATE_DATETIME ,
USERNAME            )

select INVOICE_NO           ,
INVOICE_DATE         ,
PAYMENT_RECEIVE_DATE ,
COUNTRY_CODE         ,
COMPANY_ID_NO        ,
INVOICE_TYPE_ID_NO   ,
RELEASE_DATE         ,
RELEASE_HOLD_REASON  ,
PAYMENT_DATE         ,
PAYMENT_AMT          ,
PAYMENT_EXCH_RATE    ,
CURRENCY_CODE        ,
LAST_UPDATE_DATETIME ,
USERNAME            
from temp_invoice;


insert into invoice_audit (TRANSACTION_DATETIME      ,
TRANSACTION_DESC          ,
TRANSACTION_USERNAME      ,
INVOICE_NO                ,
INVOICE_DATE              ,
PAYMENT_RECEIVE_DATE      ,
COUNTRY_CODE              ,
COMPANY_ID_NO             ,
RELEASE_DATE              ,
RELEASE_HOLD_REASON       ,
PAYMENT_DATE              ,
PAYMENT_AMT               ,
PAYMENT_EXCH_RATE         ,
CURRENCY_CODE             )

select TRANSACTION_DATETIME      ,
TRANSACTION_DESC          ,
TRANSACTION_USERNAME      ,
INVOICE_NO                ,
INVOICE_DATE              ,
PAYMENT_RECEIVE_DATE      ,
COUNTRY_CODE              ,
COMPANY_ID_NO             ,
RELEASE_DATE              ,
RELEASE_HOLD_REASON       ,
PAYMENT_DATE              ,
PAYMENT_AMT               ,
PAYMENT_EXCH_RATE         ,
CURRENCY_CODE             
from  temp_invoice_audit;


-- 5) Enable foreign key constraint on INVOICE_DETAIL again
ALTER TABLE INVOICE_DETAIL
ADD CONSTRAINT "INVOICE_DETAIL_FK" FOREIGN KEY ("INVOICE_NO")
REFERENCES "LHHCOM"."INVOICE" ("INVOICE_NO") ENABLE;


--6) Compile Triggers
@../../../../plsql/triggers/lhhcom/INVOICE_AUDIT_BEFORE_TRG.sql;
@../../../../plsql/triggers/lhhcom/INVOICE_BEFORE_TRG.sql;
@../../../../plsql/triggers/lhhcom/INVOICE_DETAIL_AUDIT_BEF_TRG.sql;

-- 7) Compile new COMMS_CALC procedure
@../../../../plsql/packages/lhhcom/comms_calc_pkg.sql;
@../../../../plsql/packages/lhhcom/commissions_pkg.sql;

-- 8 Clean up
DROP table temp_invoice;
DROP table temp_invoice_audit;