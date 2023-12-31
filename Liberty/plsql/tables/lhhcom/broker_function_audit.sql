-- Create Commisions Table Audits "LHHCOM"."BROKER_FUNCTION_AUDIT"

  CREATE TABLE "LHHCOM"."BROKER_FUNCTION_AUDIT" 
   (	
  "TRANSACTION_DATETIME" DATE,
	"TRANSACTION_DESC" VARCHAR2(550 BYTE),
	"TRANSACTION_USERNAME" VARCHAR2(50 BYTE),
  "BROKER_ID_NO" NUMBER(9,0),
	"BROKER_TABLE_TYPE_ID_NO" NUMBER(9,0),
	"EFFECTIVE_START_DATE" DATE,
	"EFFECTIVE_END_DATE" DATE, 
	"BROKER_TABLE_ID_NO" NUMBER(9,0)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
  NOCOMPRESS LOGGING
  TABLESPACE "USERS" ;

/**
******** Check the structure of your table
*/
-- descr "LHHCOM"."BROKER_FUNCTION_AUDIT";

/**
******** Drop the structure of your BROKER_FUNCTION_AUDIT table if needed
*/
-- DROP TABLE "LHHCOM"."BROKER_FUNCTION_AUDIT"; 