SET SERVEROUTPUT ON;
DECLARE
  pv_username           VARCHAR2(100) := 'SAREL';
  pv_return_msg         VARCHAR2(500);
  ld_last_process_date  DATE;
  gc_scope_prefix       CONSTANT VARCHAR2(31)  := lower($$PLSQL_UNIT) || '.';
  l_scope               logger_logs.scope%TYPE := 'Commissions: ' || gc_scope_prefix;
  l_params              logger.tab_param;
  ln_invoice_no         NUMBER(9);
  ln_company_no         NUMBER(9);
  ln_amt                invoice_payments.invoice_line_amount%TYPE;
  ip                    invoice_payments%ROWTYPE;
  lv_processed_cnt      NUMBER(5);
  lv_updated_cnt        NUMBER(5);
  lv_inserted_cnt       NUMBER(5);
  lv_update_ind         VARCHAR2(1);
  lv_updated_datetime   DATE;
  lv_processed_inv      NUMBER(5);
  lv_updated_inv        NUMBER(5);
  lv_inv_paydate        invoice.payment_date%TYPE;
  lv_inv_payamt         invoice.payment_amt%TYPE;

CURSOR c_fusion_report IS
  SELECT 
         fusion_report_uid
        ,fusion_report_reference
        ,p_business_unit
        ,supplier_number
        ,invoice_id
        ,vendor_site_code
        ,invoice_num
        ,invoice_line_amount
        ,line_number
        ,line_type_lookup_code
        ,invoice_line_description
        ,reversal_flag
        ,exchange_rate_type
        ,exchange_rate
        ,invoice_currency_code
        ,payment_currency_code
        ,date_actioned
        ,date_stamp
    FROM fusion_report@fusion
   WHERE     fusion_report_reference =  'Commission_run'
         AND p_from_date             >= ld_last_process_date
         AND vendor_type_lookup_code like '%Broker%'
   ORDER BY check_if_number(invoice_num)
           ,line_type_lookup_code DESC
           ,date_stamp;

CURSOR c_processed_invoices IS
  SELECT invoice_no
        ,min(date_actioned)       payment_date
        ,sum(invoice_line_amount) payment_amount
    FROM invoice_payments
   WHERE     invoice_no IN (SELECT DISTINCT invoice_no
                              FROM invoice_payments
                             WHERE last_update_datetime = lv_updated_datetime)
         AND line_type_lookup_code = 'ITEM'
   GROUP BY invoice_no;

BEGIN
  lv_processed_cnt             := 0;
  lv_updated_cnt               := 0;
  lv_inserted_cnt              := 0;
  lv_processed_inv             := 0;
  lv_updated_inv               := 0;
  -- Setting the logger values in case of errors
  logger.append_param(l_params, 'COMMS_CALC_PKG.PROOF_OF_PAYMENT_UPDATE_RUN: ', 'RunDate ' 
                      || to_char(lv_updated_datetime , 'yyyy-Mon-dd hh24:mi:ss'));

  ld_last_process_date         := TO_DATE(get_system_parameter('LB_HEALTH_COMMS','FUSION','LAST_REMITTANCE_CHECK_DATE'),'dd-MON-yyyy');
  lv_updated_datetime          := SYSDATE;
  FOR x IN c_fusion_report LOOP
    lv_processed_cnt             := lv_processed_cnt + 1;
    ip.invoice_no                := NULL;
    ip.company_id_no             := NULL;
    ip.fusion_report_uid         := NULL;
    ip.fusion_report_reference   := NULL;
    ip.p_business_unit           := NULL;
    ip.supplier_number           := NULL;
    ip.invoice_id                := NULL;
    ip.vendor_site_code          := NULL;
    ip.invoice_num               := NULL;
    ip.invoice_line_amount       := NULL;
    ip.line_number               := NULL;
    ip.line_type_lookup_code     := NULL;
    ip.invoice_line_description  := NULL;
    ip.reversal_flag             := NULL;
    ip.exchange_rate_type        := NULL;
    ip.exchange_rate             := NULL;
    ip.invoice_currency_code     := NULL;
    ip.payment_currency_code     := NULL;
    ip.date_actioned             := NULL;
    ip.date_stamp                := NULL;
    ip.last_update_datetime      := NULL;
    ip.username                  := NULL;

    BEGIN -- Change Amount sign for "ITEM" records
      ln_amt                     := check_if_number(x.invoice_line_amount);
      IF trim(x.line_type_lookup_code) IN ('ITEM') THEN
        ln_amt                     := ln_amt * -1;
      END IF;
    END; -- Invoice No Check

    BEGIN -- Invoice No Check
      ln_invoice_no              := check_if_number(x.invoice_id);
      SELECT MAX(invoice_no) INTO ip.invoice_no
        FROM invoice
       WHERE invoice_no = ln_invoice_no
       GROUP BY invoice_no;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('Fusion Report UID: ' || x.fusion_report_uid || ' - Invoice No ' || x.invoice_id || ' does not link to a valid Invoice.');
