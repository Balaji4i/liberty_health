CREATE OR REPLACE EDITIONABLE TRIGGER "LHHCOM"."INVOICE_DETAIL_AUDIT_BEF_TRG"

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

BEFORE INSERT OR UPDATE OR DELETE ON INVOICE_DETAIL

FOR EACH ROW

DECLARE

  gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';
  l_scope logger_logs.scope%type := 'CommissionsSelfBuild: ' || gc_scope_prefix;
  l_params logger.tab_param;
  aud INVOICE_DETAIL_AUDIT%ROWTYPE;
  l_write_aud VARCHAR(1);
  
BEGIN    

  l_write_aud := 'N';
  -- Setting the Transaction Description
  IF INSERTING THEN
    aud.transaction_desc := 'Created ' || :NEW.invoice_no || ', ' || :NEW.fee_type_id_no;
    l_write_aud := 'Y';
  ELSIF UPDATING THEN
    aud.transaction_desc := 'Changed record ' || :OLD.invoice_no || ', ' || :OLD.fee_type_id_no;
    IF :OLD.invoice_no <> :NEW.invoice_no OR
      (:OLD.invoice_no IS NULL AND :NEW.invoice_no IS NOT NULL) OR
      (:OLD.invoice_no IS NOT NULL AND :NEW.invoice_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', INVOICE_NO from ' ||
        :OLD.invoice_no || ' to ' || :NEW.invoice_no, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.fee_type_id_no <> :NEW.fee_type_id_no OR
      (:OLD.fee_type_id_no IS NULL AND :NEW.fee_type_id_no IS NOT NULL) OR
      (:OLD.fee_type_id_no IS NOT NULL AND :NEW.fee_type_id_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', FEE_TYPE_ID_NO from ' ||
        :OLD.fee_type_id_no || ' to ' || :NEW.fee_type_id_no, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.fee_type_amt <> :NEW.fee_type_amt OR
      (:OLD.fee_type_amt IS NULL AND :NEW.fee_type_amt IS NOT NULL) OR
      (:OLD.fee_type_amt IS NOT NULL AND :NEW.fee_type_amt IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', FEE_TYPE_AMT from ' ||
        :OLD.fee_type_amt || ' to ' || :NEW.fee_type_amt, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.fee_type_exch_amt <> :NEW.fee_type_exch_amt OR
      (:OLD.fee_type_exch_amt IS NULL AND :NEW.fee_type_exch_amt IS NOT NULL) OR
      (:OLD.fee_type_exch_amt IS NOT NULL AND :NEW.fee_type_exch_amt IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', FEE_TYPE_EXCH_AMT from ' ||
        :OLD.fee_type_exch_amt || ' to ' || :NEW.fee_type_exch_amt, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.fee_type_desc <> :NEW.fee_type_desc OR
      (:OLD.fee_type_desc IS NULL AND :NEW.fee_type_desc IS NOT NULL) OR
      (:OLD.fee_type_desc IS NOT NULL AND :NEW.fee_type_desc IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', FEE_TYPE_DESC from ' ||
        :OLD.fee_type_desc || ' to ' || :NEW.fee_type_desc, 1, 550);
      l_write_aud := 'Y';
    END IF;
  ELSIF DELETING THEN
    aud.transaction_desc := 'Deleted record ' || :OLD.invoice_no || ', ' || :OLD.fee_type_id_no;
    l_write_aud := 'Y';
  END IF;

  -- Setting the logger values in case
  logger.append_param(l_params, 'Action:', aud.transaction_desc);

  -- Setting the Audit row values
  IF INSERTING OR UPDATING THEN
    aud.invoice_no                       := :NEW.invoice_no;
    aud.fee_type_id_no                   := :NEW.fee_type_id_no;
    aud.fee_type_amt                     := :NEW.fee_type_amt;
    aud.fee_type_exch_amt                := :NEW.fee_type_exch_amt;
    aud.fee_type_desc                    := :NEW.fee_type_desc;
  ELSIF DELETING THEN
    aud.invoice_no                       := :OLD.invoice_no;
    aud.fee_type_id_no                   := :OLD.fee_type_id_no;
    aud.fee_type_amt                     := :OLD.fee_type_amt;
    aud.fee_type_exch_amt                := :OLD.fee_type_exch_amt;
    aud.fee_type_desc                    := :OLD.fee_type_desc;
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
    INSERT INTO INVOICE_DETAIL_AUDIT VALUES aud;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      logger.log_error('Unhandled Exception', l_scope, null, l_params);
      -- dbms_output.put_line('Error Code is ' || TO_CHAR(SQLCODE ) );
      -- dbms_output.put_line('Error Message is ' || SQLERRM );
      RAISE;
END INVOICE_DETAIL_AUDIT_BEF_TRG;
/
