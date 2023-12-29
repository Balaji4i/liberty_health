  CREATE TABLE "LHHCOM"."OHI_PRODUCTS" 
   (
    "ENPR_ID"                 NUMBER(14,0)       NOT NULL ENABLE
   ,"PRODUCT_CODE"            VARCHAR2(30 BYTE)  NOT NULL ENABLE
   ,"COUNTRY_CODE"            VARCHAR2(4 BYTE)
   ,"PRODUCT_NAME"            VARCHAR2(30 BYTE)
   ,"PRODUCT_DESCR"           VARCHAR2(200 BYTE)
   ,"LAST_UPDATE_DATETIME"    DATE               DEFAULT sysdate NOT NULL ENABLE
   ,"USERNAME"                VARCHAR2(20 BYTE)  DEFAULT 'USERNAME' NOT NULL ENABLE
   ,CONSTRAINT "OHI_PRODUCTS_PK"
      PRIMARY KEY ("ENPR_ID")
      ENABLE
   );