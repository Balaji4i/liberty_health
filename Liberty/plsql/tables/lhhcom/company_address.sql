CREATE TABLE "LHHCOM"."COMPANY_ADDRESS" 
   (	"COMPANY_ID_NO" NUMBER(9,0) NOT NULL ENABLE, 
	"COUNTRY_CODE" VARCHAR2(4 BYTE) NOT NULL ENABLE, 
	"ADDRESS_TYPE_CODE" CHAR(1 BYTE) NOT NULL ENABLE, 
	"EFFECTIVE_START_DATE" DATE NOT NULL ENABLE, 
	"EFFECTIVE_END_DATE" DATE NOT NULL ENABLE, 
	"ADDRESS_LINE1" VARCHAR2(250 BYTE), 
	"ADDRESS_LINE2" VARCHAR2(250 BYTE), 
	"ADDRESS_LINE3" VARCHAR2(250 BYTE), 
	"ADDRESS_COUNTRY_CODE" VARCHAR2(4 BYTE), 
	"POSTAL_CODE" VARCHAR2(15 BYTE), 
	"LAST_UPDATE_DATETIME" DATE NOT NULL ENABLE, 
	"USERNAME" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	 CONSTRAINT "COMPANY_ADDRESS_PK" PRIMARY KEY ("COMPANY_ID_NO", "ADDRESS_TYPE_CODE", "EFFECTIVE_START_DATE", "COUNTRY_CODE")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS"  ENABLE, 
	 CONSTRAINT "COMPANY_ADDRESS_TYPE_FK" FOREIGN KEY ("ADDRESS_TYPE_CODE")
	  REFERENCES "LHHCOM"."ADDRESS_TYPE" ("ADDRESS_TYPE_CODE") ENABLE, 
	 CONSTRAINT "COMPANY_ADDRESS_FK" FOREIGN KEY ("COMPANY_ID_NO", "COUNTRY_CODE")
	  REFERENCES "LHHCOM"."COMPANY_COUNTRY" ("COMPANY_ID_NO", "COUNTRY_CODE") ENABLE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;
