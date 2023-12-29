CREATE OR REPLACE EDITIONABLE TRIGGER "LHHCOM"."COMPANY_CONTACT_AUDIT_TRG"

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
06/04/2018  SE       Make Changes for transaction_desc < 550 characters
29/01/2019  SE       Ensure that Audit records only get written if something worth auditing changes
*/

BEFORE INSERT OR UPDATE OR DELETE ON COMPANY_CONTACT

FOR EACH ROW

DECLARE

  gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';
  l_scope logger_logs.scope%type := 'CommissionsSelfBuild: ' || gc_scope_prefix;
  l_params logger.tab_param;
  aud COMPANY_CONTACT_AUDIT%ROWTYPE;
  l_write_aud VARCHAR(1);
  
BEGIN    

  l_write_aud := 'N';
  -- Setting the Transaction Description
  IF INSERTING THEN
    aud.transaction_desc := 'Created ' || :NEW.company_id_no;
    l_write_aud := 'Y';
  ELSIF UPDATING THEN
    aud.transaction_desc := 'Changed record ' || :OLD.company_id_no;
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
    IF :OLD.company_contact_type_id_no <> :NEW.company_contact_type_id_no OR
      (:OLD.company_contact_type_id_no IS NULL AND :NEW.company_contact_type_id_no IS NOT NULL) OR
      (:OLD.company_contact_type_id_no IS NOT NULL AND :NEW.company_contact_type_id_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', COMPANY_CONTACT_TYPE_ID_NO from ' ||
        :OLD.company_contact_type_id_no || ' to ' || :NEW.company_contact_type_id_no, 1, 550);
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
    IF :OLD.contact_name <> :NEW.contact_name OR
      (:OLD.contact_name IS NULL AND :NEW.contact_name IS NOT NULL) OR
      (:OLD.contact_name IS NOT NULL AND :NEW.contact_name IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', CONTACT_NAME from ' ||
        :OLD.contact_name || ' to ' || :NEW.contact_name, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.contact_cellphone_no <> :NEW.contact_cellphone_no OR
      (:OLD.contact_cellphone_no IS NULL AND :NEW.contact_cellphone_no IS NOT NULL) OR
      (:OLD.contact_cellphone_no IS NOT NULL AND :NEW.contact_cellphone_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', CONTACT_CELLPHONE_NO from ' ||
        :OLD.contact_cellphone_no || ' to ' || :NEW.contact_cellphone_no, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.contact_email <> :NEW.contact_email OR
      (:OLD.contact_email IS NULL AND :NEW.contact_email IS NOT NULL) OR
      (:OLD.contact_email IS NOT NULL AND :NEW.contact_email IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', CONTACT_EMAIL from ' ||
        :OLD.contact_email || ' to ' || :NEW.contact_email, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.contact_fax_no <> :NEW.contact_fax_no OR
      (:OLD.contact_fax_no IS NULL AND :NEW.contact_fax_no IS NOT NULL) OR
      (:OLD.contact_fax_no IS NOT NULL AND :NEW.contact_fax_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', CONTACT_FAX_NO from ' ||
        :OLD.contact_fax_no || ' to ' || :NEW.contact_fax_no, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.contact_telephone_no <> :NEW.contact_telephone_no OR
      (:OLD.contact_telephone_no IS NULL AND :NEW.contact_telephone_no IS NOT NULL) OR
      (:OLD.contact_telephone_no IS NOT NULL AND :NEW.contact_telephone_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', CONTACT_TELEPHONE_NO from ' ||
        :OLD.contact_telephone_no || ' to ' || :NEW.contact_telephone_no, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.contact_desc <> :NEW.contact_desc OR
      (:OLD.contact_desc IS NULL AND :NEW.contact_desc IS NOT NULL) OR
      (:OLD.contact_desc IS NOT NULL AND :NEW.contact_desc IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', CONTACT_DESC from ' ||
        :OLD.contact_desc || ' to ' || :NEW.contact_desc, 1, 550);
      l_write_aud := 'Y';
    END IF;
  ELSIF DELETING THEN
    aud.transaction_desc := 'Deleted record ' || :OLD.company_id_no;
    l_write_aud := 'Y';
  END IF;

  -- Setting the logger values in case
  logger.append_param(l_params, 'Action:', aud.transaction_desc);

  -- Setting the Audit row values
  IF INSERTING OR UPDATING THEN
    aud.company_id_no                    := :NEW.company_id_no;
    aud.country_code                     := :NEW.country_code;
    aud.company_contact_type_id_no       := :NEW.company_contact_type_id_no;
    aud.effective_start_date             := :NEW.effective_start_date;
    aud.effective_end_date               := :NEW.effective_end_date;
    aud.contact_name                     := :NEW.contact_name;
    aud.contact_cellphone_no             := :NEW.contact_cellphone_no;
    aud.contact_email                    := :NEW.contact_email;
    aud.contact_fax_no                   := :NEW.contact_fax_no;
    aud.contact_telephone_no             := :NEW.contact_telephone_no;
    aud.contact_desc                     := :NEW.contact_desc;
  ELSIF DELETING THEN
    aud.company_id_no                    := :OLD.company_id_no;
    aud.country_code                     := :OLD.country_code;
    aud.company_contact_type_id_no       := :OLD.company_contact_type_id_no;
    aud.effective_start_date             := :OLD.effective_start_date;
    aud.effective_end_date               := :OLD.effective_end_date;
    aud.contact_name                     := :OLD.contact_name;
    aud.contact_cellphone_no             := :OLD.contact_cellphone_no;
    aud.contact_email                    := :OLD.contact_email;
    aud.contact_fax_no                   := :OLD.contact_fax_no;
    aud.contact_telephone_no             := :OLD.contact_telephone_no;
    aud.contact_desc                     := :OLD.contact_desc;
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
    INSERT INTO COMPANY_CONTACT_AUDIT VALUES aud;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      logger.log_error('Unhandled Exception', l_scope, null, l_params);
      -- dbms_output.put_line('Error Code is ' || TO_CHAR(SQLCODE ) );
      -- dbms_output.put_line('Error Message is ' || SQLERRM );
      RAISE;
END COMPANY_CONTACT_AUDIT_TRG;
/
