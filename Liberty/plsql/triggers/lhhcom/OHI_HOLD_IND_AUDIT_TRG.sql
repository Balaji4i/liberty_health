CREATE OR REPLACE EDITIONABLE TRIGGER "LHHCOM"."OHI_HOLD_IND_AUDIT_TRG" 

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
09/09/2017  SE       Create Trigger 
27/10/2017  SE       Changed how Audit key is displayed
06/04/2018  SE       Make Changes for transaction_desc < 550 characters
29/01/2019  SE       Ensure that Audit records only get written if something worth auditing changes
*/

BEFORE INSERT OR UPDATE OR DELETE ON OHI_HOLD_IND

FOR EACH ROW

DECLARE

  gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';
  l_scope logger_logs.scope%type := 'CommissionsSelfBuild: ' || gc_scope_prefix;
  l_params logger.tab_param;
  aud OHI_HOLD_IND_AUDIT%ROWTYPE;
  l_write_aud VARCHAR(1);
  l_cnt NUMBER; 
  
BEGIN    

  l_write_aud := 'N';
  -- Checking that valid values were entered in the Codes . . .
  IF  -- Not NULL Values Check
         :NEW.company_id_no IS NULL 
     AND :NEW.broker_id_no  IS NULL
     AND :NEW.group_code    IS NULL
     AND :NEW.product_code  IS NULL
     AND :NEW.policy_code   IS NULL
     AND :NEW.inse_code   IS NULL
     AND :NEW.poep_id       IS NULL THEN
    raise_application_error(-20007,'Error: NULL values entered for all Key Fields');
  END IF; -- Not NULL Values Check
  -- Checking the Company ID
  IF :NEW.company_id_no IS NOT NULL THEN
    IF isvalid_company_id_no(:NEW.company_id_no) = 'FALSE' THEN
      raise_application_error(-20007,'Error: COMPANY_ID_NO '|| :NEW.company_id_no || ' does not exist.');
    END IF;
    IF   :NEW.broker_id_no IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: BROKER_ID_NO must be NULL when COMPANY_ID_NO is populated');
    END IF;
    IF   :NEW.group_code   IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: GROUP_CODE must be NULL when COMPANY_ID_NO is populated');
    END IF;
    IF   :NEW.product_code IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: PRODUCT_CODE must be NULL when COMPANY_ID_NO is populated');
    END IF;
    IF   :NEW.policy_code IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: POLICY_CODE must be NULL when COMPANY_ID_NO is populated');
    END IF;
    IF   :NEW.inse_code IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: INSE_CODE must be NULL when COMPANY_ID_NO is populated');
    END IF;
    IF   :NEW.poep_id IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: POEP_ID must be NULL when COMPANY_ID_NO is populated');
    END IF;
  END IF; -- Checking the Company ID
  -- Checking the Broker ID
  IF :NEW.broker_id_no IS NOT NULL THEN
    IF isvalid_broker_id_no(:NEW.broker_id_no) = 'FALSE' THEN
      raise_application_error(-20007,'Error: BROKER_ID_NO '|| :NEW.broker_id_no || ' does not exist.');
    END IF;
    IF   :NEW.group_code   IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: GROUP_CODE must be NULL when BROKER_ID_NO is populated');
    END IF;
    IF   :NEW.product_code IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: PRODUCT_CODE must be NULL when BROKER_ID_NO is populated');
    END IF;
    IF   :NEW.policy_code IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: POLICY_CODE must be NULL when BROKER_ID_NO is populated');
    END IF;
    IF   :NEW.inse_code IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: INSE_CODE must be NULL when BROKER_ID_NO is populated');
    END IF;
    IF   :NEW.poep_id IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: POEP_ID must be NULL when BROKER_ID_NO is populated');
    END IF;
  END IF; -- Checking the Broker ID
  -- Checking the Group Code
  IF :NEW.group_code IS NOT NULL THEN
    IF isvalid_group_code(:NEW.group_code) = 'FALSE' THEN
      raise_application_error(-20007,'Error: GROUP_CODE '|| :NEW.group_code || ' does not exist.');
    END IF;
    IF   :NEW.policy_code IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: POLICY_CODE must be NULL when GROUP_CODE is populated');
    END IF;
    IF   :NEW.inse_code IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: INSE_CODE must be NULL when GROUP_CODE is populated');
    END IF;
    IF   :NEW.poep_id IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: POEP_ID must be NULL when GROUP_CODE is populated');
    END IF;
  END IF; -- Checking the Group Code
  -- Checking the Product Code
  IF :NEW.product_code IS NOT NULL THEN
    IF isvalid_product_code(:NEW.product_code) = 'FALSE' THEN
      raise_application_error(-20007,'Error: PRODUCT_CODE '|| :NEW.product_code || ' does not exist.');
    END IF;
    IF   :NEW.policy_code IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: POLICY_CODE must be NULL when PRODUCT_CODE is populated');
    END IF;
    IF   :NEW.inse_code IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: INSE_CODE must be NULL when PRODUCT_CODE is populated');
    END IF;
    IF   :NEW.poep_id IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: POEP_ID must be NULL when PRODUCT_CODE is populated');
    END IF;
  END IF; -- Checking the Product Code
  -- Checking the Policy Code
  IF :NEW.policy_code IS NOT NULL THEN
    IF isvalid_policy_code(:NEW.policy_code) = 'FALSE' THEN
      raise_application_error(-20007,'Error: POLICY_CODE '|| :NEW.policy_code || ' does not exist.');
    END IF;
    IF   :NEW.inse_code IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: INSE_CODE must be NULL when POLICY_CODE is populated');
    END IF;
    IF   :NEW.poep_id IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: POEP_ID must be NULL when POLICY_CODE is populated');
    END IF;
  END IF; -- Checking the Policy Code
  -- Checking the Person Code
  IF :NEW.inse_code IS NOT NULL THEN
    IF isvalid_person_code(:NEW.inse_code) = 'FALSE' THEN
      raise_application_error(-20007,'Error: INSE_CODE '|| :NEW.inse_code || ' does not exist.');
    END IF;
    IF   :NEW.poep_id IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: POEP_ID must be NULL when INSE_CODE is populated');
    END IF;
  END IF; -- Checking the Person Code
  -- Checking the POEP ID
  IF :NEW.poep_id IS NOT NULL THEN
    IF isvalid_poep_id(:NEW.poep_id) = 'FALSE' THEN
      raise_application_error(-20007,'Error: POEP_ID '|| :NEW.poep_id || ' does not exist.');
    END IF;
  END IF; -- Checking the POEP ID

  -- Writing away the Audit record . . .
  -- Setting the Transaction Description
  IF INSERTING THEN
    aud.transaction_desc := 'Added new record' ||
      CASE WHEN :NEW.company_id_no IS NOT NULL THEN ' COMPANY-' || :NEW.company_id_no END ||
      CASE WHEN :NEW.broker_id_no  IS NOT NULL THEN ' BROKER-'  || :NEW.broker_id_no  END ||
      CASE WHEN :NEW.group_code    IS NOT NULL THEN ' GROUP-'   || :NEW.group_code    END ||
      CASE WHEN :NEW.product_code  IS NOT NULL THEN ' PRODUCT-' || :NEW.product_code  END ||
      CASE WHEN :NEW.policy_code   IS NOT NULL THEN ' POLICY-'  || :NEW.policy_code   END ||
      CASE WHEN :NEW.inse_code     IS NOT NULL THEN ' INSE-'    || :NEW.inse_code     END ||
      CASE WHEN :NEW.poep_id       IS NOT NULL THEN ' POEP-'    || :NEW.poep_id       END;
    l_write_aud := 'Y';
  ELSIF UPDATING THEN
    aud.transaction_desc := 'Changed record' ||
      CASE WHEN :OLD.company_id_no IS NOT NULL THEN ' COMPANY-' || :OLD.company_id_no END ||
      CASE WHEN :OLD.broker_id_no  IS NOT NULL THEN ' BROKER-'  || :OLD.broker_id_no  END ||
      CASE WHEN :OLD.group_code    IS NOT NULL THEN ' GROUP-'   || :OLD.group_code    END ||
      CASE WHEN :OLD.product_code  IS NOT NULL THEN ' PRODUCT-' || :OLD.product_code  END ||
      CASE WHEN :OLD.policy_code   IS NOT NULL THEN ' POLICY-'  || :OLD.policy_code   END ||
      CASE WHEN :OLD.inse_code     IS NOT NULL THEN ' INSE-'    || :OLD.inse_code     END ||
      CASE WHEN :OLD.poep_id       IS NOT NULL THEN ' POEP-'    || :OLD.poep_id       END;
    IF :OLD.product_code <> :NEW.product_code OR 
      (:OLD.product_code IS NULL AND :NEW.product_code IS NOT NULL) OR 
      (:OLD.product_code IS NOT NULL AND :NEW.product_code IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', PRODUCT_CODE from ' ||
        :OLD.product_code || ' to ' || :NEW.product_code, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.poep_id <> :NEW.poep_id OR 
      (:OLD.poep_id IS NULL AND :NEW.poep_id IS NOT NULL) OR 
      (:OLD.poep_id IS NOT NULL AND :NEW.poep_id IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', POEP_ID from ' ||
        :OLD.poep_id || ' to ' || :NEW.poep_id, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.inse_code <> :NEW.inse_code OR 
      (:OLD.inse_code IS NULL AND :NEW.inse_code IS NOT NULL) OR 
      (:OLD.inse_code IS NOT NULL AND :NEW.inse_code IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', INSE_CODE from ' ||
        :OLD.inse_code || ' to ' || :NEW.inse_code, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.policy_code <> :NEW.policy_code OR 
      (:OLD.policy_code IS NULL AND :NEW.policy_code IS NOT NULL) OR 
      (:OLD.policy_code IS NOT NULL AND :NEW.policy_code IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', POLICY_CODE from ' ||
        :OLD.policy_code || ' to ' || :NEW.policy_code, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.group_code <> :NEW.group_code OR 
      (:OLD.group_code IS NULL AND :NEW.group_code IS NOT NULL) OR 
      (:OLD.group_code IS NOT NULL AND :NEW.group_code IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', GROUP_CODE from ' ||
        :OLD.group_code || ' to ' || :NEW.group_code, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.broker_id_no <> :NEW.broker_id_no OR 
      (:OLD.broker_id_no IS NULL AND :NEW.broker_id_no IS NOT NULL) OR 
      (:OLD.broker_id_no IS NOT NULL AND :NEW.broker_id_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', BROKER_ID_NO from ' ||
        :OLD.broker_id_no || ' to ' || :NEW.broker_id_no, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.company_id_no <> :NEW.company_id_no OR 
      (:OLD.company_id_no IS NULL AND :NEW.company_id_no IS NOT NULL) OR 
      (:OLD.company_id_no IS NOT NULL AND :NEW.company_id_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', COMPANY_ID_NO from ' ||
        :OLD.company_id_no || ' to ' || :NEW.company_id_no, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.hold_ind <> :NEW.hold_ind OR 
      (:OLD.hold_ind IS NULL AND :NEW.hold_ind IS NOT NULL) OR 
      (:OLD.hold_ind IS NOT NULL AND :NEW.hold_ind IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', HOLD_IND from ' ||
        :OLD.hold_ind || ' to ' || :NEW.hold_ind, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.hold_reason <> :NEW.hold_reason OR 
      (:OLD.hold_reason IS NULL AND :NEW.hold_reason IS NOT NULL) OR 
      (:OLD.hold_reason IS NOT NULL AND :NEW.hold_reason IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', HOLD_REASON from ' ||
        :OLD.hold_reason || ' to ' || :NEW.hold_reason, 1, 550);
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
    aud.transaction_desc := 'Deleted record' ||
      CASE WHEN :OLD.company_id_no IS NOT NULL THEN ' COMPANY-' || :OLD.company_id_no END ||
      CASE WHEN :OLD.broker_id_no  IS NOT NULL THEN ' BROKER-'  || :OLD.broker_id_no  END ||
      CASE WHEN :OLD.group_code    IS NOT NULL THEN ' GROUP-'   || :OLD.group_code    END ||
      CASE WHEN :OLD.product_code  IS NOT NULL THEN ' PRODUCT-' || :OLD.product_code  END ||
      CASE WHEN :OLD.policy_code   IS NOT NULL THEN ' POLICY-'  || :OLD.policy_code   END ||
      CASE WHEN :OLD.inse_code     IS NOT NULL THEN ' INSE-'    || :OLD.inse_code     END ||
      CASE WHEN :OLD.poep_id       IS NOT NULL THEN ' POEP-'    || :OLD.poep_id       END;
    l_write_aud := 'Y';
  END IF;

  -- Setting the logger values in case
  logger.append_param(l_params, 'Action:', aud.transaction_desc);

  -- Setting the Audit row values
  IF INSERTING OR UPDATING THEN
    aud.product_code                     := :NEW.product_code;
    aud.poep_id                          := :NEW.poep_id;
    aud.inse_code                        := :NEW.inse_code;
    aud.policy_code                      := :NEW.policy_code;
    aud.group_code                       := :NEW.group_code;
    aud.broker_id_no                     := :NEW.broker_id_no;
    aud.company_id_no                    := :NEW.company_id_no;
    aud.hold_ind                         := :NEW.hold_ind;
    aud.hold_reason                      := :NEW.hold_reason;
    aud.effective_start_date             := :NEW.effective_start_date;
    aud.effective_end_date               := :NEW.effective_end_date;
  ELSIF DELETING THEN
    aud.product_code                     := :OLD.product_code;
    aud.poep_id                          := :OLD.poep_id;
    aud.inse_code                        := :OLD.inse_code;
    aud.policy_code                      := :OLD.policy_code;
    aud.group_code                       := :OLD.group_code;
    aud.broker_id_no                     := :OLD.broker_id_no;
    aud.company_id_no                    := :OLD.company_id_no;
    aud.hold_ind                         := :OLD.hold_ind;
    aud.hold_reason                      := :OLD.hold_reason;
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
    INSERT INTO OHI_HOLD_IND_AUDIT VALUES aud;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      logger.log_error('Unhandled Exception', l_scope, null, l_params);
      -- dbms_output.put_line('Error Code is ' || TO_CHAR(SQLCODE ) );
      -- dbms_output.put_line('Error Message is ' || SQLERRM );
      RAISE;
END OHI_HOLD_IND_AUDIT_TRG;
/