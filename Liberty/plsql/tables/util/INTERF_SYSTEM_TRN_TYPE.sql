
  CREATE TABLE "UTIL"."INTERF_SYSTEM_TRN_TYPE" 
   (	"INTERF_SYSTEM_ID_NO" NUMBER(9,0) NOT NULL ENABLE, 
	"TRN_TYPE_NO" NUMBER(9,0) NOT NULL ENABLE, 
	"TRN_TYPE_DESC" VARCHAR2(50 CHAR) NOT NULL ENABLE, 
	"EFFECTIVE_START_DATE" DATE, 
	"EFFECTIVE_END_DATE" DATE, 
	"LAST_UPDATE_DATETIME" DATE NOT NULL ENABLE, 
	"USERNAME" VARCHAR2(50 CHAR) NOT NULL ENABLE, 
	 CONSTRAINT "INTERF_SYSTEM_TRN_TYPE_PK" PRIMARY KEY ("INTERF_SYSTEM_ID_NO", "TRN_TYPE_NO")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS"  ENABLE, 
	 CONSTRAINT "INTERF_SYSTEM_TRN_TYPE_FK1" FOREIGN KEY ("INTERF_SYSTEM_ID_NO")
	  REFERENCES "UTIL"."INTERF_SYSTEM" ("INTERF_SYSTEM_ID_NO") ENABLE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;
