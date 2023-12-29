
  CREATE TABLE "LHHCOM"."COMMS_CALC_SNAPSHOT" 
   (
    "COMMS_CALC_SNAPSHOT_NO"      NUMBER(12)
   ,"COUNTRY_CODE"                VARCHAR2(4 BYTE) 
   ,"PRODUCT_CODE"                VARCHAR2(30 BYTE) 
   ,"POEP_ID"                     NUMBER(14,0)       
   ,"PERSON_CODE"                 VARCHAR2(30 BYTE)  
   ,"POLICY_CODE"                 VARCHAR2(30 BYTE)  
   ,"GROUP_CODE"                  VARCHAR2(30 BYTE)  
   ,"BROKER_ID_NO"                NUMBER(9,0)       
   ,"COMPANY_ID_NO"               NUMBER(9,0)        NOT NULL ENABLE
   ,"COMMS_PERC"                  NUMBER(15,9)       NOT NULL ENABLE
   ,"CONTRIBUTION_DATE"           DATE               NOT NULL ENABLE 
   ,"PAYMENT_RECEIVE_DATE"        DATE               NOT NULL ENABLE
   ,"FINANCE_RECEIPT_NO"          VARCHAR2(100 BYTE) NOT NULL ENABLE 
   ,"CALCULATION_DATETIME"        DATE               NOT NULL ENABLE
   ,"COMMS_CALC_TYPE_CODE"        CHAR(1 CHAR)       NOT NULL ENABLE
   ,"PAYMENT_RECEIVE_AMT"         NUMBER(22,9)       NOT NULL ENABLE
   ,"PAYMENT_CURRENCY"            VARCHAR2(5 BYTE)   NOT NULL ENABLE
   ,"COMMS_CALCULATED_AMT"        NUMBER(22,9)       NOT NULL ENABLE
   ,"EXCHANGE_RATE"               NUMBER(15,9) 
   ,"EXCHANGE_RATE_CURRENCY_CODE" VARCHAR2(5 BYTE)   NOT NULL ENABLE
   ,"COMMS_CALCULATED_EXCH_AMT"   NUMBER(22,9)       NOT NULL ENABLE
   ,"INVOICE_NO"                  NUMBER(15,0)
   ,"LAST_UPDATE_DATETIME"        DATE               DEFAULT SYSDATE NOT NULL ENABLE
   ,"USERNAME"                    varchar2(20 byte)  default user not null enable
	 ,CONSTRAINT "COMMS_CALC_SNAPSHOT_PK" primary key ("COMMS_CALC_SNAPSHOT_NO")                     
	 ,CONSTRAINT "COMMS_CALC_TYPE_FK" FOREIGN KEY ("COMMS_CALC_TYPE_CODE") REFERENCES "LHHCOM"."COMMS_CALC_TYPE" ("COMMS_CALC_TYPE_CODE") ENABLE
   );