--        logger.log_error('Fusion Report UID: ' || x.fusion_report_uid || ' - Invoice No ' || x.invoice_id || ' does not link to a valid Invoice.', l_scope, null, l_params);
    END; -- Invoice No Check
    
    BEGIN -- Company Id Check
      ln_company_no              := check_if_number(x.supplier_number);
      SELECT MAX(company_id_no) INTO ip.company_id_no
        FROM company
       WHERE company_id_no = ln_company_no
       GROUP BY company_id_no;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('Fusion Report UID: ' || x.fusion_report_uid || ' - Supplier ' || x.supplier_number || ' does not link to a valid Company.');
--        logger.log_error('Fusion Report UID: ' || x.fusion_report_uid || ' - Supplier ' || x.supplier_number || ' does not link to a valid Company.', l_scope, null, l_params);
    END; -- Company Id Check
    
    BEGIN -- Insert/Update Check
      SELECT DISTINCT
             invoice_no
            ,company_id_no
            ,fusion_report_uid
            ,fusion_report_reference
            ,p_business_unit
            ,supplier_number
            ,invoice_id
            ,vendor_site_code
            ,invoice_num
            ,invoice_line_amount
            ,line_number
            ,line_type_lookup_code
            ,invoice_line_description
            ,reversal_flag
            ,exchange_rate_type
            ,exchange_rate
            ,invoice_currency_code
            ,payment_currency_code
            ,date_actioned
            ,date_stamp
        INTO 
             ip.invoice_no
            ,ip.company_id_no
            ,ip.fusion_report_uid
            ,ip.fusion_report_reference
            ,ip.p_business_unit
            ,ip.supplier_number
            ,ip.invoice_id
            ,ip.vendor_site_code
            ,ip.invoice_num
            ,ip.invoice_line_amount
            ,ip.line_number
            ,ip.line_type_lookup_code
            ,ip.invoice_line_description
            ,ip.reversal_flag
            ,ip.exchange_rate_type
            ,ip.exchange_rate
            ,ip.invoice_currency_code
            ,ip.payment_currency_code
            ,ip.date_actioned
            ,ip.date_stamp
        FROM invoice_payments
       WHERE fusion_report_uid = x.fusion_report_uid;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END; -- Insert/Update Check
    
    BEGIN
      IF ip.fusion_report_uid IS NULL THEN                         -- Inserting
        lv_inserted_cnt             := lv_inserted_cnt + 1;
        ip.fusion_report_uid        := x.fusion_report_uid;
        ip.fusion_report_reference  := x.fusion_report_reference;
        ip.p_business_unit          := x.p_business_unit;
        ip.supplier_number          := x.supplier_number;
        ip.invoice_id               := x.invoice_id;
        ip.vendor_site_code         := x.vendor_site_code;
        ip.invoice_num              := x.invoice_num;
        ip.invoice_line_amount      := ln_amt;
        ip.line_number              := x.line_number;
        ip.line_type_lookup_code    := x.line_type_lookup_code;
        ip.invoice_line_description := x.invoice_line_description;
        ip.reversal_flag            := x.reversal_flag;
        ip.exchange_rate_type       := x.exchange_rate_type;
        ip.exchange_rate            := x.exchange_rate;
        ip.invoice_currency_code    := x.invoice_currency_code;
        ip.payment_currency_code    := x.payment_currency_code;
        ip.date_actioned            := x.date_actioned;
        ip.date_stamp               := x.date_stamp;
        ip.last_update_datetime     := lv_updated_datetime;
        ip.username                 := pv_username;
        dbms_output.put_line('Inserting Fusion Report UID: ' || ip.fusion_report_uid || ' - Company ' || ip.company_id_no || ' and Invoice ' || ip.invoice_no || ' for Amount ' || ip.invoice_line_amount);
        INSERT INTO invoice_payments VALUES ip;
      ELSE                                                    -- Maybe Updating
        lv_update_ind               := NULL;
        IF x.fusion_report_reference <> ip.fusion_report_reference OR
          (x.fusion_report_reference IS NULL AND ip.fusion_report_reference IS NOT NULL) OR
          (x.fusion_report_reference IS NOT NULL AND ip.fusion_report_reference IS NULL) THEN
          ip.fusion_report_reference := x.fusion_report_reference;
          lv_update_ind := 'Y';
        END IF;
        IF x.p_business_unit <> ip.p_business_unit OR
          (x.p_business_unit IS NULL AND ip.p_business_unit IS NOT NULL) OR
          (x.p_business_unit IS NOT NULL AND ip.p_business_unit IS NULL) THEN
          ip.p_business_unit := x.p_business_unit;
          lv_update_ind := 'Y';
        END IF;
        IF x.supplier_number <> ip.supplier_number OR
          (x.supplier_number IS NULL AND ip.supplier_number IS NOT NULL) OR
          (x.supplier_number IS NOT NULL AND ip.supplier_number IS NULL) THEN
          ip.supplier_number := x.supplier_number;
          lv_update_ind := 'Y';
        END IF;
        IF x.invoice_id <> ip.invoice_id OR
          (x.invoice_id IS NULL AND ip.invoice_id IS NOT NULL) OR
          (x.invoice_id IS NOT NULL AND ip.invoice_id IS NULL) THEN
          ip.invoice_id := x.invoice_id;
          lv_update_ind := 'Y';
        END IF;
        IF x.vendor_site_code <> ip.vendor_site_code OR
          (x.vendor_site_code IS NULL AND ip.vendor_site_code IS NOT NULL) OR
          (x.vendor_site_code IS NOT NULL AND ip.vendor_site_code IS NULL) THEN
          ip.vendor_site_code := x.vendor_site_code;
          lv_update_ind := 'Y';
        END IF;
        IF x.invoice_num <> ip.invoice_num OR
          (x.invoice_num IS NULL AND ip.invoice_num IS NOT NULL) OR
          (x.invoice_num IS NOT NULL AND ip.invoice_num IS NULL) THEN
          ip.invoice_num := x.invoice_num;
          lv_update_ind := 'Y';
        END IF;
        IF ln_amt <> ip.invoice_line_amount OR
          (ln_amt IS NULL AND ip.invoice_line_amount IS NOT NULL) OR
          (ln_amt IS NOT NULL AND ip.invoice_line_amount IS NULL) THEN
          ip.invoice_line_amount := ln_amt;
          lv_update_ind := 'Y';
        END IF;
        IF x.line_number <> ip.line_number OR
          (x.line_number IS NULL AND ip.line_number IS NOT NULL) OR
          (x.line_number IS NOT NULL AND ip.line_number IS NULL) THEN
          ip.line_number := x.line_number;
          lv_update_ind := 'Y';
        END IF;
        IF x.line_type_lookup_code <> ip.line_type_lookup_code OR
          (x.line_type_lookup_code IS NULL AND ip.line_type_lookup_code IS NOT NULL) OR
          (x.line_type_lookup_code IS NOT NULL AND ip.line_type_lookup_code IS NULL) THEN
          ip.line_type_lookup_code := x.line_type_lookup_code;
          lv_update_ind := 'Y';
        END IF;
        IF x.invoice_line_description <> ip.invoice_line_description OR
          (x.invoice_line_description IS NULL AND ip.invoice_line_description IS NOT NULL) OR
          (x.invoice_line_description IS NOT NULL AND ip.invoice_line_description IS NULL) THEN
          ip.invoice_line_description := x.invoice_line_description;
          lv_update_ind := 'Y';
        END IF;
        IF x.exchange_rate_type <> ip.exchange_rate_type OR
          (x.exchange_rate_type IS NULL AND ip.exchange_rate_type IS NOT NULL) OR
          (x.exchange_rate_type IS NOT NULL AND ip.exchange_rate_type IS NULL) THEN
          ip.exchange_rate_type := x.exchange_rate_type;
          lv_update_ind := 'Y';
        END IF;
        IF x.exchange_rate <> ip.exchange_rate OR
          (x.exchange_rate IS NULL AND ip.exchange_rate IS NOT NULL) OR
          (x.exchange_rate IS NOT NULL AND ip.exchange_rate IS NULL) THEN
          ip.exchange_rate := x.exchange_rate;
          lv_update_ind := 'Y';
        END IF;
        IF x.invoice_currency_code <> ip.invoice_currency_code OR
          (x.invoice_currency_code IS NULL AND ip.invoice_currency_code IS NOT NULL) OR
          (x.invoice_currency_code IS NOT NULL AND ip.invoice_currency_code IS NULL) THEN
          ip.invoice_currency_code := x.invoice_currency_code;
          lv_update_ind := 'Y';
        END IF;
        IF x.payment_currency_code <> ip.payment_currency_code OR
          (x.payment_currency_code IS NULL AND ip.payment_currency_code IS NOT NULL) OR
          (x.payment_currency_code IS NOT NULL AND ip.payment_currency_code IS NULL) THEN
          ip.payment_currency_code := x.payment_currency_code;
          lv_update_ind := 'Y';
        END IF;
        IF x.date_actioned <> ip.date_actioned OR
          (x.date_actioned IS NULL AND ip.date_actioned IS NOT NULL) OR
          (x.date_actioned IS NOT NULL AND ip.date_actioned IS NULL) THEN
          ip.date_actioned := x.date_actioned;
          lv_update_ind := 'Y';
        END IF;
        IF x.date_stamp <> ip.date_stamp OR
          (x.date_stamp IS NULL AND ip.date_stamp IS NOT NULL) OR
          (x.date_stamp IS NOT NULL AND ip.date_stamp IS NULL) THEN
          ip.date_stamp := x.date_stamp;
          lv_update_ind := 'Y';
        END IF;
        IF lv_update_ind IS NULL THEN
          dbms_output.put_line('No action needed on Fusion Report UID: ' || ip.fusion_report_uid || ' - Company ' || ip.company_id_no || ' and Invoice ' || ip.invoice_no || ' for Amount ' || ip.invoice_line_amount);
        ELSE
          lv_updated_cnt              := lv_updated_cnt + 1;
          dbms_output.put_line('Updating Fusion Report UID: ' || ip.fusion_report_uid || ' - Company ' || ip.company_id_no || ' and Invoice ' || ip.invoice_no || ' for Amount ' || ip.invoice_line_amount);
          UPDATE invoice_payments 
             SET 
                 invoice_no                       = ip.invoice_no
                ,company_id_no                    = ip.company_id_no
                ,fusion_report_reference          = ip.fusion_report_reference
                ,p_business_unit                  = ip.p_business_unit
                ,supplier_number                  = ip.supplier_number
                ,invoice_id                       = ip.invoice_id
                ,vendor_site_code                 = ip.vendor_site_code
                ,invoice_num                      = ip.invoice_num
                ,invoice_line_amount              = ip.invoice_line_amount
                ,line_number                      = ip.line_number
                ,line_type_lookup_code            = ip.line_type_lookup_code
                ,invoice_line_description         = ip.invoice_line_description
                ,exchange_rate_type               = ip.exchange_rate_type
                ,exchange_rate                    = ip.exchange_rate
                ,invoice_currency_code            = ip.invoice_currency_code
                ,payment_currency_code            = ip.payment_currency_code
                ,date_actioned                    = ip.date_actioned
                ,date_stamp                       = ip.date_stamp
                ,last_update_datetime             = lv_updated_datetime
                ,username                         = pv_username
           WHERE fusion_report_uid = x.fusion_report_uid;
        END IF;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('Fusion Report UID: ' || x.fusion_report_uid || ' - Supplier ' || x.supplier_number || ' does not link to a valid Company.');
