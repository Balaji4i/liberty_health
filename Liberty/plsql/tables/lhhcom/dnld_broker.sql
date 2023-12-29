
  CREATE TABLE "LHHCOM"."DNLD_BROKER" 
   (	"BROKER_ID_NO" NUMBER(9,0) NOT NULL ENABLE, 
	"STAMP_DATETIME" TIMESTAMP NOT NULL ENABLE, 
	"STAMP_IND" CHAR(1 CHAR) NOT NULL ENABLE, 
	"BATCH_NO" NUMBER(9,0) DEFAULT 0 NOT NULL ENABLE, 
	"LAST_UPDATE_DATETIME" DATE NOT NULL ENABLE, 
	"USERNAME" VARCHAR2(50 CHAR) NOT NULL ENABLE, 
	 CONSTRAINT "DNLD_BROKER" PRIMARY KEY ("BROKER_ID_NO", "STAMP_DATETIME")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS"  ENABLE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;