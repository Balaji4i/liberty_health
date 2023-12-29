CREATE OR REPLACE EDITIONABLE TRIGGER "LHHCOM"."INVOICE_AUDIT_BEFORE_TRG"

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
15/06/2018  Sarel    LS-1361 add INVOICE_TAX_CODES
29/01/2019  SE       Ensure that Audit records only get written if something worth auditing changes
*/

BEFORE INSERT OR UPDATE OR DELETE ON INVOICE

FOR EACH ROW

DECLARE

  gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';
  l_scope logger_logs.scope%type := 'CommissionsSelfBuild: ' || gc_scope_prefix;
  l_params logger.tab_param;
  aud INVOICE_AUDIT%ROWTYPE;
  l_write_aud VARCHAR(1);
  
BEGIN    

  l_write_aud := 'N';
  -- Setting the Transaction Description
  IF INSERTING THEN
    aud.transaction_desc := 'Created ' || :NEW.invoice_no;
    l_write_aud := 'Y';
  ELSIF UPDATING THEN
    aud.transaction_desc := 'Changed record ' || :OLD.invoice_no;
    IF :OLD.invoice_no <> :NEW.invoice_no OR
      (:OLD.invoice_no IS NULL AND :NEW.invoice_no IS NOT NULL) OR
      (:OLD.invoice_no IS NOT NULL AND :NEW.invoice_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', INVOICE_NO from ' ||
        :OLD.invoice_no || ' to ' || :NEW.invoice_no, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.invoice_date <> :NEW.invoice_date OR
      (:OLD.invoice_date IS NULL AND :NEW.invoice_date IS NOT NULL) OR
      (:OLD.invoice_date IS NOT NULL AND :NEW.invoice_date IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', INVOICE_DATE from ' ||
        :OLD.invoice_date || ' to ' || :NEW.invoice_date, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.payment_receive_date <> :NEW.payment_receive_date OR
      (:OLD.payment_receive_date IS NULL AND :NEW.payment_receive_date IS NOT NULL) OR
      (:OLD.payment_receive_date IS NOT NULL AND :NEW.payment_receive_date IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', PAYMENT_RECEIVE_DATE from ' ||
        :OLD.payment_receive_date || ' to ' || :NEW.payment_receive_date, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.country_code <> :NEW.country_code OR
      (:OLD.country_code IS NULL AND :NEW.country_code IS NOT NULL) OR
      (:OLD.country_code IS NOT NULL AND :NEW.country_code IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', COUNTRY_CODE from ' ||
        :OLD.country_code || ' to ' || :NEW.country_code, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.company_id_no <> :NEW.company_id_no OR
      (:OLD.company_id_no IS NULL AND :NEW.company_id_no IS NOT NULL) OR
      (:OLD.company_id_no IS NOT NULL AND :NEW.company_id_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', COMPANY_ID_NO from ' ||
        :OLD.company_id_no || ' to ' || :NEW.company_id_no, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.invoice_type_id_no <> :NEW.invoice_type_id_no OR
      (:OLD.invoice_type_id_no IS NULL AND :NEW.invoice_type_id_no IS NOT NULL) OR
      (:OLD.invoice_type_id_no IS NOT NULL AND :NEW.invoice_type_id_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', INVOICE_TYPE_ID_NO from ' ||
        :OLD.invoice_type_id_no || ' to ' || :NEW.invoice_type_id_no, 1, 550);
      l_write_aud := 'Y';
    END IF;
-- Helen LS-1361
    IF :OLD.invoice_tax_codes <> :NEW.invoice_tax_codes OR
      (:OLD.invoice_tax_codes IS NULL AND :NEW.invoice_tax_codes IS NOT NULL) OR
      (:OLD.invoice_tax_codes IS NOT NULL AND :NEW.invoice_tax_codes IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', INVOICE_TAX_CODES from ' ||
        :OLD.invoice_tax_codes || ' to ' || :NEW.invoice_tax_codes, 1, 550);
      l_write_aud := 'Y';
    END IF;
-- Helen LS-1361    
    IF :OLD.release_date <> :NEW.release_date OR
      (:OLD.release_date IS NULL AND :NEW.release_date IS NOT NULL) OR
      (:OLD.release_date IS NOT NULL AND :NEW.release_date IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', RELEASE_DATE from ' ||
        :OLD.release_date || ' to ' || :NEW.release_date, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.release_hold_reason <> :NEW.release_hold_reason OR
      (:OLD.release_hold_reason IS NULL AND :NEW.release_hold_reason IS NOT NULL) OR
      (:OLD.release_hold_reason IS NOT NULL AND :NEW.release_hold_reason IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', RELEASE_HOLD_REASON from ' ||
        :OLD.release_hold_reason || ' to ' || :NEW.release_hold_reason, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.payment_date <> :NEW.payment_date OR
      (:OLD.payment_date IS NULL AND :NEW.payment_date IS NOT NULL) OR
      (:OLD.payment_date IS NOT NULL AND :NEW.payment_date IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', PAYMENT_DATE from ' ||
        :OLD.payment_date || ' to ' || :NEW.payment_date, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.payment_reject_date <> :NEW.payment_reject_date OR
      (:OLD.payment_reject_date IS NULL AND :NEW.payment_reject_date IS NOT NULL) OR
      (:OLD.payment_reject_date IS NOT NULL AND :NEW.payment_reject_date IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', PAYMENT_REJECT_DATE from ' ||
        :OLD.payment_reject_date || ' to ' || :NEW.payment_reject_date, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.payment_reject_desc <> :NEW.payment_reject_desc OR
      (:OLD.payment_reject_desc IS NULL AND :NEW.payment_reject_desc IS NOT NULL) OR
      (:OLD.payment_reject_desc IS NOT NULL AND :NEW.payment_reject_desc IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', PAYMENT_REJECT_DESC from ' ||
        :OLD.payment_reject_desc || ' to ' || :NEW.payment_reject_desc, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.payment_amt <> :NEW.payment_amt OR
      (:OLD.payment_amt IS NULL AND :NEW.payment_amt IS NOT NULL) OR
      (:OLD.payment_amt IS NOT NULL AND :NEW.payment_amt IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', PAYMENT_AMT from ' ||
        :OLD.payment_amt || ' to ' || :NEW.payment_amt, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.payment_exch_rate <> :NEW.payment_exch_rate OR
      (:OLD.payment_exch_rate IS NULL AND :NEW.payment_exch_rate IS NOT NULL) OR
      (:OLD.payment_exch_rate IS NOT NULL AND :NEW.payment_exch_rate IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', PAYMENT_EXCH_RATE from ' ||
        :OLD.payment_exch_rate || ' to ' || :NEW.payment_exch_rate, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.currency_code <> :NEW.currency_code OR
      (:OLD.currency_code IS NULL AND :NEW.currency_code IS NOT NULL) OR
      (:OLD.currency_code IS NOT NULL AND :NEW.currency_code IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', CURRENCY_CODE from ' ||
        :OLD.currency_code || ' to ' || :NEW.currency_code, 1, 550);
      l_write_aud := 'Y';
    END IF;
  ELSIF DELETING THEN
    aud.transaction_desc := 'Deleted record ' || :OLD.invoice_no;
    l_write_aud := 'Y';
  END IF;

  -- Setting the logger values in case
  logger.append_param(l_params, 'Action:', aud.transaction_desc);

  -- Setting the Audit row values
  IF INSERTING OR UPDATING THEN
    aud.invoice_no                       := :NEW.invoice_no;
    aud.invoice_date                     := :NEW.invoice_date;
    aud.payment_receive_date             := :NEW.payment_receive_date;
    aud.country_code                     := :NEW.country_code;
    aud.company_id_no                    := :NEW.company_id_no;
    aud.invoice_type_id_no               := :NEW.invoice_type_id_no;
    aud.release_date                     := :NEW.release_date;
    aud.release_hold_reason              := :NEW.release_hold_reason;
    aud.payment_date                     := :NEW.payment_date;
    aud.payment_reject_date              := :NEW.payment_reject_date;
    aud.payment_reject_desc              := :NEW.payment_reject_desc;
    aud.payment_amt                      := :NEW.payment_amt;
    aud.payment_exch_rate                := :NEW.payment_exch_rate;
    aud.currency_code                    := :NEW.currency_code;
    aud.invoice_tax_codes                := :NEW.invoice_tax_codes;
  ELSIF DELETING THEN
    aud.invoice_no                       := :OLD.invoice_no;
    aud.invoice_date                     := :OLD.invoice_date;
    aud.payment_receive_date             := :OLD.payment_receive_date;
    aud.country_code                     := :OLD.country_code;
    aud.company_id_no                    := :OLD.company_id_no;
    aud.invoice_type_id_no               := :OLD.invoice_type_id_no;
    aud.release_date                     := :OLD.release_date;
    aud.release_hold_reason              := :OLD.release_hold_reason;
    aud.payment_date                     := :OLD.payment_date;
    aud.payment_reject_date              := :OLD.payment_reject_date;
    aud.payment_reject_desc              := :OLD.payment_reject_desc;
    aud.payment_amt                      := :OLD.payment_amt;
    aud.payment_exch_rate                := :OLD.payment_exch_rate;
    aud.currency_code                    := :OLD.currency_code;
    aud.invoice_tax_codes                := :OLD.invoice_tax_codes;
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
    INSERT INTO INVOICE_AUDIT VALUES aud;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      logger.log_error('Unhandled Exception', l_scope, null, l_params);
      -- dbms_output.put_line('Error Code is ' || TO_CHAR(SQLCODE ) );
      -- dbms_output.put_line('Error Message is ' || SQLERRM );
      RAISE;
END INVOICE_AUDIT_BEFORE_TRG;
/