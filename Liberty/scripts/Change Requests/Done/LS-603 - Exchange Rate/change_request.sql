 create table temp_comms_calc as
select country_code,
product_code,
poep_id,
person_code,
policy_code,
group_code,
broker_id_no,
company_id_no,
comms_perc,
contribution_date,
payment_receive_date,
finance_receipt_no,
calculation_datetime,
comms_calc_type_code,
payment_receive_amt,
comms_calculated_amt,
0 exchange_rate,
' ' exchange_rate_currency_code,
0 comms_calculated_exch_amt,
invoice_no,
last_update_datetime,
username
from comms_calc_snapshot;

create table temp_invoice as
select invoice_no,
invoice_date,
contribution_date payment_receive_date,
country_code,
company_id_no,
invoice_type_id_no,
release_date,
release_hold_reason,
payment_date,
payment_amt,
payment_exch_rate,
currency_code,
last_update_datetime,
username
from invoice;

create table temp_invoice_Detail as
select invoice_no,
fee_type_id_no,
fee_type_amt,
fee_type_amt fee_type_exch_amt,
fee_type_desc,
last_update_datetime,
username
from invoice_detail;

commit;

drop  TABLE "LHHCOM"."COMMS_CALC_SNAPSHOT" ;
DROP TABLE "LHHCOM"."INVOICE_DETAIL" ; 
DROP TABLE "LHHCOM"."INVOICE" ;
   
 
  CREATE TABLE "LHHCOM"."COMMS_CALC_SNAPSHOT" 
   (
    "COUNTRY_CODE"            VARCHAR2(4 BYTE) 
   ,"PRODUCT_CODE"            VARCHAR2(30 BYTE) 
   ,"POEP_ID"                 NUMBER(14,0)       
   ,"PERSON_CODE"             VARCHAR2(30 BYTE)  
   ,"POLICY_CODE"             VARCHAR2(30 BYTE)  
   ,"GROUP_CODE"              VARCHAR2(30 BYTE)  
   ,"BROKER_ID_NO"            NUMBER(9,0)       
   ,"COMPANY_ID_NO"           NUMBER(9,0)        NOT NULL ENABLE
   ,"COMMS_PERC"              NUMBER(15,9)        NOT NULL ENABLE
   ,"CONTRIBUTION_DATE"       DATE               NOT NULL ENABLE 
   ,"PAYMENT_RECEIVE_DATE"    DATE               NOT NULL ENABLE
   ,"FINANCE_RECEIPT_NO"      VARCHAR2(100 BYTE) NOT NULL ENABLE 
   ,"CALCULATION_DATETIME"    DATE               NOT NULL ENABLE
   ,"COMMS_CALC_TYPE_CODE"    CHAR(1 CHAR)       NOT NULL ENABLE
   ,"PAYMENT_RECEIVE_AMT"     NUMBER(15,9)       NOT NULL ENABLE
   ,"COMMS_CALCULATED_AMT"    NUMBER(15,9)       NOT NULL ENABLE
   ,"EXCHANGE_RATE"           NUMBER(15,9) 
   ,"EXCHANGE_RATE_CURRENCY_CODE"   VARCHAR2(5 BYTE)  
   ,"COMMS_CALCULATED_EXCH_AMT"    NUMBER(15,9)       NOT NULL ENABLE
   ,"INVOICE_NO"              NUMBER(15,0)
   ,"LAST_UPDATE_DATETIME"    DATE               DEFAULT SYSDATE NOT NULL ENABLE
   ,"USERNAME"                VARCHAR2(20 BYTE)  DEFAULT USER NOT NULL ENABLE
	 ,CONSTRAINT "COMMS_CALC_SNAPSHOT_PK" PRIMARY KEY (
                              "COUNTRY_CODE"
                             ,"PRODUCT_CODE"
                             ,"POEP_ID"
                             ,"PERSON_CODE"
                             ,"POLICY_CODE"
                             ,"GROUP_CODE"
                             ,"BROKER_ID_NO"
                             ,"COMPANY_ID_NO"
                             ,"CONTRIBUTION_DATE"
                             ,"PAYMENT_RECEIVE_DATE"
                             ,"FINANCE_RECEIPT_NO"
                             ,"CALCULATION_DATETIME" )
	 ,CONSTRAINT "COMMS_CALC_TYPE_FK" FOREIGN KEY ("COMMS_CALC_TYPE_CODE") REFERENCES "LHHCOM"."COMMS_CALC_TYPE" ("COMMS_CALC_TYPE_CODE") ENABLE
   );
   
   
  CREATE TABLE "LHHCOM"."INVOICE" 
   (	"INVOICE_NO" NUMBER(9,0) NOT NULL ENABLE, 
	"INVOICE_DATE" DATE NOT NULL ENABLE, 
	"PAYMENT_RECEIVE_DATE" DATE NOT NULL ENABLE, 
	"COUNTRY_CODE" VARCHAR2(4 BYTE) NOT NULL ENABLE, 
	"COMPANY_ID_NO" NUMBER(9,0) NOT NULL ENABLE, 
	"INVOICE_TYPE_ID_NO" NUMBER(2,0) NOT NULL ENABLE,
	"RELEASE_DATE" DATE, 
	"RELEASE_HOLD_REASON" VARCHAR2(250 BYTE), 
	"PAYMENT_DATE" DATE, 
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
  
  CREATE TABLE "LHHCOM"."INVOICE_DETAIL" 
   ("INVOICE_NO" NUMBER(9,0) NOT NULL ENABLE, 
	"FEE_TYPE_ID_NO" NUMBER(9,0) NOT NULL ENABLE, 
	"FEE_TYPE_AMT" NUMBER(15,9) NOT NULL ENABLE, 
	"FEE_TYPE_EXCH_AMT" NUMBER(15,9) NOT NULL ENABLE,	
	"FEE_TYPE_DESC" VARCHAR2(200 BYTE), 
	"LAST_UPDATE_DATETIME" DATE NOT NULL ENABLE, 
	"USERNAME" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	 CONSTRAINT "INVOICE_DETAIL_PK" PRIMARY KEY ("INVOICE_NO", "FEE_TYPE_ID_NO")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 
  TABLESPACE "USERS"  ENABLE,
   CONSTRAINT "INVOICE_DETAIL_FK" FOREIGN KEY ("INVOICE_NO")
	  REFERENCES "LHHCOM"."INVOICE" ("INVOICE_NO") ENABLE
   
   ) SEGMENT CREATION DEFERRED 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  TABLESPACE "USERS" ;

  
  DROP TABLE "LHHCOM"."INVOICE_AUDIT" ;
  CREATE TABLE "LHHCOM"."INVOICE_AUDIT" 
   ("TRANSACTION_DATETIME" DATE, 
	"TRANSACTION_DESC" VARCHAR2(250 BYTE), 
	"TRANSACTION_USERNAME" VARCHAR2(50 BYTE),
	"INVOICE_NO" NUMBER(9,0) , 
	"INVOICE_DATE" DATE , 
	"PAYMENT_RECEIVE_DATE" DATE , 
	"COUNTRY_CODE" VARCHAR2(4 BYTE) , 
	"COMPANY_ID_NO" NUMBER(9,0) , 
	"RELEASE_DATE" DATE, 
	"RELEASE_HOLD_REASON" VARCHAR2(250 BYTE), 
	"PAYMENT_DATE" DATE, 
	"PAYMENT_AMT" NUMBER(15,9), 
	"PAYMENT_EXCH_RATE" NUMBER(15,9), 
	"CURRENCY_CODE" VARCHAR2(4 BYTE)   ) 
   TABLESPACE "USERS" ;
   
   
  DROP TABLE "LHHCOM"."INVOICE_DETAIL_AUDIT" ;

  CREATE TABLE "LHHCOM"."INVOICE_DETAIL_AUDIT" 
   ("TRANSACTION_DATETIME" DATE, 
	"TRANSACTION_DESC" VARCHAR2(250 BYTE), 
	"TRANSACTION_USERNAME" VARCHAR2(50 BYTE),
	"INVOICE_NO" NUMBER(9,0) , 
	"FEE_TYPE_ID_NO" NUMBER(9,0) , 
	"FEE_TYPE_AMT" NUMBER(15,9) , 
	"FEE_TYPE_DESC" VARCHAR2(200 BYTE),
	"FEE_TYPE_EXCH_AMT" NUMBER(15,9)
   ) 
   TABLESPACE "USERS" ;
 /

CREATE OR REPLACE TRIGGER INVOICE_AUDIT_BEFORE_TRG 
/**
----------------------------------------------------------------------
Project:     : Commissions Self Build Application               
Description  : Create Audit Trigger to insert rows whenever a new record
             : is added or an old one is updated or deleted
Author       : Jaco Bosman
Requirements : LHHCOM priviledges to account
Amendments   : 
Date        User     Change Description
========    ======== =================================================
28/08/2017  AMS       Re-Create Trigger 
*/
BEFORE DELETE OR INSERT OR UPDATE  ON INVOICE 

FOR EACH ROW

DECLARE
  aud INVOICE_AUDIT%ROWTYPE;

BEGIN
  -- Setting the Transaction Description
  IF INSERTING THEN
    aud.transaction_desc := 'Created ' || :NEW.INVOICE_NO;
  ELSIF UPDATING THEN
    aud.transaction_desc := 'Changed record ' || :OLD.INVOICE_NO;
    IF :OLD.INVOICE_NO <> :NEW.INVOICE_NO THEN
      aud.transaction_desc := aud.transaction_desc || ', INVOICE_NO from ' ||
        :OLD.INVOICE_NO || ' to ' || :NEW.INVOICE_NO;
    END IF;
    
    IF :OLD.INVOICE_DATE <> :NEW.INVOICE_DATE THEN
      aud.transaction_desc := aud.transaction_desc || ', INVOICE_DATE from ' ||
        :OLD.INVOICE_DATE || ' to ' || :NEW.INVOICE_DATE;
    END IF;
    
    IF :OLD.PAYMENT_RECEIVE_DATE <> :NEW.PAYMENT_RECEIVE_DATE THEN
      aud.transaction_desc := aud.transaction_desc || ', PAYMENT_RECEIVE_DATE from ' ||
        :OLD.PAYMENT_RECEIVE_DATE || ' to ' || :NEW.PAYMENT_RECEIVE_DATE;
    END IF;
    
    IF :OLD.COUNTRY_CODE <> :NEW.COUNTRY_CODE THEN
      aud.transaction_desc := aud.transaction_desc || ', COUNTRY_CODE from ' ||
        :OLD.COUNTRY_CODE || ' to ' || :NEW.COUNTRY_CODE;
    END IF;
    
    IF :OLD.COMPANY_ID_NO <> :NEW.COMPANY_ID_NO THEN
      aud.transaction_desc := aud.transaction_desc || ', COMPANY_ID_NO from ' ||
        :OLD.COMPANY_ID_NO || ' to ' || :NEW.COMPANY_ID_NO;
    END IF;
    
    IF :OLD.RELEASE_DATE <> :NEW.RELEASE_DATE THEN
      aud.transaction_desc := aud.transaction_desc || ', RELEASE_DATE from ' ||
        :OLD.RELEASE_DATE || ' to ' || :NEW.RELEASE_DATE;
    END IF;
    
    IF :OLD.RELEASE_HOLD_REASON <> :NEW.RELEASE_HOLD_REASON THEN
      aud.transaction_desc := aud.transaction_desc || ', RELEASE_HOLD_REASON from ' ||
        :OLD.RELEASE_HOLD_REASON || ' to ' || :NEW.RELEASE_HOLD_REASON;
    END IF;
    
    IF :OLD.PAYMENT_DATE <> :NEW.PAYMENT_DATE THEN
      aud.transaction_desc := aud.transaction_desc || ', PAYMENT_DATE from ' ||
        :OLD.PAYMENT_DATE || ' to ' || :NEW.PAYMENT_DATE;
    END IF;
    
    IF :OLD.PAYMENT_AMT <> :NEW.PAYMENT_AMT THEN
      aud.transaction_desc := aud.transaction_desc || ', PAYMENT_AMT from ' ||
        :OLD.PAYMENT_AMT || ' to ' || :NEW.PAYMENT_AMT;
    END IF;
    
    IF :OLD.PAYMENT_EXCH_RATE <> :NEW.PAYMENT_EXCH_RATE THEN
      aud.transaction_desc := aud.transaction_desc || ', PAYMENT_EXCH_RATE from ' ||
        :OLD.PAYMENT_EXCH_RATE || ' to ' || :NEW.PAYMENT_EXCH_RATE;
    END IF;
   
   IF :OLD.CURRENCY_CODE <> :NEW.CURRENCY_CODE THEN
      aud.transaction_desc := aud.transaction_desc || ', CURRENCY_CODE from ' ||
        :OLD.CURRENCY_CODE || ' to ' || :NEW.CURRENCY_CODE;
    END IF;
        
  ELSIF DELETING THEN
    aud.transaction_desc := 'Deleted record ' || :OLD.INVOICE_NO;
  END IF;

  -- Setting the logger values in case
 -- logger.append_param(l_params, 'Action:', aud.transaction_desc);

  -- Setting the Audit row values
  IF INSERTING OR UPDATING THEN
    aud.INVOICE_NO                  := :NEW.INVOICE_NO;
    aud.INVOICE_DATE		        := :NEW.INVOICE_DATE;
    aud.PAYMENT_RECEIVE_DATE        := :NEW.PAYMENT_RECEIVE_DATE;
    aud.COUNTRY_CODE               	:= :NEW.COUNTRY_CODE;
    aud.COMPANY_ID_NO               := :NEW.COMPANY_ID_NO;
    aud.RELEASE_DATE                := :NEW.RELEASE_DATE;
    aud.RELEASE_HOLD_REASON         := :NEW.RELEASE_HOLD_REASON;
    aud.PAYMENT_DATE            	:= :NEW.PAYMENT_DATE;
    aud.PAYMENT_AMT                 := :NEW.PAYMENT_AMT;
    aud.PAYMENT_EXCH_RATE       	:= :NEW.PAYMENT_EXCH_RATE;
    aud.CURRENCY_CODE               := :NEW.CURRENCY_CODE;

  ELSIF DELETING THEN
    aud.INVOICE_NO                  := :OLD.INVOICE_NO;
    aud.INVOICE_DATE              	:= :OLD.INVOICE_DATE;
    aud.PAYMENT_RECEIVE_DATE        := :OLD.PAYMENT_RECEIVE_DATE;
    aud.COUNTRY_CODE               	:= :OLD.COUNTRY_CODE;
    aud.COMPANY_ID_NO               := :OLD.COMPANY_ID_NO;
    aud.RELEASE_DATE               	:= :OLD.RELEASE_DATE;
    aud.RELEASE_HOLD_REASON         := :OLD.RELEASE_HOLD_REASON;
    aud.PAYMENT_DATE     		    := :OLD.PAYMENT_DATE;
    aud.PAYMENT_AMT        		    := :OLD.PAYMENT_AMT;
    aud.PAYMENT_EXCH_RATE           := :OLD.PAYMENT_EXCH_RATE;
    aud.CURRENCY_CODE               := :OLD.CURRENCY_CODE;
  
    -- In Case we don't want to allow deleting
    -- raise_application_error(-20001,'Deletion not supported on this table');
  ELSE
    raise_application_error(-20002,'Not INSERTING, UPDATING or DELETING. Please contact IT Support');
  END IF;
  
  -- Setting the Audit User and Date values
  aud.transaction_username := USER;
  aud.transaction_datetime := SYSDATE;

  -- Writing the Audit Record
  INSERT INTO INVOICE_AUDIT VALUES aud;

  EXCEPTION
    WHEN OTHERS THEN
      --logger.log_error('Unhandled Exception', l_scope, null, l_params);
      -- dbms_output.put_line('Error Code is ' || TO_CHAR(SQLCODE ) );
      -- dbms_output.put_line('Error Message is ' || SQLERRM );
      RAISE;
END;
/
CREATE OR REPLACE EDITIONABLE TRIGGER "LHHCOM"."INVOICE_DETAIL_AUDIT_BEF_TRG" 

/**
----------------------------------------------------------------------
Project:     : Commissions Self Build Application               
Description  : Create Audit Trigger to insert rows whenever a new record
             : is added or an old one is updated or deleted
Author       : Jaco Bosman
Requirements : LHHCOM priviledges to account
Amendments   : 
Date        User     Change Description
========    ======== =================================================
28/08/2017  AMS       Re-Create Trigger 
*/

BEFORE INSERT OR UPDATE OR DELETE ON INVOICE_DETAIL

FOR EACH ROW

DECLARE

  gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';
  l_scope logger_logs.scope%type := 'CommissionsSelfBuild: ' || gc_scope_prefix;
  l_params logger.tab_param;
  aud INVOICE_DETAIL_AUDIT%ROWTYPE;
  
BEGIN    

  -- Setting the Transaction Description
  IF INSERTING THEN
    aud.transaction_desc := 'Created ' || :NEW.INVOICE_NO;
  ELSIF UPDATING THEN
    aud.transaction_desc := 'Changed record ' || :OLD.INVOICE_NO;
    IF :OLD.INVOICE_NO <> :NEW.INVOICE_NO THEN
      aud.transaction_desc := aud.transaction_desc || ', INVOICE_NO from ' ||
        :OLD.INVOICE_NO || ' to ' || :NEW.INVOICE_NO;
    END IF;
    
    IF :OLD.FEE_TYPE_ID_NO <> :NEW.FEE_TYPE_ID_NO THEN
      aud.transaction_desc := aud.transaction_desc || ', FEE_TYPE_ID_NO from ' ||
        :OLD.FEE_TYPE_ID_NO || ' to ' || :NEW.FEE_TYPE_ID_NO;
    END IF;
    
    IF :OLD.FEE_TYPE_AMT <> :NEW.FEE_TYPE_AMT THEN
      aud.transaction_desc := aud.transaction_desc || ', FEE_TYPE_AMT from ' ||
        :OLD.FEE_TYPE_AMT || ' to ' || :NEW.FEE_TYPE_AMT;
    END IF;
	
    IF :OLD.FEE_TYPE_EXCH_AMT <> :NEW.FEE_TYPE_EXCH_AMT THEN
      aud.transaction_desc := aud.transaction_desc || ', FEE_TYPE_EXCH_AMT from ' ||
        :OLD.FEE_TYPE_EXCH_AMT || ' to ' || :NEW.FEE_TYPE_EXCH_AMT;
    END IF;
    
    IF :OLD.FEE_TYPE_DESC <> :NEW.FEE_TYPE_DESC THEN
      aud.transaction_desc := aud.transaction_desc || ', FEE_TYPE_DESC from ' ||
        :OLD.FEE_TYPE_DESC || ' to ' || :NEW.FEE_TYPE_DESC;
    END IF;
        
  ELSIF DELETING THEN
    aud.transaction_desc := 'Deleted record ' || :OLD.INVOICE_NO;
  END IF;

  -- Setting the logger values in case
  logger.append_param(l_params, 'Action:', aud.transaction_desc);

  -- Setting the Audit row values
  IF INSERTING OR UPDATING THEN
    aud.INVOICE_NO                  := :NEW.INVOICE_NO;
    aud.FEE_TYPE_ID_NO		        := :NEW.FEE_TYPE_ID_NO;
    aud.FEE_TYPE_AMT                := :NEW.FEE_TYPE_AMT;
    aud.FEE_TYPE_DESC               := :NEW.FEE_TYPE_DESC;

  ELSIF DELETING THEN
    aud.INVOICE_NO                  := :OLD.INVOICE_NO;
    aud.FEE_TYPE_ID_NO              := :OLD.FEE_TYPE_ID_NO;
    aud.FEE_TYPE_AMT                := :OLD.FEE_TYPE_AMT;
    aud.FEE_TYPE_DESC               := :OLD.FEE_TYPE_DESC;
  
    -- In Case we don't want to allow deleting
    -- raise_application_error(-20001,'Deletion not supported on this table');
  ELSE
    raise_application_error(-20002,'Not INSERTING, UPDATING or DELETING. Please contact IT Support');
  END IF;
  
  -- Setting the Audit User and Date values
  aud.transaction_username := USER;
  aud.transaction_datetime := SYSDATE;

  -- Writing the Audit Record
  INSERT INTO INVOICE_DETAIL_AUDIT VALUES aud;

  EXCEPTION
    WHEN OTHERS THEN
      logger.log_error('Unhandled Exception', l_scope, null, l_params);
      -- dbms_output.put_line('Error Code is ' || TO_CHAR(SQLCODE ) );
      -- dbms_output.put_line('Error Message is ' || SQLERRM );
      RAISE;
END COMPANY_AUDIT_BEFORE_TRG;
/

insert into comms_calc_snapshot 
select country_code,
product_code,
poep_id,
person_code,
policy_code,
group_code,
broker_id_no,
company_id_no,
comms_perc,
contribution_date,
payment_receive_date,
finance_receipt_no,
calculation_datetime,
comms_calc_type_code,
payment_receive_amt,
comms_calculated_amt,
exchange_rate,
 exchange_rate_currency_code,
 comms_calculated_exch_amt,
invoice_no,
last_update_datetime,
username
from temp_comms_calc;

insert into invoice select invoice_no,
invoice_date,
payment_receive_date,
country_code,
company_id_no,
invoice_type_id_no,
release_date,
release_hold_reason,
payment_date,
payment_amt,
payment_exch_rate,
currency_code,
last_update_datetime,
username
from temp_invoice;

insert into invoice_detail
select invoice_no,
fee_type_id_no,
fee_type_amt,
fee_type_amt fee_type_exch_amt,
fee_type_desc,
last_update_datetime,
username
from temp_invoice_Detail;


commit;

CREATE OR REPLACE PACKAGE "LHHCOM"."COMMS_CALC_PKG" 

AS

/**
* <pre>
* ----------------------------------------------------------------------
* Project:     : Commission Self Build
*
*                Description  : Procedures and Functions used for the Commission Calculations
*                File Name    : Liberty\plsql\packages\lhhcom\comms_calc_pkg.sql
*                Author       : Jaco Bosman
*                Requirements : Access to account SCHEMA
*                Call Syntax  : Anonymous Block Example at the bottom of package header
*
*                Amendments   :
*                Date        User     Change Description
*                ========    ======== =================================================
*                2017/09/14  Sarel    Change the Comm Perc pick-up
*
* </pre>         */

PROCEDURE commissions_calc_run (pn_company_id_no IN  NUMBER
                               ,pv_country_code  IN  VARCHAR2
                               ,pv_group_code    IN  VARCHAR2
                               ,pv_product_code  IN  VARCHAR2
                               ,pv_return_msg    OUT VARCHAR2);

PROCEDURE approve_comms_run    (pn_company_id_no IN  NUMBER
                               ,pv_country_code  IN  VARCHAR2
                               ,pv_group_code    IN  VARCHAR2
                               ,pv_product_code  IN  VARCHAR2
                               ,pv_return_msg    OUT VARCHAR2);

PROCEDURE execute_payment_run  (pn_invoice_no    IN  NUMBER
                               ,pn_company_id_no IN  NUMBER
                               ,pv_country_code  IN  VARCHAR2
                               ,pv_username      IN  VARCHAR2
                               ,pv_return_msg    OUT VARCHAR2);

-- * Example of Procedures executed in an anonymous block (auto-commit data)
-- * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
/*

DECLARE
  l_return_msg VARCHAR2(100);
BEGIN
-- To Run for a Company
--  comms_calc_pkg.commissions_calc_run(1000, NULL, NULL, NULL, l_return_msg);
--  dbms_output.put_line('Block - ' || l_return_msg);
-- To Run for a Country
--  comms_calc_pkg.commissions_calc_run(NULL, 'LS', NULL, NULL, l_return_msg);
--  dbms_output.put_line('Block - ' || l_return_msg);
-- To Run for a Group
--  comms_calc_pkg.commissions_calc_run(NULL, NULL, 'M2M', NULL, l_return_msg);
--  dbms_output.put_line('Block - ' || l_return_msg);
-- To Run for a Product
--  comms_calc_pkg.commissions_calc_run(NULL, NULL, NULL, 'LSCL', l_return_msg);
--  dbms_output.put_line('Block - ' || l_return_msg);
-- To Run for all records
  comms_calc_pkg.commissions_calc_run(NULL, NULL, NULL, NULL, l_return_msg);
  dbms_output.put_line('Block - ' || l_return_msg);
END;

-- */

END COMMS_CALC_PKG;
/


CREATE OR REPLACE PACKAGE BODY COMMS_CALC_PKG

  AS

/**
  * Contains Prcedures that calculate commission
  * @parameters
  *     p_commit        auto commits data to the database at the end of 
  *                     each procedure
  * */
  
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

PROCEDURE commissions_calc_run (pn_company_id_no IN  NUMBER
                               ,pv_country_code  IN  VARCHAR2
                               ,pv_group_code    IN  VARCHAR2
                               ,pv_product_code  IN  VARCHAR2
                               ,pv_return_msg    OUT VARCHAR2)

IS

  gc_scope_prefix       CONSTANT VARCHAR2(31)           
                                 := lower($$PLSQL_UNIT) || '.';
  l_scope                        logger_logs.scope%TYPE 
                                 := 'CommissionsSelfBuild: ' || gc_scope_prefix;
  l_params                       logger.tab_param;

  ccs                            comms_calc_snapshot%ROWTYPE;
  lv_poli_id                     ohi_policies.poli_id%TYPE;
  lv_inse_id                     ohi_insured_entities.inse_id%TYPE;
  lv_enpr_id                     ohi_products.enpr_id%TYPE;
  lv_grac_id                     ohi_groups.grac_id%TYPE;
  lv_poep_id                     ohi_enrollment_products.poep_id%TYPE;
  lv_pogr_id                     ohi_policy_groups.pogr_id%TYPE;
  lv_broker_id                   ohi_policy_brokers.broker_id_no%TYPE;
  lv_company_id                  ohi_policy_brokers.company_id_no%TYPE;
  lv_country_code                company_country.country_code%TYPE;
  lv_comm_perc                   ohi_comm_perc.comm_perc%TYPE;
  lv_processed_desc              comms_payments_received.processed_desc%TYPE;
  lv_processed_cnt               NUMBER(5);
  lv_processed_success           NUMBER(5);
  lv_pref_curr_required          VARCHAR2(1);
  lv_currency_code               comms_calc_snapshot.exchange_rate_currency_code%TYPE;
  ln_exch_rate                   comms_calc_snapshot.exchange_rate%TYPE;
  lv_exch_currency_code          comms_calc_snapshot.exchange_rate_currency_code%TYPE;
  ln_pref_curr_id                NUMBER(9);
  l_percentage                   ohi_comm_perc.comm_perc%type;
  l_description                  ohi_comm_perc.comm_desc%type;
  l_return_msg                   VARCHAR2(500);
  E_NO_PREF_CUR                  EXCEPTION;

  CURSOR c_get_payments_to_calc IS
    SELECT ROWID,
           application_id,
           group_code,
           country_code,
           product_code,
           policy_code,
           person_code,
           contribution_date,
           finance_receipt_no,
           finance_receipt_date,
           finance_receipt_amt
      FROM comms_payments_received
     WHERE processed_ind IN ('N', 'TY', 'TF')
       AND country_code = NVL(upper(pv_country_code), country_code)
       AND product_code = NVL(pv_product_code, product_code)
       AND group_code = NVL(pv_group_code, group_code)
     ORDER BY contribution_date;

	CURSOR c_check_currency_code IS	
      select 'Y' ind        
      from company c,            
            (select distinct bf.company_id_no, btt.company_table_type_desc, bf.effective_start_date,       
             rank() over (partition by bf.company_id_no order by bf.effective_start_date desc) rank_no        
               from company_function bf, company_table bt, company_table_type btt              
              where bf.company_table_id_no = bt.company_table_id_no              
                and bf.company_table_id_no = 6            
                and bf.company_table_type_id_no = btt.company_table_type_id_no              
                and sysdate between bf.effective_start_date and bf.effective_end_date ) b_multi_net   
      where  c.company_id_no = b_multi_net.company_id_no(+)       
          and nvl(b_multi_net.rank_no,1) = 1
          and c.preferred_currency_code is null
		  and c.company_id_no = lv_company_id
          and b_multi_net.company_table_type_desc  = 'Y';

BEGIN
  lv_processed_cnt             := 0;
  lv_processed_success         := 0;
  FOR x IN c_get_payments_to_calc LOOP
    BEGIN
      -- Setting the logger values in case of errors
      logger.append_param(l_params, 'Action:', 'Application Id: '|| x.application_id);

      -- Initialize changing ccs record
      ccs.country_code         := NULL;
      ccs.product_code         := NULL;
  	  ccs.finance_receipt_no   := x.finance_receipt_no;
      ccs.poep_id              := NULL;
      ccs.person_code          := NULL;
      ccs.policy_code          := NULL;
      ccs.group_code           := NULL;
      ccs.broker_id_no         := NULL;
      ccs.company_id_no        := NULL;
      ccs.comms_perc           := NULL;
      ccs.contribution_date    := NULL;
      ccs.payment_receive_date := NULL;
      ccs.payment_receive_amt  := NULL;
      lv_processed_cnt         := lv_processed_cnt + 1;

      BEGIN -- Not Zero Amount Check
        IF x.finance_receipt_amt = 0 THEN
          raise_application_error(-20003,'Not Calculating Commission for Zero Amounts.');
        ELSE
          ccs.payment_receive_amt := x.finance_receipt_amt;
        END IF;
      END;  -- Not Zero Amount Check
   
      BEGIN -- Not NULL Finance Receipt No Check
        IF x.finance_receipt_no IS NULL THEN
          raise_application_error(-20005,'Not Calculating Commission for transactions without a Finance Receipt No.');
        ELSE
          ccs.finance_receipt_no := x.finance_receipt_no;
        END IF;
      END;  -- Not Zero Amount Check
   
      BEGIN -- Contribution Date Check
        ccs.contribution_date    := to_date(x.contribution_date);
        EXCEPTION
          WHEN OTHERS THEN
            UPDATE comms_payments_received 
               SET
                   processed_ind          = 'TF',
                   processed_desc         = 'Failed: Contribution Date - ' || x.contribution_date || ' is not a valid date.',
                   last_update_datetime   = SYSDATE,
                   username               = USER
             WHERE ROWID = x.rowid;
            dbms_output.put_line('Appl Id: '|| x.application_id || ' - CONTRIBUTION DATE ' || x.contribution_date || ' is not a valid date.');
            RAISE;
      END;  -- Contribution Date Check

      BEGIN -- Payment Received Date Check
        ccs.payment_receive_date := to_date(x.finance_receipt_date);
        EXCEPTION
          WHEN OTHERS THEN
            UPDATE comms_payments_received 
               SET
                   processed_ind          = 'TF',
                   processed_desc         = 'Failed: Payment Received Date ' || x.finance_receipt_date || ' is not a valid date.',
                   last_update_datetime   = SYSDATE,
                   username               = USER
             WHERE ROWID = x.rowid;
            dbms_output.put_line('Appl Id: '|| x.application_id || ' - PAYMENT RECEIVED DATE ' || x.finance_receipt_date || ' is not a valid date.');
            RAISE;
      END;  -- Payment Received Date Check

      BEGIN -- Policy Code Check
        lv_poli_id := NULL;
        SELECT MAX(poli_id) INTO lv_poli_id
          FROM ohi_policies
         WHERE policy_code = x.policy_code
         GROUP BY policy_code;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            UPDATE comms_payments_received 
               SET
                   processed_ind          = 'TF',
                   processed_desc         = 'Failed: Policy Code '|| x.policy_code || ' does not exist',
                   last_update_datetime   = SYSDATE,
                   username               = USER
             WHERE ROWID = x.rowid;
            dbms_output.put_line('Appl Id: '|| x.application_id || ' - POLICY_CODE '|| x.policy_code || ' does not exist.');
            RAISE;
      END;  -- Policy Code Check
      IF lv_poli_id > 0 THEN
        ccs.policy_code          := x.policy_code;
      END IF;
       
      BEGIN -- Person Code Check
        lv_inse_id := NULL;
        SELECT MAX(inse_id) INTO lv_inse_id
          FROM ohi_insured_entities
         WHERE inse_code = x.person_code
         GROUP BY inse_code;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            UPDATE comms_payments_received 
               SET
                   processed_ind          = 'TF',
                   processed_desc         = 'Failed: Person Code '|| x.person_code || ' does not exist',
                   last_update_datetime   = SYSDATE,
                   username               = USER
             WHERE ROWID = x.rowid;
            dbms_output.put_line('Appl Id: '|| x.application_id || ' - PERSON_CODE '|| x.person_code || ' does not exist.');
            RAISE;
      END;  -- Person Code Check
      IF lv_inse_id > 0 THEN
        ccs.person_code          := x.person_code;
      END IF;
       
      BEGIN -- Product Code Check
        lv_enpr_id := NULL;
        SELECT MAX(enpr_id) INTO lv_enpr_id
          FROM ohi_products
         WHERE product_code = x.product_code
         GROUP BY product_code;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            UPDATE comms_payments_received 
               SET
                   processed_ind          = 'TF',
                   processed_desc         = 'Failed: Product Code '|| x.product_code || ' does not exist',
                   last_update_datetime   = SYSDATE,
                   username               = USER
             WHERE ROWID = x.rowid;
            dbms_output.put_line('Appl Id: '|| x.application_id || ' - PRODUCT_CODE '|| x.product_code || ' does not exist.');
            RAISE;
      END;  -- Person Code Check
      IF lv_enpr_id > 0 THEN
        ccs.product_code         := x.product_code;
      END IF;

      BEGIN -- Group Code Check
        lv_grac_id := NULL;
        SELECT MAX(grac_id) INTO lv_grac_id
          FROM ohi_groups
         WHERE group_code = x.group_code
         GROUP BY group_code;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            UPDATE comms_payments_received 
               SET
                   processed_ind          = 'TF',
                   processed_desc         = 'Failed: Group Code '|| x.group_code || ' does not exist',
                   last_update_datetime   = SYSDATE,
                   username               = USER
             WHERE ROWID = x.rowid;
            dbms_output.put_line('Appl Id: '|| x.application_id || ' - GROUP_CODE '|| x.group_code || ' does not exist.');
            RAISE;
      END;  -- Group Code Check
      IF lv_grac_id > 0 THEN
        ccs.group_code           := x.group_code;
      END IF;

      BEGIN -- POEP Id Check (Could be linked even further)
        lv_poep_id := NULL;
        SELECT MAX(poep_id) INTO lv_poep_id
          FROM ohi_enrollment_products poep
          JOIN ohi_policy_enrollments  poen
            ON poen.poen_id = poep.poen_id
         WHERE poep.enpr_id = lv_enpr_id
           AND poen.inse_id = lv_inse_id
           AND x.contribution_date between poep.effective_start_date and poep.effective_end_date
         GROUP BY poen.inse_id, poep.enpr_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            UPDATE comms_payments_received 
               SET
                   processed_ind          = 'TF',
                   processed_desc         = 'Failed: Policy Enrollment Product record for ENPR '|| lv_enpr_id || ', INSE ' || lv_inse_id 
                                            || ' and Contr Dt ' || x.contribution_date || ' does not exist',
                   last_update_datetime   = SYSDATE,
                   username               = USER
             WHERE ROWID = x.rowid;
            dbms_output.put_line('Appl Id: '|| x.application_id || ' - POEP record for ENPR '|| lv_enpr_id || ', INSE ' || lv_inse_id 
                                            || ' and Contr Dt ' || x.contribution_date || ' does not exist.');
            RAISE;
      END;  -- POEP Id Check
      IF lv_poep_id > 0 THEN
        ccs.poep_id            := lv_poep_id;
      END IF;

      BEGIN -- Policy Groups Check
        lv_pogr_id := NULL;
        SELECT MAX(pogr_id) INTO lv_pogr_id
          FROM ohi_policy_groups       pogr
          JOIN ohi_policies            poli
            ON pogr.poli_id = poli.poli_id
          JOIN ohi_groups              grac
            ON pogr.grac_id = grac.grac_id
         WHERE poli.policy_code             = x.policy_code
           AND grac.group_code              = x.group_code
           AND x.contribution_date between pogr.effective_start_date and pogr.effective_end_date
         GROUP BY poli.policy_code, grac.group_code;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            UPDATE comms_payments_received 
               SET
                   processed_ind          = 'TF',
                   processed_desc         = 'Failed: Policy - Group link does not exist for Policy '|| x.policy_code 
                                            || ', Group ' || x.group_code || ' and Date ' || x.contribution_date,
                   last_update_datetime   = SYSDATE,
                   username               = USER
             WHERE ROWID = x.rowid;
            dbms_output.put_line('Appl Id: '|| x.application_id || ' - POGR record for Policy '|| x.policy_code || ', Group ' || x.group_code || 
                                 ' and Date ' || x.contribution_date || ' does not exist.');
            RAISE;
      END;  -- Policy Groups Check

      BEGIN -- Broker Id Check
        lv_broker_id := NULL;
        lv_company_id := NULL;
        SELECT MAX(company_id_no), MAX(broker_id_no) INTO lv_company_id, lv_broker_id
          FROM ohi_policy_brokers      pobr
          JOIN ohi_policies            poli
            ON pobr.poli_id = poli.poli_id
          JOIN ohi_policy_enrollments  poen
            ON pobr.poli_id = poen.poli_id
          JOIN ohi_insured_entities    inse
            ON poen.inse_id = inse.inse_id
          JOIN ohi_enrollment_products poep
            ON poen.poen_id = poep.poen_id
          JOIN ohi_policy_groups       pogr
            ON poli.poli_id = pogr.poli_id
           AND x.contribution_date between pogr.effective_start_date and pogr.effective_end_date
          JOIN ohi_groups              grac
            ON pogr.grac_id = grac.grac_id
          JOIN ohi_products            enpr
            ON poep.enpr_id                 = enpr.enpr_id
         WHERE poli.policy_code             = x.policy_code
           AND inse.inse_code               = x.person_code
           AND x.contribution_date between poep.effective_start_date and poep.effective_end_date
           AND grac.group_code              = x.group_code
           AND enpr.product_code            = x.product_code
         GROUP BY poli.policy_code, inse.inse_code, grac.group_code, enpr.product_code;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            UPDATE comms_payments_received 
               SET
                   processed_ind          = 'TF',
                   processed_desc         = 'Failed: Policy - Broker/Company link does not exist for Policy '|| x.policy_code 
                                            || ', Person ' || x.person_code || ', Group ' || x.group_code || ', Product ' || x.product_code 
                                            || ' and Date ' || x.contribution_date,
                   last_update_datetime   = SYSDATE,
                   username               = USER
             WHERE ROWID = x.rowid;
            dbms_output.put_line('Appl Id: '|| x.application_id || ' - POBR record for Policy '|| x.policy_code || ', Person ' || x.person_code 
                                            || ', Group ' || x.group_code || ', Product ' || x.product_code || ' and Date ' || x.contribution_date || ' does not exist.');
            RAISE;
      END;  -- Broker Id Check

      IF lv_broker_id > 0 THEN
        BEGIN -- Company Id Check
          ccs.broker_id_no       := lv_broker_id;
          IF 0 < length(lv_company_id) THEN
            NULL;
          ELSE
            BEGIN
              SELECT MAX(company_id_no) INTO lv_company_id
                FROM broker
               WHERE broker_id_no             = lv_broker_id
               GROUP BY broker_id_no;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  UPDATE comms_payments_received 
                     SET
                         processed_ind          = 'TF',
                         processed_desc         = 'Failed: Broker ' || lv_broker_id || ' does not link to a valid Company',
                         last_update_datetime   = SYSDATE,
                         username               = USER
                   WHERE ROWID = x.rowid;
                  dbms_output.put_line('Appl Id: ' || x.application_id || ' - Broker ' || lv_broker_id || ' does not link to a valid Company.');
                  RAISE;
            END;
          END IF;
        END; -- Company Id Check
      END IF;
      IF lv_company_id > 0 THEN
        IF lv_company_id != NVL(pn_company_id_no, lv_company_id) THEN
          raise_application_error(-20006,'Not Calculating Commission for this Company.');
        END IF;
        ccs.company_id_no         := lv_company_id;
        IF 0 < length(lv_broker_id) THEN
          NULL;
        ELSE
          BEGIN
            lv_broker_id              := get_broker_from_comp(lv_company_id);
            ccs.broker_id_no          := lv_broker_id;
          END;
        END IF;
      END IF;

      BEGIN -- Company Country Check
        lv_country_code := NULL;
        SELECT MAX(country_code) INTO lv_country_code
          FROM company_country
         WHERE company_id_no = lv_company_id
           AND country_code = x.country_code
           AND x.contribution_date between effective_start_date and effective_end_date
         GROUP BY company_id_no, country_code;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            UPDATE comms_payments_received 
               SET
                   processed_ind          = 'TF',
                   processed_desc         = 'Failed: Company ' || lv_company_id || ' does not trade in Country' || x.country_code,
                   last_update_datetime   = SYSDATE,
                   username               = USER
             WHERE ROWID = x.rowid;
            dbms_output.put_line('Appl Id: '|| x.application_id || ' - COMPANY_COUNTRY record for Company '|| lv_company_id || ' and Country ' || x.country_code 
                                            || ' does not exist.');
            RAISE;
      END;  -- Company Country Check
      IF lv_country_code IS NOT NULL THEN
        ccs.country_code            := lv_country_code;
      END IF;
      
      BEGIN -- Exchange Rate Check
        lv_currency_code := NULL;
		lv_exch_currency_code := NULL;
		ln_exch_rate := null;
		
		OPEN c_check_currency_code;
		  FETCH c_check_currency_code into lv_pref_curr_required;
		CLOSE c_check_currency_code;
		
		IF lv_pref_curr_required IS NOT NULL THEN
		          raise_application_error(-20007,'No preferred currency set for brokerage.');
		END IF;		
		
        SELECT preferred_currency_code INTO lv_currency_code
          FROM company
         WHERE company_id_no = lv_company_id;
		 dbms_output.put_line('lv_currency_code: '||lv_currency_code);
	
    	IF lv_currency_code IS NOT NULL THEN
		     SELECT prefcur_id INTO ln_pref_curr_id
               FROM POL_POLICIES_V@POLICIES.LIBERTY.CO.ZA
              WHERE tec_ind_last_version = 'Y'
                AND code = ccs.policy_code;
				
			
			IF ln_pref_curr_id IS NULL THEN
			    SELECT prefcur_id INTO ln_pref_curr_id
                 FROM POL_GROUP_ACCOUNTS_V@POLICIES.LIBERTY.CO.ZA a
                WHERE object_version_number = (SELECT MAX(object_version_number)
                                                FROM POL_GROUP_ACCOUNTS_V@POLICIES.LIBERTY.CO.ZA
                                                WHERE a.code = code)
                  AND code = ccs.group_code;
			END IF;
			
		    IF ln_pref_curr_id IS NOT NULL THEN
                  SELECT e.rate,  c_to.code to_currency_code  INTO ln_exch_rate, lv_exch_currency_code
                  FROM OHI_CLAIMS_VIEWS_OWNER.OHI_CURRENCIES_V@CLAIMS.LIBERTY.CO.ZA c_from,    
                        OHI_CLAIMS_VIEWS_OWNER.OHI_EXCHANGE_RATES_V@CLAIMS.LIBERTY.CO.ZA e,    
                        OHI_CLAIMS_VIEWS_OWNER.OHI_CURRENCIES_V@CLAIMS.LIBERTY.CO.ZA c_to    
                  WHERE e.curr_id_from = c_from.id    
                    AND e.curr_id_to = c_to.id
                    AND e.rate_context is null
                    AND c_from.id = ln_pref_curr_id
                    AND c_to.code = lv_currency_code
                    AND ccs.payment_receive_date BETWEEN e.start_date AND NVL(e.end_Date,TRUNC(SYSDATE));
                 
				 IF ln_exch_rate IS NULL THEN
                        RAISE E_NO_PREF_CUR;
                 END IF;				   
		     ELSE
		        RAISE E_NO_PREF_CUR;
		     END IF;				
			
			ccs.exchange_rate := ln_exch_rate;
			ccs.exchange_rate_currency_code := lv_exch_currency_code;
		 ELSE
		    ccs.exchange_rate := 1;
			ccs.exchange_rate_currency_code := lv_currency_code;
		 END IF;
		 
        EXCEPTION
		  WHEN E_NO_PREF_CUR THEN
            UPDATE comms_payments_received 
               SET
                   processed_ind          = 'TF',
                   processed_desc         = 'Failed: No preferred currency found on OHI for the group or policy' ,
                   last_update_datetime   = SYSDATE,
                   username               = USER
             WHERE ROWID = x.rowid;
            dbms_output.put_line('Appl Id: '|| x.application_id || ' - No preferred currency found on OHI for the group or policy '|| lv_company_id );		  
		  RAISE;
          WHEN NO_DATA_FOUND THEN
            UPDATE comms_payments_received 
               SET
                   processed_ind          = 'TF',
                   processed_desc         = 'Failed: Current exchange rate for Brokerage ' || lv_company_id || ' and currency code '||lv_currency_code||' does not exist on OHI',
                   last_update_datetime   = SYSDATE,
                   username               = USER
             WHERE ROWID = x.rowid;
            dbms_output.put_line('Appl Id: '|| x.application_id ||' Current exchange rate for Brokerage' || lv_company_id || ' and currency code '||lv_currency_code||' does not exist on OHI');
            RAISE;
      END;  -- Exchange Rate Check
	  
      IF lv_country_code IS NOT NULL THEN
        ccs.country_code            := lv_country_code;
      END IF;
      -- Deciding on the Commission Percentage
      lv_comm_perc            := NULL;
      commissions_pkg.get_percentage(p_date => to_date(x.contribution_date)
                                    ,p_poep => lv_poep_id
                                    ,p_percentage => l_percentage
                                    ,p_description => l_description
                                    ,p_return_msg => l_return_msg);
      IF l_percentage IS NOT NULL THEN
        ccs.comms_perc         := ROUND(l_percentage, 2);
        lv_processed_desc      := l_return_msg;
      ELSE
        dbms_output.put_line('Appl Id: '|| x.application_id || ' - No Commission Percentage found for Any Combination. ' || lv_processed_desc);
        raise_application_error(-20004,'No Commission Percentage found for Any Combination.');
      END IF;
      -- Setting the rest of the Values
      ccs.comms_calculated_amt := ccs.payment_receive_amt * ccs.comms_perc / 100;
	  ccs.comms_calculated_exch_amt := ccs.comms_calculated_amt * ccs.exchange_rate;
      ccs.calculation_datetime := SYSDATE;
      ccs.comms_calc_type_code := 'T';
      ccs.invoice_no           := NULL;
      ccs.last_update_datetime := SYSDATE;
      ccs.username             := USER;
      dbms_output.put_line('Appl Id: '|| x.application_id || ' - Record: ' || 'coun' || ccs.country_code || ' prod' ||  ccs.product_code 
                                      || ' poep' ||  ccs.poep_id || ' inse' ||  ccs.person_code || ' poli' ||  ccs.policy_code || ' grac' 
                                      ||  ccs.group_code || ' brok' ||  ccs.broker_id_no || ' comp' ||  ccs.company_id_no || ' perc' 
                                      ||  ccs.comms_perc || ' cdte' ||  ccs.contribution_date || ' pmnt' ||  ccs.payment_receive_amt 
                                      || ' camt' ||  ccs.comms_calculated_amt|| ' cant-exch' ||  ccs.comms_calculated_exch_amt
									  || ' exch' ||  ccs.exchange_rate|| ' exch-curr' ||  ccs.exchange_rate_currency_code);

      -- Writing the Values to Comms Payments Received
      INSERT INTO comms_calc_snapshot VALUES ccs;

      -- Update Comms Payments Received on Success
      UPDATE comms_payments_received 
         SET
             processed_ind          = 'TY',
             processed_desc         = lv_processed_desc,
             last_update_datetime   = SYSDATE,
             username               = USER
       WHERE ROWID = x.rowid;   
      lv_processed_success         := lv_processed_success + 1;
 
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
        -- dbms_output.put_line('Appl Id: '|| x.application_id || ' - No OHI Data Found.');
      WHEN DUP_VAL_ON_INDEX THEN
        dbms_output.put_line('Appl Id: '|| x.application_id || ' - Duplicate Value on Index.');
        UPDATE comms_payments_received 
           SET
               processed_ind          = 'TF',
               processed_desc         = 'Failed: Record combination already exists',
               last_update_datetime   = SYSDATE,
               username               = USER
         WHERE ROWID = x.rowid;   
      WHEN OTHERS THEN
        IF SQLCODE = -20003 THEN
          dbms_output.put_line('Appl Id: '|| x.application_id || ' - Zero Amounts are not Processed.');
          UPDATE comms_payments_received 
             SET
                 processed_ind          = 'TY',
                 processed_desc         = 'Failed: Zero amounts are not processed',
                 last_update_datetime   = SYSDATE,
                 username               = USER
           WHERE ROWID = x.rowid;
        ELSIF SQLCODE = -20004 THEN
          -- dbms_output.put_line('Appl Id: '|| x.application_id || ' - No Commission Percentage found for Any Combination.');
          UPDATE comms_payments_received 
             SET
                 processed_ind          = 'TF',
                 processed_desc         = 'Failed: No Commission Percentage found for Any Combination.',
                 last_update_datetime   = SYSDATE,
                 username               = USER
           WHERE ROWID = x.rowid;
        ELSIF SQLCODE = -20005 THEN
          dbms_output.put_line('Appl Id: '|| x.application_id || ' - Not Calculating Commission for transactions without a Finance Receipt No.');
          UPDATE comms_payments_received 
             SET
                 processed_ind          = 'TF',
                 processed_desc         = 'Failed: Not Calculating Commission for transactions without a Finance Receipt No.',
                 last_update_datetime   = SYSDATE,
                 username               = USER
           WHERE ROWID = x.rowid;
        ELSIF SQLCODE = -20006 THEN
          lv_processed_cnt     := lv_processed_cnt - 1;
          dbms_output.put_line('Appl Id: '|| x.application_id || ' - Calculating Commission for a different Company.');
        ELSIF SQLCODE = -20007 THEN
          dbms_output.put_line('Appl Id: '|| x.application_id || ' - No preferred currency set for brokerage.');
          UPDATE comms_payments_received 
             SET
                 processed_ind          = 'TF',
                 processed_desc         = 'Failed: Multinational Broker does not have a preferred currency set.',
                 last_update_datetime   = SYSDATE,
                 username               = USER
           WHERE ROWID = x.rowid;
        ELSE
          dbms_output.put_line('Appl Id: '|| x.application_id || ' - Other Error: ' || sqlerrm);
          UPDATE comms_payments_received 
             SET
                 processed_ind          = 'TF',
                 processed_desc         = 'Failed: Unhandled exception error ocurred.',
                 last_update_datetime   = SYSDATE,
                 username               = USER
           WHERE ROWID = x.rowid;
        END IF;
    END;
  END LOOP;
  COMMIT;
  IF lv_processed_cnt = 0 THEN
    pv_return_msg := 'Nothing to process for Parameter set submitted';
  ELSIF lv_processed_success = 0 THEN
    pv_return_msg := 'None of the ' || lv_processed_cnt || ' records processed successfully';
  ELSIF lv_processed_success < lv_processed_cnt THEN
    dbms_output.put_line(lv_processed_success || ' out of ' || lv_processed_cnt || ' records processed successfully');
    -- pv_return_msg := lv_processed_success || ' out of ' || lv_processed_cnt || ' records processed successfully';
  ELSE
    dbms_output.put_line('All ' || lv_processed_cnt || ' records processed successfully');
    -- pv_return_msg := 'All ' || lv_processed_cnt || ' records processed successfully';
  END IF;
  dbms_output.put_line(pv_return_msg);
   
EXCEPTION
  WHEN OTHERS THEN
    logger.log_error('Unhandled Exception', l_scope, null, l_params);
    dbms_output.put_line(' - Unhandled Exception Error: ' || sqlerrm);
    ROLLBACK;
    pv_return_msg := 'System failed with error: ' || sqlerrm;
END commissions_calc_run;

/**********************************************************************************************************************/

PROCEDURE approve_comms_run    (pn_company_id_no IN  NUMBER
                               ,pv_country_code  IN  VARCHAR2
                               ,pv_group_code    IN  VARCHAR2
                               ,pv_product_code  IN  VARCHAR2
                               ,pv_return_msg    OUT VARCHAR2)

IS

  lv_error_msg                 VARCHAR2(500);
  ld_calculation_date          DATE;
  ln_invoice_no                invoice.invoice_no%TYPE;
  ln_total_invoice_line_amt    invoice_detail.fee_type_amt%TYPE;
  ln_total_invoice_exch_amt    invoice_detail.fee_type_exch_amt%TYPE;
  lv_hold_desc                 VARCHAR2(250);

  CURSOR c_approved_comms_header IS
    SELECT b.company_id_no, 
           cc.country_code, 
           cc.payment_receive_date, --this should be the date of receipt, not the contribution_date
		   cc.exchange_rate,
		   cc.EXCHANGE_RATE_CURRENCY_CODE,
           COUNT(*)
      FROM comms_calc_snapshot         cc, 
           broker                      b  
     WHERE cc.broker_id_no = b.broker_id_no
       AND comms_calc_type_code = 'P'
	   AND cc.group_code = nvl(pv_group_code, cc.group_code)
	   AND cc.product_code = nvl(pv_product_code, cc.product_code)
	   AND cc.country_code = nvl(pv_country_code, cc.country_code)
	   AND cc.company_id_no = nvl(pn_company_id_no, cc.company_id_no)
       AND calculation_datetime = ld_calculation_date
     GROUP BY b.company_id_no, 
              cc.country_code, 
              cc.payment_receive_date, --this should be the date of receipt, not the contribution_date
			  cc.exchange_rate,
		      cc.EXCHANGE_RATE_CURRENCY_CODE;
    
  CURSOR c_approved_comms_detail (pn_company_id_no NUMBER, 
                                  pv_country_code VARCHAR2, 
                                  pd_fin_receipt_date date) IS 
    SELECT cc.rowid, 
           comms_calculated_amt,
           comms_calculated_exch_amt
      FROM comms_calc_snapshot         cc, 
           broker                      b  
     WHERE cc.broker_id_no = b.broker_id_no
       AND comms_calc_type_code = 'P'
	   AND cc.group_code = nvl(pv_group_code, cc.group_code)
	   AND cc.product_code = nvl(pv_product_code, cc.product_code)
	   AND cc.country_code = nvl(pv_country_code, cc.country_code)
	   AND cc.company_id_no = nvl(pn_company_id_no, cc.company_id_no)
       AND payment_receive_date = pd_fin_receipt_date  --this should be the date of receipt, not the contribution_date
       AND calculation_datetime = ld_calculation_date;
     
BEGIN
  
        -- Update Comms Payments Received on Success
      UPDATE comms_payments_received 
         SET
             processed_ind          = 'Y',
             last_update_datetime   = SYSDATE,
             username               = USER
       WHERE processed_ind = 'TY'; 
       
  select max(calculation_datetime) into ld_calculation_date
    from COMMS_CALC_SNAPSHOT s
   where s.comms_calc_type_code = 'T'
   	 AND s.group_code = nvl(pv_group_code, s.group_code)
	 AND s.product_code = nvl(pv_product_code, s.product_code)
	 AND s.country_code = nvl(pv_country_code, s.country_code)
	 AND s.company_id_no = nvl(pn_company_id_no, s.company_id_no);
   
  update COMMS_CALC_SNAPSHOT s
     set comms_calc_type_code = 'P',
         last_update_datetime = SYSDATE,
         username = USER
   where calculation_datetime = ld_calculation_date
     AND s.group_code = nvl(pv_group_code, group_code)
	 AND s.product_code = nvl(pv_product_code, product_code)
	 AND s.country_code = nvl(pv_country_code, country_code)
	 AND s.company_id_no = nvl(pn_company_id_no, company_id_no);
								  
   if sql%notfound then
     raise no_data_found;
   END IF;
   
   for x IN c_approved_comms_header loop
     ln_invoice_no := invoice_no_seq.nextval();
     ln_total_invoice_line_amt := 0;
     ln_total_invoice_exch_amt := 0;
	 lv_hold_desc := get_invoice_hold_reason(x.company_id_no,x.country_code,x.payment_receive_date,null);
	 
     insert into invoice (invoice_no,
                          invoice_date,
                          payment_receive_date,
                          country_code,
                          company_id_no,
                          invoice_type_id_no,
                          release_date,
                          release_hold_reason,
                          payment_date,
                          payment_amt,
                          payment_exch_rate,
                          currency_code,
                          last_update_datetime,
                          username)
                  values (ln_invoice_no,
                          trunc(SYSDATE),
                          x.payment_receive_date,
                          x.country_code,
                          x.company_id_no,
						  1, --comms run
                          null,
                          lv_hold_desc,
                          null,
                          null,
                          x.exchange_rate,
		                  x.EXCHANGE_RATE_CURRENCY_CODE,
                          SYSDATE,
                          USER);
                          
     for y IN c_approved_comms_detail (x.company_id_no, x.country_code, x.payment_receive_date) loop
       ln_total_invoice_line_amt := ln_total_invoice_line_amt+y.comms_calculated_amt;
       ln_total_invoice_exch_amt := ln_total_invoice_exch_amt+y.comms_calculated_exch_amt;
	   
       update COMMS_CALC_SNAPSHOT
          set invoice_no = ln_invoice_no,
              last_update_datetime = SYSDATE,
              username = USER
        where rowid = y.rowid;
        
		begin
        insert into invoice_detail (invoice_no,
                                    fee_type_id_no,
                                    fee_type_amt,
									fee_type_exch_amt,
                                    fee_type_desc,
                                    last_update_datetime,
                                    username)
						    values (ln_invoice_no,
                                    1,
                                    y.comms_calculated_amt,
									y.comms_calculated_exch_amt,
                                    'Commissions',
                                    SYSDATE,
                                    USER);
		 exception 
		   when dup_val_on_index then
		     update invoice_detail
			    set fee_type_amt = fee_type_amt+y.comms_calculated_amt,
				    fee_type_exch_amt = fee_type_exch_amt+y.comms_calculated_exch_amt
			 where invoice_no = ln_invoice_no
			   and fee_type_id_no = 1;
		 end;
     END LOOP;
	 
	 update invoice  
	    set payment_amt = ln_total_invoice_exch_amt
	  where invoice_no = ln_invoice_no;	
	  
   END LOOP;
   
   commit;
   
   pv_return_msg := null;
   
EXCEPTION
  WHEN no_data_found then
    pv_return_msg := 'No Records found for posting';
  WHEN others then
     rollback;
     dbms_output.put_line('Error: '||sqlerrm);
	 pv_return_msg := 'System failed with error: '||sqlerrm;
END approve_comms_run;

/**********************************************************************************************************************/

PROCEDURE execute_payment_run  (pn_invoice_no    IN  NUMBER
                               ,pn_company_id_no IN  NUMBER
                               ,pv_country_code  IN  VARCHAR2
                               ,pv_username      IN  VARCHAR2
                               ,pv_return_msg    OUT VARCHAR2)

IS

lv_hold_reason_desc              VARCHAR2(250);
ld_release_date                  DATE := SYSDATE;

cursor c_get_invoice is
  select invoice_no, company_id_no, country_code, payment_receive_date
  from invoice
  where release_Date is null
    AND invoice_no = nvl(pn_invoice_no,invoice_no)
    AND country_code = nvl(pv_country_code,country_code)
    AND company_id_no = nvl(pn_company_id_no, company_id_no);

BEGIN
    --get all invoices that has not been processed and loop through each record
   for x IN c_get_invoice loop
      --See if there is any reason why the invoice cannot be paid
      lv_hold_reason_desc := get_invoice_hold_reason(x.company_id_no,x.country_code,x.payment_receive_date, x.invoice_no);
	  
	  --If there is no reason to withold payment, update the invoice with todays date and stamp the invoice to be interfaced to fusion
	  if lv_hold_reason_desc is null then
	    update invoice  
	       set release_date = ld_release_date,
		       release_hold_reason = null,
		       last_update_datetime = SYSDATE,
			   username = pv_username
	     where invoice_no = x.invoice_no;

    	insert into dnld_invoice (invoice_no,
                                 stamp_datetime,
                                 stamp_ind,
                                 batch_no,
                                 last_update_datetime,
                                 username) 
		                 values (x.invoice_no,
						         SYSDATE,
								 'I',
								 0,
								 SYSDATE,
								 pv_username);	
	  else
	    --If there is a reason to withold payment, update the invoice record with the date and hold reason
	    update invoice  
	       set release_hold_reason = to_char(SYSDATE,'dd/MON/yyyy')||':'||lv_hold_reason_desc,
		       release_date = null,
		       last_update_datetime = SYSDATE,
			   username = pv_username
	     where invoice_no = x.invoice_no;	
	  END IF;
	 commit;
   END LOOP;
   
EXCEPTION
  WHEN others then
     rollback;
     dbms_output.put_line('Error: '||sqlerrm);
	 pv_return_msg := 'System failed with error: '||sqlerrm;
end execute_payment_run;

/**********************************************************************************************************************/

END COMMS_CALC_PKG;
/


create or replace FUNCTION get_invoice_hold_reason 
(p_company_id_no IN NUMBER,p_country_code IN VARCHAR2,p_date IN DATE, p_invoice_no IN NUMBER) RETURN VARCHAR2 IS v_char VARCHAR2 (250);
lv_msg     varchar2(250) := null;
lv_ind     varchar2(1)   := null;

cursor c_get_company_status is
  select decode(cf.company_table_type_id_no,25,'Y','N') ind, company_table_type_desc
    from company_function cf, company_table_type ctt
   where cf.company_Table_id_no = 2
     and cf.company_id_no = p_company_id_no
     and sysdate between cf.effective_start_date and cf.effective_end_date
     and cf.company_Table_id_no = ctt.company_Table_id_no
     and cf.company_table_type_id_no = ctt.company_table_type_id_no
   order by cf.last_update_datetime desc;

 --group  country hold  
cursor c_get_company_country is
  select hold_ind
    from company_country
   where company_id_no = p_company_id_no
     and country_code = p_country_code;
  
 --does not meet minimum payout amount
cursor c_get_min_pay_out_valid is
  select case
           when sum(id.fee_type_exch_amt) < cc.min_payout_amt then 'N'
         else 
          'Y'
         end ind,
		 i.country_code
    from invoice i, invoice_detail id, company_country cc
   where i.invoice_no = id.invoice_no
     and i.company_id_no = p_company_id_no
     and i. country_code = nvl(p_country_code,i.country_code)
     and i.release_date is null
     and i.release_hold_reason is null
     and i.company_id_no = cc.company_id_no
     and i.country_code = cc.country_code
   group by i.country_code,cc.min_payout_amt; 
 --group hold
cursor c_get_ohi_group is
  select 'N' hold_ind, 'Group: '||og.group_code||' is currently on hold.' msg
    from Comms_Calc_Snapshot c, ohi_groups og
   where invoice_no = p_invoice_no
     and c.contribution_date = p_date
     and c.group_code = og.group_code
     and c.contribution_date between og.effective_Start_date and og.effective_end_date;
  
 --product country hold
cursor c_get_ohi_product is
  select 'N' hold_ind, 'Product: '||product_name||' is currently on hold.' msg
    from Comms_Calc_Snapshot c, ohi_products og
   where invoice_no = p_invoice_no
     and c.contribution_date = p_date
     and c.product_code = og.product_code;
	 
 --SA only needs to have valid accredidation based on contribution date
cursor c_get_accred is
  select 'Y'
    from Company_Accreditation
   where p_date between company_accred_start_date and company_accred_end_date
     and company_id_no = p_company_id_no
     and country_code = p_country_code
	 and accreditation_type_id_no = 1;
  
BEGIN

   open c_get_company_status;
     fetch c_get_company_status into lv_ind, lv_msg;
   close c_get_company_status;
   
   if lv_ind = 'N' then
     v_char := 'Brokerage is currently in '||lv_msg||' status';
   end if;
  
   lv_ind := null;
   lv_msg := null;
   open c_get_company_country;
     fetch c_get_company_country into lv_ind;
   close c_get_company_country; 

   if lv_ind = 'Y' then
     v_char := 'Country is currently on hold';
   end if;
   
   lv_ind := null;
   lv_msg := null;
   open c_get_ohi_group;
     fetch c_get_ohi_group into lv_ind,lv_msg;
   close c_get_ohi_group;
  
   if lv_ind <> 'N' then
     v_char := lv_msg;
   end if;

   lv_ind := null;
   lv_msg := null;
   open c_get_ohi_product;
     fetch c_get_ohi_product into lv_ind,lv_msg;
   close c_get_ohi_product;
  
   if lv_ind <> 'N' then
     v_char := lv_msg;
   end if;  

   lv_ind := null;
   lv_msg := null;
   open c_get_min_pay_out_valid;
     fetch c_get_min_pay_out_valid into lv_ind,lv_msg;
   close c_get_min_pay_out_valid;
  
   if lv_ind = 'N' then --The cursor can return Y,N or nothing, therefore check if the lv_ind = 'N'. Otherwise if the cursor returns nothing, the check will still occur
     v_char := 'Total outstanding payments does not meet the minimum payout amount for country '||lv_msg; 
   end if;     
   
   lv_ind := null;
   lv_msg := null;
   if p_country_code = 'ZA' then
     open c_get_accred;
	   fetch c_get_accred into lv_ind;
     close c_get_accred;
	 
	 if lv_ind <> 'Y' then   --The cursor only returns a Y or nothing, therefore check if the lv_ind <> 'Y'.
	   v_char := 'Brokerage does not have a valid accreditation';
	 end if;
   end if;
   
  RETURN v_char;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
   v_char := NULL;
END;
/

/*drop table temp_comms_calc;
drop table temp_invoice;
drop table temp_invoice_Detail;*/