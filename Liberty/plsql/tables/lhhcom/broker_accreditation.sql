CREATE TABLE "LHHCOM"."BROKER_ACCREDITATION" 
   ("BROKER_ID_NO" NUMBER(9,0) NOT NULL ENABLE, 
	"EFFECTIVE_START_DATE" DATE NOT NULL ENABLE, 
	"EFFECTIVE_END_DATE" DATE, 
    "ACCREDITATION_TYPE_ID_NO" NUMBER(2,0) NOT NULL ENABLE, 
	"BROKER_ACCRED_NO" NUMBER(9,0), 
	"BROKER_ACCRED_START_DATE" DATE NOT NULL ENABLE, 
	"BROKER_ACCRED_END_DATE" DATE NOT NULL ENABLE, 
	"LAST_UPDATE_DATETIME" DATE NOT NULL ENABLE, 
	"USERNAME" VARCHAR2(50 CHAR) NOT NULL ENABLE, 
	 CONSTRAINT "BROKER_ACCRED_PK" PRIMARY KEY ("BROKER_ID_NO", "EFFECTIVE_START_DATE","ACCREDITATION_TYPE_ID_NO")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS"  ENABLE, 
	 CONSTRAINT "BROKER_ACCRED_FK" FOREIGN KEY ("BROKER_ID_NO")
	  REFERENCES "LHHCOM"."BROKER" ("BROKER_ID_NO") ENABLE, 
	 CONSTRAINT "ACCREDITATION_BROKER_FK" FOREIGN KEY ("ACCREDITATION_TYPE_ID_NO")
	  REFERENCES "LHHCOM"."ACCREDITATION_TYPE" ("ACCREDITATION_TYPE_ID_NO") ENABLE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;

