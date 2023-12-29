/*
  SELECT ROWID, 
         upld_trn_no, 
--         TRIM(substr(dataline,0,100)) || upld_trn_no application_id,
         TRIM(substr(dataline,0,100))                application_id,
         TRIM(substr(dataline,101,100))              finance_receipt_no, 
         TRIM(substr(dataline,201,100))              group_code,
         TRIM(substr(dataline,301,4))                country_code, 
         TRIM(substr(dataline,305,100))              product_code,
         TRIM(substr(dataline,405,100))              policy_code,
         TRIM(substr(dataline,505,100))              person_code,
         TRIM(substr(dataline,605,10))               contribution_date,
         TRIM(substr(dataline,615,10))               finance_receipt_date,
         TRIM(substr(dataline,625,100))              finance_invoice_no,
         TRIM(substr(dataline,725,10))               finance_invoice_date,
         TRIM(substr(dataline,735,100))              finance_receipt_amt
    from util.upld_trn
   where interf_system_id_no  = 1
     and trn_type_no          = 2
     and process_datetime     = to_date(get_system_parameter('LB_HEALTH_COMMS','SYSTEM','SYSTEM_START_DATE'));
*/
/*
delete from COMMS_PAYMENTS_RECEIVED;
UPDATE util.upld_trn SET
  error_desc             = NULL,
  last_update_datetime   = sysdate,
  process_datetime       = to_date(get_system_parameter('LB_HEALTH_COMMS','SYSTEM','SYSTEM_START_DATE'), 'DD-MON-YYYY'),
  username               = ' '
  where UPLD_TRN_NO < 1000;
commit;
SELECT upld_trn_no, process_datetime, error_desc, dataline from util.upld_trn; where upld_trn_no between 1300 and 1350 order by PROCESS_DATETIME Desc;
*/

/*
cursor c_validate_data is
  select 
         cpr.country_code              cprCntry
        ,grac.group_code               gracGroup
        ,prod.product_code             prodProd
        ,poep.poep_id                  poepPoep
        ,poli.policy_code              poliPolicy
        ,inse.inse_code                inseCode
        ,pobr.broker_id_no             pobrBroker
        ,pobr.company_id_no            pobrCompany
        ,cpr.contribution_date         cprSubsDate
    from COMMS_PAYMENTS_RECEIVED       cpr
    inner  
    join (
          select 
                 trim(policy_code)     policy_cde
                ,max(poli_id)          max_poli
            from OHI_POLICIES
--           where last_update_datetime  <= cpr.contribution_date
           group by trim(policy_code)
         )                             maxpoli
      on maxpoli.policy_cde            = trim(cpr.policy_code)
    inner  
    join OHI_POLICIES                  poli
      on trim(poli.policy_code)        = maxpoli.policy_cde
     and poli.poli_id                  = maxpoli.max_poli
    left outer 
    join OHI_GROUPS                    grac
      on grac.grac_id                  = poli.grac_id
    left outer 
    join OHI_POLICY_ENROLLMENTS        poen
      on poen.poli_id                  = poli.poli_id
    inner  
    join OHI_INSURED_ENTITIES          inse
      on inse.inse_id                  = poen.inse_id
     and trim(inse.INSE_CODE)          = trim(cpr.person_code)
    left outer 
    join OHI_ENROLLMENT_PRODUCTS       poep
      on poep.poen_id                  = poen.poen_id
    left outer 
    join OHI_PRODUCTS                  prod
      on prod.product_code             = cpr.product_code
    left outer 
    join OHI_POLICY_BROKERS            pobr
      on pobr.poli_id                  = poli.poli_id
   where cpr.policy_code = '5074444'
--   where cpr.group_code = 'M2M';
   order by cpr.policy_code;
*/

DECLARE

  gc_scope_prefix       constant VARCHAR2(31)           
                                 := lower($$PLSQL_UNIT) || '.';
  l_scope                        logger_logs.scope%type 
                                 := 'CommissionsSelfBuild: ' || gc_scope_prefix;
  l_params                       logger.tab_param;
  lv_sys_param_date              VARCHAR2(50)           
