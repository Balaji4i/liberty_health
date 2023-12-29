CREATE OR REPLACE EDITIONABLE TRIGGER "LHHCOM"."COMPANY_REG_AUDIT_TRG" 

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
27/07/2017  SE       Create Trigger 
06/04/2018  SE       Make Changes for transaction_desc < 550 characters
29/01/2019  SE       Ensure that Audit records only get written if something worth auditing changes
*/

BEFORE INSERT OR UPDATE OR DELETE ON COMPANY_REG

FOR EACH ROW

DECLARE

  gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';
  l_scope logger_logs.scope%type := 'CommissionsSelfBuild: ' || gc_scope_prefix;
  l_params logger.tab_param;
  aud COMPANY_REG_AUDIT%ROWTYPE;
  l_write_aud VARCHAR(1);
  
BEGIN    

  l_write_aud := 'N';
  -- Setting the Transaction Description
  IF INSERTING THEN
    aud.transaction_desc := 'Created ' || :NEW.company_id_no || 
      :NEW.effective_start_date || :NEW.country_code;
    l_write_aud := 'Y';
  ELSIF UPDATING THEN
    aud.transaction_desc := 'Changed record ' || :OLD.company_id_no || 
      :OLD.effective_start_date || :OLD.country_code;
    IF :OLD.company_id_no <> :NEW.company_id_no OR 
      (:OLD.company_id_no IS NULL AND :NEW.company_id_no IS NOT NULL) OR 
      (:OLD.company_id_no IS NOT NULL AND :NEW.company_id_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', COMPANY_ID_NO from ' ||
        :OLD.company_id_no || ' to ' || :NEW.company_id_no, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.country_code <> :NEW.country_code OR 
      (:OLD.country_code IS NULL AND :NEW.country_code IS NOT NULL) OR 
      (:OLD.country_code IS NOT NULL AND :NEW.country_code IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', COUNTRY_CODE from ' ||
        :OLD.country_code || ' to ' || :NEW.country_code, 1, 550);
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
    IF :OLD.vat_no <> :NEW.vat_no OR 
      (:OLD.vat_no IS NULL AND :NEW.vat_no IS NOT NULL) OR 
      (:OLD.vat_no IS NOT NULL AND :NEW.vat_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', VAT_NO from ' ||
        :OLD.vat_no || ' to ' || :NEW.vat_no, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.reg_no <> :NEW.reg_no OR 
      (:OLD.reg_no IS NULL AND :NEW.reg_no IS NOT NULL) OR 
      (:OLD.reg_no IS NOT NULL AND :NEW.reg_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', REG_NO from ' ||
        :OLD.reg_no || ' to ' || :NEW.reg_no, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.fais_no <> :NEW.fais_no OR 
      (:OLD.fais_no IS NULL AND :NEW.fais_no IS NOT NULL) OR 
      (:OLD.fais_no IS NOT NULL AND :NEW.fais_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', FAIS_NO from ' ||
        :OLD.fais_no || ' to ' || :NEW.fais_no, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.expiry_date <> :NEW.expiry_date OR 
      (:OLD.expiry_date IS NULL AND :NEW.expiry_date IS NOT NULL) OR 
      (:OLD.expiry_date IS NOT NULL AND :NEW.expiry_date IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', EXPIRY_DATE from ' ||
        :OLD.expiry_date || ' to ' || :NEW.expiry_date, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.application_date <> :NEW.application_date OR 
      (:OLD.application_date IS NULL AND :NEW.application_date IS NOT NULL) OR 
      (:OLD.application_date IS NOT NULL AND :NEW.application_date IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', APPLICATION_DATE from ' ||
        :OLD.application_date || ' to ' || :NEW.application_date, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.authorise_date <> :NEW.authorise_date OR 
      (:OLD.authorise_date IS NULL AND :NEW.authorise_date IS NOT NULL) OR 
      (:OLD.authorise_date IS NOT NULL AND :NEW.authorise_date IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', AUTHORISE_DATE from ' ||
        :OLD.authorise_date || ' to ' || :NEW.authorise_date, 1, 550);
      l_write_aud := 'Y';
    END IF;
  ELSIF DELETING THEN
    aud.transaction_desc := 'Deleted record ' || :OLD.company_id_no || 
      :OLD.effective_start_date || :OLD.country_code;
    l_write_aud := 'Y';
  END IF;

  -- Setting the logger values in case
  logger.append_param(l_params, 'Action:', aud.transaction_desc);

  -- Setting the Audit row values
  IF INSERTING OR UPDATING THEN
    aud.company_id_no                    := :NEW.company_id_no;
    aud.country_code                     := :NEW.country_code;
    aud.effective_start_date             := :NEW.effective_start_date;
    aud.effective_end_date               := :NEW.effective_end_date;
    aud.vat_no                           := :NEW.vat_no;
    aud.reg_no                           := :NEW.reg_no;
    aud.fais_no                          := :NEW.fais_no;
    aud.expiry_date                      := :NEW.expiry_date;
    aud.application_date                 := :NEW.application_date;
    aud.authorise_date                   := :NEW.authorise_date;
  ELSIF DELETING THEN
    aud.company_id_no                    := :OLD.company_id_no;
    aud.country_code                     := :OLD.country_code;
    aud.effective_start_date             := :OLD.effective_start_date;
    aud.effective_end_date               := :OLD.effective_end_date;
    aud.vat_no                           := :OLD.vat_no;
    aud.reg_no                           := :OLD.reg_no;
    aud.fais_no                          := :OLD.fais_no;
    aud.expiry_date                      := :OLD.expiry_date;
    aud.application_date                 := :OLD.application_date;
    aud.authorise_date                   := :OLD.authorise_date;
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
    INSERT INTO COMPANY_REG_AUDIT VALUES aud;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      logger.log_error('Unhandled Exception', l_scope, null, l_params);
      -- dbms_output.put_line('Error Code is ' || TO_CHAR(SQLCODE ) );
      -- dbms_output.put_line('Error Message is ' || SQLERRM );
      RAISE;
END COMPANY_REG_AUDIT_TRG;
/