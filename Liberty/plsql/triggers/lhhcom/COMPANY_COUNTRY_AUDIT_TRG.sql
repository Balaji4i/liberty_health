create or replace TRIGGER "LHHCOM"."COMPANY_COUNTRY_AUDIT_TRG" 

/**
----------------------------------------------------------------------
Project:     : Commissions Self Build Application               
Description  : Create Audit Trigger to insert rows whenever a new record
             : is added or an old one is updated or deleted
Author       : Sarel Eybers
Requirements : LHHCOM priviledges to account
Amendments   : 
Date        User       Change Number   Change Description
========    ========   =============   =================================================
27/07/2017  SE                         Create Trigger 
06/04/2018  SE                         Make Changes for DNLD_COMPANY
06/04/2018  SE                         Make Changes for transaction_desc < 550 characters
05/06/2018  SE                         Allow for multiple Company Changes per day to trigger DNLD_COMPANY
12/09/2048  TP          1.1            Set l_dnld variable to 'U' remove concate as resulting in error
29/01/2019  SE                         Ensure that Audit records only get written if something worth auditing changes
*/

BEFORE INSERT OR UPDATE OR DELETE ON COMPANY_COUNTRY

FOR EACH ROW

DECLARE

  gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';
  l_scope logger_logs.scope%type := 'CommissionsSelfBuild: ' || gc_scope_prefix;
  l_params logger.tab_param;
  l_dnld VARCHAR(1);
  aud COMPANY_COUNTRY_AUDIT%ROWTYPE;
  l_write_aud VARCHAR(1);
  
