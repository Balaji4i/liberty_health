CREATE OR REPLACE EDITIONABLE TRIGGER "LHHCOM"."OHI_POLICYHOLDERS_AUDIT_TRG" 

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
29/08/2017  SE       Create Trigger 
06/04/2018  SE       Make Changes for transaction_desc < 550 characters
29/01/2019  SE       Ensure that Audit records only get written if something worth auditing changes
*/

BEFORE INSERT OR UPDATE OR DELETE ON OHI_POLICYHOLDERS

FOR EACH ROW

DECLARE

  gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';
  l_scope logger_logs.scope%type := 'CommissionsSelfBuild: ' || gc_scope_prefix;
  l_params logger.tab_param;
  aud OHI_POLICYHOLDERS_AUDIT%ROWTYPE;
  l_write_aud VARCHAR(1);
  
BEGIN    

  l_write_aud := 'N';
  -- Setting the Transaction Description
  IF INSERTING THEN
    aud.transaction_desc := 'Created ' || :NEW.poho_id;
    l_write_aud := 'Y';
  ELSIF UPDATING THEN
    aud.transaction_desc := 'Changed record ' || :OLD.poho_id;
    IF :OLD.poho_id <> :NEW.poho_id OR 
      (:OLD.poho_id IS NULL AND :NEW.poho_id IS NOT NULL) OR 
      (:OLD.poho_id IS NOT NULL AND :NEW.poho_id IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', POHO_ID from ' ||
        :OLD.poho_id || ' to ' || :NEW.poho_id, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.poli_id <> :NEW.poli_id OR 
      (:OLD.poli_id IS NULL AND :NEW.poli_id IS NOT NULL) OR 
      (:OLD.poli_id IS NOT NULL AND :NEW.poli_id IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', POLI_ID from ' ||
        :OLD.poli_id || ' to ' || :NEW.poli_id, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.rela_id_pers <> :NEW.rela_id_pers OR 
      (:OLD.rela_id_pers IS NULL AND :NEW.rela_id_pers IS NOT NULL) OR 
      (:OLD.rela_id_pers IS NOT NULL AND :NEW.rela_id_pers IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', RELA_ID_PERS from ' ||
        :OLD.rela_id_pers || ' to ' || :NEW.rela_id_pers, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.title <> :NEW.title OR 
      (:OLD.title IS NULL AND :NEW.title IS NOT NULL) OR 
      (:OLD.title IS NOT NULL AND :NEW.title IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', TITLE from ' ||
        :OLD.title || ' to ' || :NEW.title, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.initials <> :NEW.initials OR 
      (:OLD.initials IS NULL AND :NEW.initials IS NOT NULL) OR 
      (:OLD.initials IS NOT NULL AND :NEW.initials IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', INITIALS from ' ||
        :OLD.initials || ' to ' || :NEW.initials, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.first_name <> :NEW.first_name OR 
      (:OLD.first_name IS NULL AND :NEW.first_name IS NOT NULL) OR 
      (:OLD.first_name IS NOT NULL AND :NEW.first_name IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', FIRST_NAME from ' ||
        :OLD.first_name || ' to ' || :NEW.first_name, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.surname <> :NEW.surname OR 
      (:OLD.surname IS NULL AND :NEW.surname IS NOT NULL) OR 
      (:OLD.surname IS NOT NULL AND :NEW.surname IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', SURNAME from ' ||
        :OLD.surname || ' to ' || :NEW.surname, 1, 550);
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
  ELSIF DELETING THEN
    aud.transaction_desc := 'Deleted record ' || :OLD.poho_id;
    l_write_aud := 'Y';
  END IF;

  -- Setting the logger values in case
  logger.append_param(l_params, 'Action:', aud.transaction_desc);

  -- Setting the Audit row values
  IF INSERTING OR UPDATING THEN
    aud.poho_id                          := :NEW.poho_id;
    aud.poli_id                          := :NEW.poli_id;
    aud.rela_id_pers                     := :NEW.rela_id_pers;
    aud.title                            := :NEW.title;
    aud.initials                         := :NEW.initials;
    aud.first_name                       := :NEW.first_name;
    aud.surname                          := :NEW.surname;
    aud.effective_start_date             := :NEW.effective_start_date;
    aud.effective_end_date               := :NEW.effective_end_date;
  ELSIF DELETING THEN
    aud.poho_id                          := :OLD.poho_id;
    aud.poli_id                          := :OLD.poli_id;
    aud.rela_id_pers                     := :OLD.rela_id_pers;
    aud.title                            := :OLD.title;
    aud.initials                         := :OLD.initials;
    aud.first_name                       := :OLD.first_name;
    aud.surname                          := :OLD.surname;
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
    INSERT INTO OHI_POLICYHOLDERS_AUDIT VALUES aud;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      logger.log_error('Unhandled Exception', l_scope, null, l_params);
      -- dbms_output.put_line('Error Code is ' || TO_CHAR(SQLCODE ) );
      -- dbms_output.put_line('Error Message is ' || SQLERRM );
      RAISE;
END OHI_POLICYHOLDERS_AUDIT_TRG;
/