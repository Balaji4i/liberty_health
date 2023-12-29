CREATE OR REPLACE EDITIONABLE TRIGGER "LHHCOM"."COUNTRY_TAXES_AUDIT_TRG" 

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
17/05/2018  SE       Create Trigger
29/01/2019  SE       Ensure that Audit records only get written if something worth auditing changes
*/

BEFORE INSERT OR UPDATE OR DELETE ON COUNTRY_TAXES

FOR EACH ROW

DECLARE

  gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';
  l_scope logger_logs.scope%type := 'CommissionsSelfBuild: ' || gc_scope_prefix;
  l_params logger.tab_param;
  aud COUNTRY_TAXES_AUDIT%ROWTYPE;
  l_write_aud VARCHAR(1);
  
BEGIN    

  l_write_aud := 'N';
  -- Setting the Transaction Description
  IF INSERTING THEN
    aud.transaction_desc := 'Created ' || :NEW.country_code || ' for Accred_Id:'
      || :NEW.accreditation_type_id_no || ' and from date:' || :NEW.effective_start_date;
    l_write_aud := 'Y';
  ELSIF UPDATING THEN
    aud.transaction_desc := 'Changed record ' || :OLD.country_code || ' for Accred_Id:'
      || :OLD.accreditation_type_id_no || ' and from date:' || :OLD.effective_start_date;
    IF :OLD.country_code <> :NEW.country_code OR
      (:OLD.country_code IS NULL AND :NEW.country_code IS NOT NULL) OR 
      (:OLD.country_code IS NOT NULL AND :NEW.country_code IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', COUNTRY_CODE from ' ||
        :OLD.country_code || ' to ' || :NEW.country_code, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.accreditation_type_id_no <> :NEW.accreditation_type_id_no  OR
      (:OLD.accreditation_type_id_no IS NULL AND :NEW.accreditation_type_id_no IS NOT NULL) OR 
      (:OLD.accreditation_type_id_no IS NOT NULL AND :NEW.accreditation_type_id_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', ACCREDITATION_TYPE_ID_NO from ' ||
        :OLD.accreditation_type_id_no || ' to ' || :NEW.accreditation_type_id_no, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.effective_start_date <> :NEW.effective_start_date  OR
      (:OLD.effective_start_date IS NULL AND :NEW.effective_start_date IS NOT NULL) OR 
      (:OLD.effective_start_date IS NOT NULL AND :NEW.effective_start_date IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', EFFECTIVE_START_DATE from ' ||
        :OLD.effective_start_date || ' to ' || :NEW.effective_start_date, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.effective_end_date <> :NEW.effective_end_date  OR
      (:OLD.effective_end_date IS NULL AND :NEW.effective_end_date IS NOT NULL) OR 
      (:OLD.effective_end_date IS NOT NULL AND :NEW.effective_end_date IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', EFFECTIVE_END_DATE from ' ||
        :OLD.effective_end_date || ' to ' || :NEW.effective_end_date, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.accred_local <> :NEW.accred_local  OR
      (:OLD.accred_local IS NULL AND :NEW.accred_local IS NOT NULL) OR 
      (:OLD.accred_local IS NOT NULL AND :NEW.accred_local IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', ACCRED_LOCAL from ' ||
        :OLD.accred_local || ' to ' || :NEW.accred_local, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.accred_multi <> :NEW.accred_multi  OR
      (:OLD.accred_multi IS NULL AND :NEW.accred_multi IS NOT NULL) OR 
      (:OLD.accred_multi IS NOT NULL AND :NEW.accred_multi IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', ACCRED_MULTI from ' ||
        :OLD.accred_multi || ' to ' || :NEW.accred_multi, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.no_accr_local <> :NEW.no_accr_local  OR
      (:OLD.no_accr_local IS NULL AND :NEW.no_accr_local IS NOT NULL) OR 
      (:OLD.no_accr_local IS NOT NULL AND :NEW.no_accr_local IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', NO_ACCR_LOCAL from ' ||
        :OLD.no_accr_local || ' to ' || :NEW.no_accr_local, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.no_accr_multi <> :NEW.no_accr_multi  OR
      (:OLD.no_accr_multi IS NULL AND :NEW.no_accr_multi IS NOT NULL) OR 
      (:OLD.no_accr_multi IS NOT NULL AND :NEW.no_accr_multi IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', NO_ACCR_MULTI from ' ||
        :OLD.no_accr_multi || ' to ' || :NEW.no_accr_multi, 1, 550);
      l_write_aud := 'Y';
    END IF;
  ELSIF DELETING THEN
    aud.transaction_desc := 'Deleted record ' || :OLD.country_code || ' for Accred_Id:'
      || :OLD.accreditation_type_id_no || ' and from date:' || :OLD.effective_start_date;
    l_write_aud := 'Y';
  END IF;

  -- Setting the logger values in case
  logger.append_param(l_params, 'Action:', aud.transaction_desc);

  -- Setting the Audit row values
  IF INSERTING OR UPDATING THEN
    aud.country_code                     := :NEW.country_code;
    aud.accreditation_type_id_no         := :NEW.accreditation_type_id_no;
    aud.effective_start_date             := :NEW.effective_start_date;
    aud.effective_end_date               := :NEW.effective_end_date;
    aud.accred_local                     := :NEW.accred_local;
    aud.accred_multi                     := :NEW.accred_multi;
    aud.no_accr_local                    := :NEW.no_accr_local;
    aud.no_accr_multi                    := :NEW.no_accr_multi;
  ELSIF DELETING THEN
    aud.country_code                     := :OLD.country_code;
    aud.accreditation_type_id_no         := :OLD.accreditation_type_id_no;
    aud.effective_start_date             := :OLD.effective_start_date;
    aud.effective_end_date               := :OLD.effective_end_date;
    aud.accred_local                     := :OLD.accred_local;
    aud.accred_multi                     := :OLD.accred_multi;
    aud.no_accr_local                    := :OLD.no_accr_local;
    aud.no_accr_multi                    := :OLD.no_accr_multi;
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
    INSERT INTO COUNTRY_TAXES_AUDIT VALUES aud;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      logger.log_error('Unhandled Exception', l_scope, null, l_params);
      -- dbms_output.put_line('Error Code is ' || TO_CHAR(SQLCODE ) );
      -- dbms_output.put_line('Error Message is ' || SQLERRM );
      RAISE;
END COUNTRY_TAXES_AUDIT_TRG;
/