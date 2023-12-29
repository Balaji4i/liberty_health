CREATE TABLE "LHHCOM"."DNLD_COMPANY_ACCRED" 
   (
  "INTERF_SYSTEM_ID_NO" NUMBER(9,0) DEFAULT 1 NOT NULL ENABLE,
	"COMPANY_ID_NO" NUMBER(9,0) NOT NULL ENABLE, 
	"EFFECTIVE_START_DATE" DATE NOT NULL ENABLE, 
	"ACCREDITATION_TYPE_ID_NO"  NUMBER(2,0) NOT NULL ENABLE,
	"STAMP_DATETIME" TIMESTAMP NOT NULL ENABLE, 
	"STAMP_IND" CHAR(1 CHAR) NOT NULL ENABLE, 
	"BATCH_NO" NUMBER(9,0) DEFAULT 0 NOT NULL ENABLE, 
	"LAST_UPDATE_DATETIME" DATE NOT NULL ENABLE, 
	"USERNAME" VARCHAR2(50 CHAR) NOT NULL ENABLE, 
	 CONSTRAINT "DNLD_COMPANY_ACCRED" PRIMARY KEY ("INTERF_SYSTEM_ID_NO", "COMPANY_ID_NO","EFFECTIVE_START_DATE","ACCREDITATION_TYPE_ID_NO", "STAMP_DATETIME") ENABLE
   );