BEGIN    

  l_write_aud := 'N';
  -- Setting the Transaction Description
  IF INSERTING THEN
    aud.transaction_desc := 'Created ' || :NEW.company_id_no ||' for COUNTRY_CODE:'||      :NEW.country_code;
    l_dnld := 'I';
    l_write_aud := 'Y';
  ELSIF UPDATING THEN
    aud.transaction_desc := 'Changed record ' || :OLD.company_id_no ||' for COUNTRY_CODE:'||  
      :OLD.country_code;
    IF :OLD.company_id_no <> :NEW.company_id_no OR 
      (:OLD.company_id_no IS NULL AND :NEW.company_id_no IS NOT NULL) OR 
      (:OLD.company_id_no IS NOT NULL AND :NEW.company_id_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', COMPANY_ID_NO from ' ||
        :OLD.company_id_no || ' to ' || :NEW.company_id_no, 1, 550);
      l_dnld := 'B';
      l_write_aud := 'Y';
    END IF;
    IF :OLD.country_code <> :NEW.country_code OR 
      (:OLD.country_code IS NULL AND :NEW.country_code IS NOT NULL) OR 
      (:OLD.country_code IS NOT NULL AND :NEW.country_code IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', COUNTRY_CODE from ' ||
        :OLD.country_code || ' to ' || :NEW.country_code, 1, 550);
      l_dnld := SUBSTR(l_dnld || 'U', 1, 1);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.min_payout_amt <> :NEW.min_payout_amt OR 
      (:OLD.min_payout_amt IS NULL AND :NEW.min_payout_amt IS NOT NULL) OR 
      (:OLD.min_payout_amt IS NOT NULL AND :NEW.min_payout_amt IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', MIN_PAYOUT_AMT from ' ||
        :OLD.min_payout_amt || ' to ' || :NEW.min_payout_amt, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.hold_ind <> :NEW.hold_ind OR 
      (:OLD.hold_ind IS NULL AND :NEW.hold_ind IS NOT NULL) OR 
      (:OLD.hold_ind IS NOT NULL AND :NEW.hold_ind IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', HOLD_IND from ' ||
        :OLD.hold_ind || ' to ' || :NEW.hold_ind, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.effective_start_date <> :NEW.effective_start_date OR 
      (:OLD.effective_start_date IS NULL AND :NEW.effective_start_date IS NOT NULL) OR 
      (:OLD.effective_start_date IS NOT NULL AND :NEW.effective_start_date IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', EFFECTIVE_START_DATE from ' ||
        :OLD.effective_start_date || ' to ' || :NEW.effective_start_date, 1, 550);
      l_dnld := SUBSTR(l_dnld || 'U', 1, 1);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.effective_end_date <> :NEW.effective_end_date OR 
      (:OLD.effective_end_date IS NULL AND :NEW.effective_end_date IS NOT NULL) OR 
      (:OLD.effective_end_date IS NOT NULL AND :NEW.effective_end_date IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', EFFECTIVE_END_DATE from ' ||
        :OLD.effective_end_date || ' to ' || :NEW.effective_end_date, 1, 550);
      l_dnld := SUBSTR(l_dnld || 'U', 1, 1);
      l_write_aud := 'Y';
    END IF;
  ELSIF DELETING THEN
    aud.transaction_desc := 'Deleted record ' || :OLD.company_id_no || 
      :OLD.country_code;
    l_dnld := 'D';
    l_write_aud := 'Y';
  END IF;

  -- Setting the logger values in case
  logger.append_param(l_params, 'Action:', aud.transaction_desc);

  -- Setting the Audit row values
  IF INSERTING OR UPDATING THEN
    aud.company_id_no                    := :NEW.company_id_no;
    aud.country_code                     := :NEW.country_code;
    aud.min_payout_amt                   := :NEW.min_payout_amt;
    aud.hold_ind                         := :NEW.hold_ind;
    aud.effective_start_date             := :NEW.effective_start_date;
    aud.effective_end_date               := :NEW.effective_end_date;
  ELSIF DELETING THEN
    aud.company_id_no                    := :OLD.company_id_no;
    aud.country_code                     := :OLD.country_code;
    aud.min_payout_amt                   := :OLD.min_payout_amt;
    aud.hold_ind                         := :OLD.hold_ind;
    aud.effective_start_date             := :OLD.effective_start_date;
    aud.effective_end_date               := :OLD.effective_end_date;
    -- In Case we don't want to allow deleting
    -- raise_application_error(-20001,'Deletion not supported on this table');
  ELSE
    raise_application_error(-20002,'Not INSERTING, UPDATING or DELETING. Please contact IT Support');
  END IF;
  
  -- Setting the Audit User and Date values
  aud.transaction_username := :NEW.USERNAME;
  aud.transaction_datetime := SYSDATE;

  -- Writing the Audit Record
  IF l_write_aud = 'Y' THEN
    INSERT INTO COMPANY_COUNTRY_AUDIT VALUES aud;
  END IF;

  -- Writing the DNLD_COMPANY Record
  BEGIN
    CASE l_dnld
      WHEN 'I' THEN 
        INSERT INTO dnld_company
                   (interf_system_id_no
                   ,company_id_no
                   ,stamp_datetime
                   ,stamp_ind
                   ,batch_no
                   ,last_update_datetime
                   ,username)
            VALUES (2
                   ,:NEW.company_id_no
                   ,trunc(sysdate)
                   ,'I'
                   ,0
                   ,sysdate
                   ,user);
      WHEN 'U' THEN
        INSERT INTO dnld_company
                   (interf_system_id_no
                   ,company_id_no
                   ,stamp_datetime
                   ,stamp_ind
                   ,batch_no
                   ,last_update_datetime
                   ,username)
            VALUES (2
                   ,:NEW.company_id_no
                   ,trunc(sysdate)
                   ,'U'
                   ,0
                   ,sysdate
                   ,user);
      WHEN 'D' THEN
        INSERT INTO dnld_company
                   (interf_system_id_no
                   ,company_id_no
                   ,stamp_datetime
                   ,stamp_ind
                   ,batch_no
                   ,last_update_datetime
                   ,username)
            VALUES (2
                   ,:OLD.company_id_no
                   ,trunc(sysdate)
                   ,'D'
                   ,0
                   ,sysdate
                   ,user);
      WHEN 'B' THEN
        BEGIN
          INSERT INTO dnld_company
                     (interf_system_id_no
                     ,company_id_no
                     ,stamp_datetime
                     ,stamp_ind
                     ,batch_no
                     ,last_update_datetime
                     ,username)
              VALUES (2
                     ,:NEW.company_id_no
                     ,trunc(sysdate)
                     ,'U'
                     ,0
                     ,sysdate
                     ,user);
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            NULL;
        END;
        INSERT INTO dnld_company
                   (interf_system_id_no
                   ,company_id_no
                   ,stamp_datetime
                   ,stamp_ind
                   ,batch_no
                   ,last_update_datetime
                   ,username)
            VALUES (2
                   ,:OLD.company_id_no
                   ,trunc(sysdate)
                   ,'U'
                   ,0
                   ,sysdate
                   ,user);
      ELSE NULL;
    END CASE;
  EXCEPTION 
    WHEN DUP_VAL_ON_INDEX THEN
      NULL;
  END;
   
EXCEPTION
  WHEN OTHERS THEN
    logger.log_error('Unhandled Exception', l_scope, null, l_params);
    -- dbms_output.put_line('Error Code is ' || TO_CHAR(SQLCODE ) );
    -- dbms_output.put_line('Error Message is ' || SQLERRM );
    RAISE;

END COMPANY_COUNTRY_AUDIT_TRG;