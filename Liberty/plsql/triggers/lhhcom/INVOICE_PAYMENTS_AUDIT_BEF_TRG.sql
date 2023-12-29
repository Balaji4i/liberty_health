CREATE OR REPLACE EDITIONABLE TRIGGER "LHHCOM"."INVOICE_PAYMENTS_AUDIT_BEF_TRG"

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

BEFORE INSERT OR UPDATE OR DELETE ON INVOICE_PAYMENTS

FOR EACH ROW

DECLARE

  gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';
  l_scope logger_logs.scope%type := 'CommissionsSelfBuild: ' || gc_scope_prefix;
  l_params logger.tab_param;
  aud INVOICE_PAYMENTS_AUDIT%ROWTYPE;
  l_write_aud VARCHAR(1);
  
BEGIN    
  l_write_aud := 'N';
  -- Setting the Transaction Description
  IF INSERTING THEN
    aud.transaction_desc := 'Created ' || :NEW.fusion_report_uid;
    l_write_aud := 'Y';
  ELSIF UPDATING THEN
    aud.transaction_desc := 'Changed record ' || :OLD.fusion_report_uid;
    IF :OLD.invoice_no <> :NEW.invoice_no OR
      (:OLD.invoice_no IS NULL AND :NEW.invoice_no IS NOT NULL) OR
      (:OLD.invoice_no IS NOT NULL AND :NEW.invoice_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', INVOICE_NO from ' ||
        :OLD.invoice_no || ' to ' || :NEW.invoice_no, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.company_id_no <> :NEW.company_id_no OR
      (:OLD.company_id_no IS NULL AND :NEW.company_id_no IS NOT NULL) OR
      (:OLD.company_id_no IS NOT NULL AND :NEW.company_id_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', COMPANY_ID_NO from ' ||
        :OLD.company_id_no || ' to ' || :NEW.company_id_no, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.fusion_report_uid <> :NEW.fusion_report_uid OR
      (:OLD.fusion_report_uid IS NULL AND :NEW.fusion_report_uid IS NOT NULL) OR
      (:OLD.fusion_report_uid IS NOT NULL AND :NEW.fusion_report_uid IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', FUSION_REPORT_UID from ' ||
        :OLD.fusion_report_uid || ' to ' || :NEW.fusion_report_uid, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.fusion_report_reference <> :NEW.fusion_report_reference OR
      (:OLD.fusion_report_reference IS NULL AND :NEW.fusion_report_reference IS NOT NULL) OR
      (:OLD.fusion_report_reference IS NOT NULL AND :NEW.fusion_report_reference IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', FUSION_REPORT_REFERENCE from ' ||
        :OLD.fusion_report_reference || ' to ' || :NEW.fusion_report_reference, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.p_business_unit <> :NEW.p_business_unit OR
      (:OLD.p_business_unit IS NULL AND :NEW.p_business_unit IS NOT NULL) OR
      (:OLD.p_business_unit IS NOT NULL AND :NEW.p_business_unit IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', P_BUSINESS_UNIT from ' ||
        :OLD.p_business_unit || ' to ' || :NEW.p_business_unit, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.supplier_number <> :NEW.supplier_number OR
      (:OLD.supplier_number IS NULL AND :NEW.supplier_number IS NOT NULL) OR
      (:OLD.supplier_number IS NOT NULL AND :NEW.supplier_number IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', SUPPLIER_NUMBER from ' ||
        :OLD.supplier_number || ' to ' || :NEW.supplier_number, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.invoice_id <> :NEW.invoice_id OR
      (:OLD.invoice_id IS NULL AND :NEW.invoice_id IS NOT NULL) OR
      (:OLD.invoice_id IS NOT NULL AND :NEW.invoice_id IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', INVOICE_ID from ' ||
        :OLD.invoice_id || ' to ' || :NEW.invoice_id, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.vendor_site_code <> :NEW.vendor_site_code OR
      (:OLD.vendor_site_code IS NULL AND :NEW.vendor_site_code IS NOT NULL) OR
      (:OLD.vendor_site_code IS NOT NULL AND :NEW.vendor_site_code IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', VENDOR_SITE_CODE from ' ||
        :OLD.vendor_site_code || ' to ' || :NEW.vendor_site_code, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.invoice_num <> :NEW.invoice_num OR
      (:OLD.invoice_num IS NULL AND :NEW.invoice_num IS NOT NULL) OR
      (:OLD.invoice_num IS NOT NULL AND :NEW.invoice_num IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', INVOICE_NUM from ' ||
        :OLD.invoice_num || ' to ' || :NEW.invoice_num, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.invoice_line_amount <> :NEW.invoice_line_amount OR
      (:OLD.invoice_line_amount IS NULL AND :NEW.invoice_line_amount IS NOT NULL) OR
      (:OLD.invoice_line_amount IS NOT NULL AND :NEW.invoice_line_amount IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', INVOICE_LINE_AMOUNT from ' ||
        :OLD.invoice_line_amount || ' to ' || :NEW.invoice_line_amount, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.line_number <> :NEW.line_number OR
      (:OLD.line_number IS NULL AND :NEW.line_number IS NOT NULL) OR
      (:OLD.line_number IS NOT NULL AND :NEW.line_number IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', LINE_NUMBER from ' ||
        :OLD.line_number || ' to ' || :NEW.line_number, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.line_type_lookup_code <> :NEW.line_type_lookup_code OR
      (:OLD.line_type_lookup_code IS NULL AND :NEW.line_type_lookup_code IS NOT NULL) OR
      (:OLD.line_type_lookup_code IS NOT NULL AND :NEW.line_type_lookup_code IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', LINE_TYPE_LOOKUP_CODE from ' ||
        :OLD.line_type_lookup_code || ' to ' || :NEW.line_type_lookup_code, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.invoice_line_description <> :NEW.invoice_line_description OR
      (:OLD.invoice_line_description IS NULL AND :NEW.invoice_line_description IS NOT NULL) OR
      (:OLD.invoice_line_description IS NOT NULL AND :NEW.invoice_line_description IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', INVOICE_LINE_DESCRIPTION from ' ||
        :OLD.invoice_line_description || ' to ' || :NEW.invoice_line_description, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.exchange_rate_type <> :NEW.exchange_rate_type OR
      (:OLD.exchange_rate_type IS NULL AND :NEW.exchange_rate_type IS NOT NULL) OR
      (:OLD.exchange_rate_type IS NOT NULL AND :NEW.exchange_rate_type IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', EXCHANGE_RATE_TYPE from ' ||
        :OLD.exchange_rate_type || ' to ' || :NEW.exchange_rate_type, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.reversal_flag <> :NEW.reversal_flag OR
      (:OLD.reversal_flag IS NULL AND :NEW.reversal_flag IS NOT NULL) OR
      (:OLD.reversal_flag IS NOT NULL AND :NEW.reversal_flag IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', REVERSAL_FLAG from ' ||
        :OLD.reversal_flag || ' to ' || :NEW.reversal_flag, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.exchange_rate <> :NEW.exchange_rate OR
      (:OLD.exchange_rate IS NULL AND :NEW.exchange_rate IS NOT NULL) OR
      (:OLD.exchange_rate IS NOT NULL AND :NEW.exchange_rate IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', EXCHANGE_RATE from ' ||
        :OLD.exchange_rate || ' to ' || :NEW.exchange_rate, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.invoice_currency_code <> :NEW.invoice_currency_code OR
      (:OLD.invoice_currency_code IS NULL AND :NEW.invoice_currency_code IS NOT NULL) OR
      (:OLD.invoice_currency_code IS NOT NULL AND :NEW.invoice_currency_code IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', INVOICE_CURRENCY_CODE from ' ||
        :OLD.invoice_currency_code || ' to ' || :NEW.invoice_currency_code, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.payment_currency_code <> :NEW.payment_currency_code OR
      (:OLD.payment_currency_code IS NULL AND :NEW.payment_currency_code IS NOT NULL) OR
      (:OLD.payment_currency_code IS NOT NULL AND :NEW.payment_currency_code IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', PAYMENT_CURRENCY_CODE from ' ||
        :OLD.payment_currency_code || ' to ' || :NEW.payment_currency_code, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.date_actioned <> :NEW.date_actioned OR
      (:OLD.date_actioned IS NULL AND :NEW.date_actioned IS NOT NULL) OR
      (:OLD.date_actioned IS NOT NULL AND :NEW.date_actioned IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', DATE_ACTIONED from ' ||
        :OLD.date_actioned || ' to ' || :NEW.date_actioned, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.date_stamp <> :NEW.date_stamp OR
      (:OLD.date_stamp IS NULL AND :NEW.date_stamp IS NOT NULL) OR
      (:OLD.date_stamp IS NOT NULL AND :NEW.date_stamp IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', DATE_STAMP from ' ||
        :OLD.date_stamp || ' to ' || :NEW.date_stamp, 1, 550);
      l_write_aud := 'Y';
    END IF;
  ELSIF DELETING THEN
    aud.transaction_desc := 'Deleted record ' || :OLD.fusion_report_uid;
    l_write_aud := 'Y';
  END IF;

  -- Setting the logger values in case
  logger.append_param(l_params, 'Action:', aud.transaction_desc);

  -- Setting the Audit row values
  IF INSERTING OR UPDATING THEN
    aud.invoice_no                       := :NEW.invoice_no;
    aud.company_id_no                    := :NEW.company_id_no;
    aud.fusion_report_uid                := :NEW.fusion_report_uid;
    aud.fusion_report_reference          := :NEW.fusion_report_reference;
    aud.p_business_unit                  := :NEW.p_business_unit;
    aud.supplier_number                  := :NEW.supplier_number;
    aud.invoice_id                       := :NEW.invoice_id;
    aud.vendor_site_code                 := :NEW.vendor_site_code;
    aud.invoice_num                      := :NEW.invoice_num;
    aud.invoice_line_amount              := :NEW.invoice_line_amount;
    aud.line_number                      := :NEW.line_number;
    aud.line_type_lookup_code            := :NEW.line_type_lookup_code;
    aud.invoice_line_description         := :NEW.invoice_line_description;
    aud.reversal_flag                    := :NEW.reversal_flag;
    aud.exchange_rate_type               := :NEW.exchange_rate_type;
    aud.exchange_rate                    := :NEW.exchange_rate;
    aud.invoice_currency_code            := :NEW.invoice_currency_code;
    aud.payment_currency_code            := :NEW.payment_currency_code;
    aud.date_actioned                    := :NEW.date_actioned;
    aud.date_stamp                       := :NEW.date_stamp;
  ELSIF DELETING THEN
    aud.invoice_no                       := :OLD.invoice_no;
    aud.company_id_no                    := :OLD.company_id_no;
    aud.fusion_report_uid                := :OLD.fusion_report_uid;
    aud.fusion_report_reference          := :OLD.fusion_report_reference;
    aud.p_business_unit                  := :OLD.p_business_unit;
    aud.supplier_number                  := :OLD.supplier_number;
    aud.invoice_id                       := :OLD.invoice_id;
    aud.vendor_site_code                 := :OLD.vendor_site_code;
    aud.invoice_num                      := :OLD.invoice_num;
    aud.invoice_line_amount              := :OLD.invoice_line_amount;
    aud.line_number                      := :OLD.line_number;
    aud.line_type_lookup_code            := :OLD.line_type_lookup_code;
    aud.invoice_line_description         := :OLD.invoice_line_description;
    aud.reversal_flag                    := :OLD.reversal_flag;
    aud.exchange_rate_type               := :OLD.exchange_rate_type;
    aud.exchange_rate                    := :OLD.exchange_rate;
    aud.invoice_currency_code            := :OLD.invoice_currency_code;
    aud.payment_currency_code            := :OLD.payment_currency_code;
    aud.date_actioned                    := :OLD.date_actioned;
    aud.date_stamp                       := :OLD.date_stamp;
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
    INSERT INTO INVOICE_PAYMENTS_AUDIT VALUES aud;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      logger.log_error('Unhandled Exception', l_scope, null, l_params);
      -- dbms_output.put_line('Error Code is ' || TO_CHAR(SQLCODE ) );
      -- dbms_output.put_line('Error Message is ' || SQLERRM );
      RAISE;
END INVOICE_PAYMENTS_AUDIT_BEF_TRG;
/
