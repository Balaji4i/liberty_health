
  CREATE TABLE "LHHCOM"."BROKER" 
   ("BROKER_ID_NO" NUMBER(9,0) NOT NULL ENABLE, 
   	"PARENT_BROKER_ID_NO" NUMBER(9,0), 
	"KAM_BROKER_ID_NO" NUMBER(9,0), 
	"COMPANY_ID_NO" NUMBER(9,0),
	"PERSON_TITLE_CODE" VARCHAR2(12 CHAR) DEFAULT NULL NOT NULL ENABLE, 
	"INITIALS" VARCHAR2(10 CHAR), 
	"BROKER_NAME" VARCHAR2(50 CHAR) DEFAULT NULL NOT NULL ENABLE, 
	"BROKER_LAST_NAME" VARCHAR2(100 CHAR) DEFAULT NULL NOT NULL ENABLE, 
	"PASSPORT_CODE" VARCHAR2(50 CHAR), 
	"LANGUAGE_CODE" VARCHAR2(4 CHAR) DEFAULT NULL NOT NULL ENABLE, 
	"ID_NO" NUMBER(20,0) DEFAULT NULL, 
	"SMS_NOTIFICATION_IND" CHAR(1 CHAR) DEFAULT NULL NOT NULL ENABLE, 
	"EMAIL_NOTIFICATION_IND" CHAR(1 CHAR) DEFAULT NULL NOT NULL ENABLE, 
	"BUSINESS_DEV_MGR_NAME" VARCHAR2(250 CHAR), 
	"WEB_PASSWORD" VARCHAR2(50 CHAR), 
	"EFFECTIVE_START_DATE" DATE, 
	"EFFECTIVE_END_DATE" DATE, 
	"CELLPHONE_NO" VARCHAR2(30 CHAR), 
	"EMAIL_ADDRESS" VARCHAR2(250 CHAR), 
	"WORK_TELEPHONE_NO" VARCHAR2(30 CHAR), 
	"HOME_TELEPHONE_NO" VARCHAR2(30 CHAR), 
	"LAST_UPDATE_DATETIME" DATE DEFAULT NULL NOT NULL ENABLE, 
	"USERNAME" VARCHAR2(50 CHAR) DEFAULT NULL NOT NULL ENABLE, 
	 CONSTRAINT "BROKER_PK" PRIMARY KEY ("BROKER_ID_NO")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS"  ENABLE, 
	 CONSTRAINT "BROKER_COMPANY_FK" FOREIGN KEY ("COMPANY_ID_NO")
	  REFERENCES "LHHCOM"."COMPANY" ("COMPANY_ID_NO") DISABLE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;
