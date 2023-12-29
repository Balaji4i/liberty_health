CREATE OR REPLACE EDITIONABLE TRIGGER "LHHCOM"."BROKER_ACCREDITAT_AUD_BEF_TRG"

/**
----------------------------------------------------------------------
Project:     : Commissions Self Build Application               
Description  : Create Audit Trigger to insert rows whenever a new record
             : is added or an old one is updated or deleted
Author       : Sarel Eybers
Requirements : LHHCOM priviledges to account
Amendments   : 
Date        User     Change Description
========    ======== =================================================
09/04/2017  SE       Create Trigger 
29/01/2019  SE       Ensure that Audit records only get written if something worth auditing changes
*/

BEFORE INSERT OR UPDATE OR DELETE ON BROKER_ACCREDITATION

FOR EACH ROW

DECLARE

  gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';
  l_scope logger_logs.scope%type := 'CommissionsSelfBuild: ' || gc_scope_prefix;
  l_params logger.tab_param;
  aud BROKER_ACCREDITATION_AUDIT%ROWTYPE;
  l_write_aud VARCHAR(1);
  
BEGIN    

  l_write_aud := 'N';
  -- Setting the Transaction Description
  IF INSERTING THEN
    aud.transaction_desc := 'Created ' || :NEW.broker_id_no;
    l_write_aud := 'Y';
  ELSIF UPDATING THEN
    aud.transaction_desc := 'Changed record ' || :OLD.broker_id_no;
    IF :OLD.broker_id_no <> :NEW.broker_id_no OR
      (:OLD.broker_id_no IS NULL AND :NEW.broker_id_no IS NOT NULL) OR
      (:OLD.broker_id_no IS NOT NULL AND :NEW.broker_id_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', BROKER_ID_NO from ' ||
        :OLD.broker_id_no || ' to ' || :NEW.broker_id_no, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.effective_start_date <> :NEW.effective_start_date OR
      (:OLD.effective_start_date IS NULL AND :NEW.effective_start_date IS NOT NULL) OR
      (:OLD.effective_start_date IS NOT NULL AND :NEW.effective_start_date IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', EFFECTIVE_START_DATE from ' ||
        :OLD.effective_start_date || ' to ' || :NEW.effective_start_date, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.effective_end_date <> :NEW.effective_end_date OR
      (:OLD.effective_end_date IS NULL AND :NEW.effective_end_date IS NOT NULL) OR
      (:OLD.effective_end_date IS NOT NULL AND :NEW.effective_end_date IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', EFFECTIVE_END_DATE from ' ||
        :OLD.effective_end_date || ' to ' || :NEW.effective_end_date, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.accreditation_type_id_no <> :NEW.accreditation_type_id_no OR
      (:OLD.accreditation_type_id_no IS NULL AND :NEW.accreditation_type_id_no IS NOT NULL) OR
      (:OLD.accreditation_type_id_no IS NOT NULL AND :NEW.accreditation_type_id_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', ACCREDITATION_TYPE_ID_NO from ' ||
        :OLD.accreditation_type_id_no || ' to ' || :NEW.accreditation_type_id_no, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.broker_accred_no <> :NEW.broker_accred_no OR
      (:OLD.broker_accred_no IS NULL AND :NEW.broker_accred_no IS NOT NULL) OR
      (:OLD.broker_accred_no IS NOT NULL AND :NEW.broker_accred_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', BROKER_ACCRED_NO from ' ||
        :OLD.broker_accred_no || ' to ' || :NEW.broker_accred_no, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.broker_accred_start_date <> :NEW.broker_accred_start_date OR
      (:OLD.broker_accred_start_date IS NULL AND :NEW.broker_accred_start_date IS NOT NULL) OR
      (:OLD.broker_accred_start_date IS NOT NULL AND :NEW.broker_accred_start_date IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', BROKER_ACCRED_START_DATE from ' ||
        :OLD.broker_accred_start_date || ' to ' || :NEW.broker_accred_start_date, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.broker_accred_end_date <> :NEW.broker_accred_end_date OR
      (:OLD.broker_accred_end_date IS NULL AND :NEW.broker_accred_end_date IS NOT NULL) OR
      (:OLD.broker_accred_end_date IS NOT NULL AND :NEW.broker_accred_end_date IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', BROKER_ACCRED_END_DATE from ' ||
        :OLD.broker_accred_end_date || ' to ' || :NEW.broker_accred_end_date, 1, 550);
      l_write_aud := 'Y';
    END IF;
ELSIF DELETING THEN
    aud.transaction_desc := 'Deleted record ' || :OLD.broker_id_no;
    l_write_aud := 'Y';
  END IF;

  -- Setting the logger values in case
  logger.append_param(l_params, 'Action:', aud.transaction_desc);

  -- Setting the Audit row values
  IF INSERTING OR UPDATING THEN
    aud.broker_id_no                     := :NEW.broker_id_no;
    aud.effective_start_date             := :NEW.effective_start_date;
    aud.effective_end_date               := :NEW.effective_end_date;
    aud.accreditation_type_id_no         := :NEW.accreditation_type_id_no;
    aud.broker_accred_no                 := :NEW.broker_accred_no;
    aud.broker_accred_start_date         := :NEW.broker_accred_start_date;
    aud.broker_accred_end_date           := :NEW.broker_accred_end_date;
  ELSIF DELETING THEN
    aud.broker_id_no                     := :OLD.broker_id_no;
    aud.effective_start_date             := :OLD.effective_start_date;
    aud.effective_end_date               := :OLD.effective_end_date;
    aud.accreditation_type_id_no         := :OLD.accreditation_type_id_no;
    aud.broker_accred_no                 := :OLD.broker_accred_no;
    aud.broker_accred_start_date         := :OLD.broker_accred_start_date;
    aud.broker_accred_end_date           := :OLD.broker_accred_end_date;
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
    INSERT INTO BROKER_ACCREDITATION_AUDIT VALUES aud;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      logger.log_error('Unhandled Exception', l_scope, null, l_params);
      -- dbms_output.put_line('Error Code is ' || TO_CHAR(SQLCODE ) );
      -- dbms_output.put_line('Error Message is ' || SQLERRM );
      RAISE;
END BROKER_ACCREDITAT_AUD_BEF_TRG;
/