--                                 := SYSDATE;
                                 := get_system_parameter('LB_HEALTH_COMMS','SYSTEM','SYSTEM_START_DATE');
  ln_interf_system_id_no         NUMBER(2)    
                                 := 1;
  ln_interf_system_trn_type_no   NUMBER(2)    
                                 := 2;
  lv_username                    VARCHAR2(20) 
                                 := USER;
  cpr                            comms_payments_received%rowtype;
  lv_poli_id                     ohi_policies.poli_id%type;
  lv_inse_id                     ohi_insured_entities.inse_id%type;
  lv_enpr_id                     ohi_products.enpr_id%type;
  lv_grac_id                     ohi_groups.grac_id%type;

cursor c_xfer_receipts is
  select rowid, 
         upld_trn_no, 
         trim(substr(dataline,0,100)) || upld_trn_no application_id,
--         trim(substr(dataline,0,100))                application_id,
         trim(substr(dataline,101,100))              finance_receipt_no, 
         trim(substr(dataline,201,100))              group_code,
         trim(substr(dataline,301,4))                country_code, 
         trim(substr(dataline,305,100))              product_code,
         trim(substr(dataline,405,100))              policy_code,
         trim(substr(dataline,505,100))              person_code,
         trim(substr(dataline,605,10))               contribution_date,
         trim(substr(dataline,615,10))               finance_receipt_date,
         trim(substr(dataline,625,100))              finance_invoice_no,
         trim(substr(dataline,725,10))               finance_invoice_date,
         trim(substr(dataline,735,100))              finance_receipt_amt
    from util.upld_trn
   where interf_system_id_no  = ln_interf_system_id_no
     and trn_type_no          = ln_interf_system_trn_type_no
--     and process_datetime     = '01/JAN/17'
--     and process_datetime     = to_date(lv_sys_param_date)
     and upld_trn_no between 1300 and 1350;
     