--        logger.log_error('Fusion Report UID: ' || x.fusion_report_uid || ' - Supplier ' || x.supplier_number || ' does not link to a valid Company.', l_scope, null, l_params);
    END;
  END LOOP;
   
  FOR y IN c_processed_invoices LOOP
    lv_processed_inv             := lv_processed_inv + 1;
    BEGIN -- Invoice Check
      SELECT invoice_no
            ,payment_date
            ,payment_amt
        INTO ln_invoice_no
            ,lv_inv_paydate
            ,lv_inv_payamt
        FROM invoice
       WHERE invoice_no = y.invoice_no;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('Updating Invoice Error: Invoice No ' || y.invoice_no || ' does not link to a valid Invoice.');
--        logger.log_error('Updating Invoice Error: Invoice No ' || y.invoice_no || ' does not link to a valid Invoice.', l_scope, null, l_params);
    END; -- Invoice No Check
    IF     lv_inv_paydate  <> y.payment_date
       OR  (lv_inv_paydate IS NULL     AND y.payment_date IS NOT NULL)
       OR  (lv_inv_paydate IS NOT NULL AND y.payment_date IS NULL)
       OR  lv_inv_payamt   <> y.payment_amount
       OR  (lv_inv_payamt  IS NULL     AND y.payment_amount IS NOT NULL)
       OR  (lv_inv_payamt  IS NOT NULL AND y.payment_amount IS NULL) THEN
      lv_updated_inv              := lv_updated_inv + 1;
      UPDATE invoice
         SET payment_date   = y.payment_date
            ,payment_amt    = y.payment_amount
            ,last_update_datetime = lv_updated_datetime
            ,username = pv_username
       WHERE invoice_no = y.invoice_no;
    END IF;
  END LOOP;

  UPDATE system_parameter
        SET parameter_value = trunc(lv_updated_datetime),
            last_update_datetime = lv_updated_datetime,
            username = pv_username
      WHERE parameter_key = 'LAST_REMITTANCE_CHECK_DATE'
        AND parameter_section = 'FUSION'
        AND system_name = 'LB_HEALTH_COMMS';

  pv_return_msg := 'Status:
    ' || lv_processed_cnt || ' AP Report records processed - ' || lv_inserted_cnt || ' records inserted and ' || lv_updated_cnt || ' records updated
    ' || lv_processed_inv || ' Invoice records processed and ' || lv_updated_inv || ' records updated';
  dbms_output.put_line('Final Count: ' || pv_return_msg);

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    logger.log_error('System failed with unhandled exception in comms_calc_pkg.proof_of_payment_update_run. Exception desc: 
      ' || sqlerrm, l_scope, null, l_params);
	  pv_return_msg := 'System failed with error: 
      ' || sqlerrm;
    dbms_output.put_line(pv_return_msg);
	  UPDATE system_parameter  --this is to catch any date format errors as the users can manually update the date via the application.
       SET parameter_value = trunc(lv_updated_datetime)-1,
           last_update_datetime = lv_updated_datetime,
           username = pv_username
     WHERE parameter_key = 'LAST_REMITTANCE_CHECK_DATE'
       AND parameter_section = 'FUSION'
       AND system_name = 'LB_HEALTH_COMMS';
    COMMIT;
END;