BEGIN
  FOR x IN c_xfer_receipts LOOP
    BEGIN
      -- Setting the logger values in case of errors
      logger.append_param(l_params, 'Action:', 'UPLD_TRN_NO: ' || x.upld_trn_no);

      BEGIN -- Not Zero Amount Check
        cpr.finance_receipt_amt  := to_number(substr(x.finance_receipt_amt,0,length(x.finance_receipt_amt)-1));
        IF cpr.finance_receipt_amt = 0 THEN
          raise_application_error(-20003,'Not INSERTING records with zero amount values.');
        END IF;
      END;  -- Not Zero Amount Check

      BEGIN -- Policy Code Check
        lv_poli_id := NULL;
        SELECT MAX(poli_id) INTO lv_poli_id
          FROM ohi_policies
         WHERE policy_code = x.policy_code
         GROUP BY policy_code;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            UPDATE util.upld_trn 
               SET
                   error_desc             = 'Upload Failed. Not a valid Policy Code.',
                   last_update_datetime   = sysdate,
                   username               = lv_username
             WHERE ROWID = x.rowid;
            -- dbms_output.put_line('Txn No: '|| x.upld_trn_no || ' - POLICY_CODE '|| x.policy_code || ' does not exist.');
            RAISE;
      END;  -- Policy Code Check
      IF lv_poli_id > 0 THEN
        cpr.policy_code          := x.policy_code;
      END IF;
       
      BEGIN -- Person Code Check
        lv_inse_id := NULL;
        SELECT MAX(inse_id) INTO lv_inse_id
          FROM ohi_insured_entities
         WHERE inse_code = x.person_code
         GROUP BY inse_code;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            UPDATE util.upld_trn 
               SET
                   error_desc             = 'Upload Failed. Not a valid Person Code.',
                   last_update_datetime   = sysdate,
                   username               = lv_username
             WHERE ROWID = x.rowid;
            -- dbms_output.put_line('Txn No: '|| x.upld_trn_no || ' - PERSON_CODE '|| x.person_code || ' does not exist.');
            RAISE;
      END;  -- Person Code Check
      IF lv_inse_id > 0 THEN
        cpr.person_code          := x.person_code;
      END IF;
       
      BEGIN -- Product Code Check
        lv_enpr_id := NULL;
        SELECT MAX(enpr_id) INTO lv_enpr_id
          FROM ohi_products
         WHERE product_code = x.product_code
         GROUP BY product_code;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            UPDATE util.upld_trn 
               SET
                   error_desc             = 'Upload Failed. Not a valid Product Code.',
                   last_update_datetime   = sysdate,
                   username               = lv_username
             WHERE ROWID = x.rowid;
            -- dbms_output.put_line('Txn No: '|| x.upld_trn_no || ' - PRODUCT_CODE '|| x.product_code || ' does not exist.');
            RAISE;
      END;  -- Person Code Check
      IF lv_enpr_id > 0 THEN
        cpr.product_code         := x.product_code;
      END IF;

      BEGIN -- Group Code Check
        lv_grac_id := NULL;
        SELECT MAX(grac_id) INTO lv_grac_id
          FROM ohi_groups
         WHERE group_code = x.group_code
         GROUP BY group_code;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            UPDATE util.upld_trn 
               SET
                   error_desc             = 'Upload Failed. Not a valid Group Code.',
                   last_update_datetime   = sysdate,
                   username               = lv_username
             WHERE ROWID = x.rowid;
            -- dbms_output.put_line('Txn No: '|| x.upld_trn_no || ' - GROUP_CODE '|| x.group_code || ' does not exist.');
            RAISE;
      END;  -- Group Code Check
      IF lv_grac_id > 0 THEN
        cpr.group_code           := x.group_code;
      END IF;

    -- dbms_output.put_line('Txn No: ' || x.upld_trn_no || ' - POLICY_CODE: '|| x.policy_code || ' POLI_ID ' || lv_poli_id || ' PERSON_CODE: '|| x.person_code);

      -- Setting the rest of the Values
      cpr.application_id       := x.application_id;
      cpr.country_code         := x.country_code;
      cpr.contribution_date    := x.contribution_date;
      cpr.finance_receipt_no   := x.finance_receipt_no;
      cpr.finance_receipt_date := x.finance_receipt_date;
      cpr.finance_invoice_no   := x.finance_invoice_no;
      cpr.finance_invoice_date := x.finance_invoice_date;
      cpr.processed_ind        := 'N';
      cpr.last_update_datetime := SYSDATE;
      cpr.username             := USER;

      -- Writing the Values to Comms Payments Received
      INSERT INTO comms_payments_received VALUES cpr;

      -- Update Upload Transaction on Success
      UPDATE util.upld_trn 
         SET
             process_datetime           = sysdate,
             error_desc                 = NULL,
             last_update_datetime       = sysdate,
             username                   = lv_username
       WHERE ROWID = x.rowid;   

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
        -- dbms_output.put_line('Txn No: '|| x.upld_trn_no || ' - No OHI Data Found.');
      WHEN DUP_VAL_ON_INDEX THEN
        -- dbms_output.put_line('Txn No: '|| x.upld_trn_no || ' - Duplicate Value on Index.');
        UPDATE util.upld_trn 
           SET
               error_desc             = 'Duplicate record. Cannot upload.',
               last_update_datetime   = sysdate,
               username               = lv_username
         WHERE ROWID = x.rowid;   
      WHEN OTHERS THEN
        IF SQLCODE = -20003 THEN
          -- dbms_output.put_line('Txn No: '|| x.upld_trn_no || ' - No Zero Amount Uploaded.');
          UPDATE util.upld_trn 
             SET
                 error_desc             = 'Not Uploaded. Amount is Zero.',
                 last_update_datetime   = sysdate,
                 username               = lv_username
           WHERE ROWID = x.rowid;
        ELSE
          -- dbms_output.put_line('Txn No: '|| x.upld_trn_no || ' - Other Error: ' || sqlerrm);
          UPDATE util.upld_trn 
             SET
                 error_desc             = 'Record failed to load.',
                 last_update_datetime   = sysdate,
                 username               = lv_username
           WHERE ROWID = x.rowid;   
        END IF;
    END;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    logger.log_error('Unhandled Exception', l_scope, null, l_params);
    -- dbms_output.put_line('Unhandled Exception Error: '||sqlerrm);

END;
