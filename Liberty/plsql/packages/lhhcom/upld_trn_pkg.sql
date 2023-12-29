CREATE OR REPLACE PACKAGE UPLD_TRN_PKG AS 

/**
* <pre>
* ----------------------------------------------------------------------
* Project:     : Commission Self Build
*
*                Description  : Procedures and Functions used by the Commission Self Build project
*                File Name    : Liberty\plsql\packages\lhhcom\upld_trn_pkg.sql
*                Author       : Sarel Eybers
*                Requirements : Access to account SCHEMA
*                Call Syntax  : Anonymous Block Example at the bottom of package header
*
*                Amendments   :
*                Date        User     Change Description
*                ========    ======== =================================================
*                2017/09/23  Sarel    Created Package
*                2018/02/08  Sarel    Allow Duplicates to have a Processed Date
*                2018/02/20  Sarel    Truncate amounts with more than 2 decimals
*
* </pre>         */

PROCEDURE UPLD_ALL;
PROCEDURE UPLD_PAYMENTS_RECEIVED (p_commit BOOLEAN DEFAULT FALSE);
PROCEDURE XFER_ALL;
PROCEDURE XFER_PAYMENTS_RECEIVED (p_commit BOOLEAN DEFAULT FALSE);

/* Anonymous Block Example
SET SERVEROUTPUT ON;
SELECT count(*) FROM util.upld_trn;
SELECT count(*) FROM lhhcom.comms_payments_received;
/
DECLARE
  lv_list_filename               VARCHAR2(50)
                                 := 'comms_payments_received';
  lv_ext_filename                VARCHAR2(50)
                                 := 'ext_comms_payments_received';
  lv_current_filename            VARCHAR2(50);
  lv_directory                   VARCHAR2(50)
                                 := 'LOGDATA';
  lv_check_file_exist            BOOLEAN;
BEGIN
  LHHCOM.UPLD_TRN_PKG.UPLD_ALL;
--  utl_file.fcopy(lv_directory,lv_list_filename||'.txt',lv_directory,lv_list_filename||'.dat');
--  SELECT * FROM ext_comms_payments_received;
--  SELECT count(*) FROM ext_comms_payments_received;
--  upld_trn_pkg.upld_payments_received(true); 
--  utl_file.fremove(lv_directory,lv_list_filename||'.txt');  
--  utl_file.fremove(lv_directory,lv_list_filename||'.dat'); 
--  utl_file.fremove('LOGDATA','comms_payments_received.dat');  
  LHHCOM.UPLD_TRN_PKG.XFER_ALL;
END;
/
SELECT count(*) FROM util.upld_trn;
SELECT count(*) FROM lhhcom.comms_payments_received;
*/

/* -- List the content of the BAD file
DECLARE
  file VARCHAR2(50) := 'ext_comms_payments_received.log';
  loc VARCHAR2(20) := 'LOGDATA';
  fid UTL_FILE.FILE_TYPE := UTL_FILE.FOPEN (loc, file, 'R');
  line VARCHAR2(2000);
BEGIN
  DBMS_OUTPUT.PUT_LINE (file);
  BEGIN
    LOOP
      UTL_FILE.GET_LINE (fid, line);
      DBMS_OUTPUT.PUT_LINE (line);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN UTL_FILE.FCLOSE (fid);
  END;
  utl_file.fremove(loc,file);  
END;
*/

END UPLD_TRN_PKG;

/

CREATE OR REPLACE PACKAGE BODY UPLD_TRN_PKG AS

-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

PROCEDURE XFER_ALL

AS

BEGIN
  XFER_PAYMENTS_RECEIVED(true);
END XFER_ALL;

-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

PROCEDURE XFER_PAYMENTS_RECEIVED (p_commit BOOLEAN DEFAULT FALSE)
  
AS

  gc_scope_prefix       constant VARCHAR2(31)           
                                 := lower($$PLSQL_UNIT) || '.';
  l_scope                        logger_logs.scope%TYPE 
                                 := 'CommissionsSelfBuild: ' || gc_scope_prefix;
  l_params                       logger.tab_param;
  lv_sys_param_date              VARCHAR2(50)           
                                 := get_system_parameter('LB_HEALTH_COMMS','SYSTEM','SYSTEM_START_DATE');
  ln_interf_system_id_no         NUMBER(2)    
                                 := 1;
  ln_interf_system_trn_type_no   NUMBER(2)    
                                 := 2;
  lv_username                    VARCHAR2(20) 
                                 := USER;
  lv_error                       util.upld_trn.error_desc%TYPE; 
  cpr                            comms_payments_received%ROWTYPE;
  lv_poli_id                     ohi_policies.poli_id%TYPE;
  lv_inse_id                     ohi_insured_entities.inse_id%TYPE;
  lv_enpr_id                     ohi_products.enpr_id%TYPE;
  lv_grac_id                     ohi_groups.grac_id%TYPE;

CURSOR c_xfer_receipts is
  SELECT ROWID, 
         upld_trn_no, 
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
         TRUNC(nvl(TRIM(replace(replace(substr(dataline,735,100),CHR(13),' '),CHR(10),' ')),0),2) finance_receipt_amt
    from util.upld_trn
   where interf_system_id_no  = ln_interf_system_id_no
     and trn_type_no          = ln_interf_system_trn_type_no
     and process_datetime     = to_date(lv_sys_param_date, 'DD-MON-YYYY');
     
BEGIN
  FOR x IN c_xfer_receipts LOOP
    BEGIN
      -- Setting the logger values in case of errors
      logger.append_param(l_params, 'Action:', 'UPLD_TRN_NO: ' || x.upld_trn_no);

      BEGIN -- Not NULL Amount Check
        cpr.finance_receipt_amt  := to_number(x.finance_receipt_amt);
        IF cpr.finance_receipt_amt IS NULL THEN
          raise_application_error(-20003,'Not INSERTING records with NULL amount values.');
        END IF;
      END;  -- Not NULL Amount Check

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
                   error_desc             = 'Upload Failed. Not a valid Policy Code: ' || x.policy_code,
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
                   error_desc             = 'Upload Failed. Not a valid Person Code: ' || x.person_code,
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
                   error_desc             = 'Upload Failed. Not a valid Product Code: ' || x.product_code,
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
                   error_desc             = 'Upload Failed. Not a valid Group Code: ' || x.group_code,
                   last_update_datetime   = sysdate,
                   username               = lv_username
             WHERE ROWID = x.rowid;
            -- dbms_output.put_line('Txn No: '|| x.upld_trn_no || ' - GROUP_CODE '|| x.group_code || ' does not exist.');
            RAISE;
      END;  -- Group Code Check
      IF lv_grac_id > 0 THEN
        cpr.group_code           := x.group_code;
      END IF;

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
      -- dbms_output.put_line('Txn No: ' || x.upld_trn_no || ' - POLICY_CODE: '|| x.policy_code || ' POLI_ID ' || lv_poli_id || ' PERSON_CODE: '|| x.person_code);

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
               process_datetime       = sysdate,
               error_desc             = 'Duplicate record. Cannot upload.',
               last_update_datetime   = sysdate,
               username               = lv_username
         WHERE ROWID = x.rowid;   
      WHEN OTHERS THEN
        IF SQLCODE = -20003 THEN
          dbms_output.put_line('Txn No: '|| x.upld_trn_no || ' - No NULL Amount Uploaded.');
          UPDATE util.upld_trn 
             SET
                 error_desc             = 'Not Uploaded. Amount is Missing.',
                 last_update_datetime   = sysdate,
                 username               = lv_username
           WHERE ROWID = x.rowid;
        ELSE
          lv_error := SUBSTR('Record failed to load. Other Error: ' || sqlerrm, 1, 450);
          dbms_output.put_line('Txn No: '|| x.upld_trn_no || ' - Other Error: ' || sqlerrm);
          UPDATE util.upld_trn 
             SET
                 error_desc             = lv_error,
                 last_update_datetime   = sysdate,
                 username               = lv_username
           WHERE ROWID = x.rowid;   
        END IF;
    END;
  END LOOP;
  IF p_commit
    THEN
      COMMIT;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    logger.log_error('Unhandled Exception', l_scope, null, l_params);
    dbms_output.put_line('Unhandled EXCEPTION Error: '||sqlerrm);

END XFER_PAYMENTS_RECEIVED;

-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

PROCEDURE UPLD_ALL

AS

  f_file                         utl_file.file_type;
  lv_list_filename               VARCHAR2(50)
                                 := 'comms_payments_received';
  lv_ext_filename                VARCHAR2(50)
                                 := 'ext_comms_payments_received';
  lv_current_filename            VARCHAR2(50);
  lv_directory                   VARCHAR2(50)
                                 := 'LOGDATA';
  lv_check_file_exist            BOOLEAN;
  lb_clob                        CLOB;
  lv_a                           NUMBER;
  lv_b                           NUMBER;
  e_process_running              EXCEPTION;
  e_bad_file_exist               EXCEPTION;

  CURSOR c_filenames IS
    SELECT Filename FROM util.ext_fusion_file_name;
   
BEGIN
  utl_file.fgetattr (lv_directory, lv_list_filename||'.dat', lv_check_file_exist, lv_a, lv_b );
  dbms_output.put_line('Step 01: DAT file Exists? ... ' || sys.diutil.bool_to_int(lv_check_file_exist));

  IF lv_check_file_exist THEN
    RAISE e_process_running;
  END IF;
   
  utl_file.fgetattr (lv_directory, lv_list_filename||'.txt', lv_check_file_exist, lv_a, lv_b );
  dbms_output.put_line('Step 02: TXT file Exists? ... ' || sys.diutil.bool_to_int(lv_check_file_exist));

  IF lv_check_file_exist THEN
    utl_file.fcopy(lv_directory,lv_list_filename||'.txt',lv_directory,lv_list_filename||'.dat');
    dbms_output.put_line('Step 03: Copy Done. ');

    upld_trn_pkg.upld_payments_received(true); 
    dbms_output.put_line('Step 04: Upload Done. ');

    -- check if bad file was created
    utl_file.fgetattr (lv_directory, lv_ext_filename||'.bad', lv_check_file_exist, lv_a, lv_b );
    dbms_output.put_line('Step 05: Bad file Exists? ... ' || sys.diutil.bool_to_int(lv_check_file_exist));

    IF lv_check_file_exist THEN
      utl_file.fcopy(lv_directory,lv_ext_filename||'.bad','UPLD_FUSION',lv_list_filename||to_char(sysdate,'yyyymmddhhmiss')||'.bad');  
      utl_file.fremove(lv_directory,lv_ext_filename||'.bad'); 
      dbms_output.put_line('Bad File: ' || lv_ext_filename || '.bad');
      RAISE e_bad_file_exist;
    ELSE
      utl_file.fcopy(lv_directory,lv_list_filename||'.txt','UPLD_FUSION',lv_list_filename||to_char(sysdate,'yyyymmddhhmiss')||'.txt');
      utl_file.fremove(lv_directory,lv_list_filename||'.txt');  
      --check if .dat file is still there and remove it
      utl_file.fgetattr (lv_directory, lv_list_filename||'.dat', lv_check_file_exist, lv_a, lv_b );
      IF lv_check_file_exist THEN
        utl_file.fremove(lv_directory,lv_list_filename||'.dat'); 
      END IF;
    END IF;
  END IF;

  --check if .log file was created and remove it
  utl_file.fgetattr (lv_directory, lv_ext_filename||'.log', lv_check_file_exist, lv_a, lv_b );
  IF lv_check_file_exist THEN
    utl_file.fremove(lv_directory,lv_ext_filename||'.log'); 
  END IF;
      
/*
  FOR x IN c_filenames LOOP
    lv_current_filename := x.filename;
    --run os command       
    dbms_output.put_line('Filename: ' || lv_current_filename);
  END LOOP;
*/

EXCEPTION
  WHEN e_bad_file_exist THEN
    utl_file.fremove(lv_directory,lv_list_filename||'.dat');  
    dbms_output.put_line('Caught Error: '||sqlerrm);  
  WHEN e_process_running THEN
    dbms_output.put_line('Process currently still running');
  WHEN OTHERS THEN
    utl_file.fremove(lv_directory,lv_list_filename||'.dat');  
    dbms_output.put_line('Caught Other Error: '||sqlerrm);

END UPLD_ALL;

-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

PROCEDURE UPLD_PAYMENTS_RECEIVED (p_commit BOOLEAN DEFAULT FALSE)

AS

  lv_sys_param_date              VARCHAR2(50)
                                 := get_system_parameter('LB_HEALTH_COMMS','SYSTEM','SYSTEM_START_DATE');
  ln_interf_system_id_no         NUMBER(2)    
                                 := 1;
  ln_interf_system_trn_type_no   NUMBER(2)    
                                 := 2;

  CURSOR c_receipts IS
    SELECT
           rpad(nvl(to_char(application_id)      , ' '), 100, ' ') || 
           rpad(nvl(finance_receipt_no           , ' '), 100, ' ') || 
           rpad(nvl(group_code                   , ' '), 100, ' ') || 
           rpad(nvl(country_code                 , ' '),   4, ' ') ||
           rpad(nvl(product_code                 , ' '), 100, ' ') || 
           rpad(nvl(policy_code                  , ' '), 100, ' ') || 
           rpad(nvl(person_code                  , ' '), 100, ' ') || 
           rpad(nvl(to_char(contribution_date)   , ' '),  10, ' ') ||
           rpad(nvl(to_char(finance_receipt_date), ' '),  10, ' ') ||
           rpad(nvl(to_char(finance_invoice_no)  , ' '), 100, ' ') || 
           rpad(nvl(to_char(finance_invoice_date), ' '),  10, ' ') ||
           rpad(nvl(to_char(finance_receipt_amt) , ' '), 100, ' ') dataline,
           finance_receipt_date
      FROM ext_comms_payments_received;

BEGIN
  FOR x IN c_receipts LOOP
    INSERT INTO util.upld_trn 
               (upld_trn_no
               ,detail_seq_no
               ,interf_system_id_no
               ,trn_type_no
               ,trn_sub_type_code
               ,process_datetime
               ,trn_datetime
               ,upld_trn_date
               ,dataline
               ,error_desc
               ,last_update_datetime
               ,username)
        VALUES (util.upld_trn_seq_no.NEXTVAL
               ,1
               ,ln_interf_system_id_no
               ,ln_interf_system_trn_type_no
               ,'N'
               ,TO_DATE(lv_sys_param_date, 'DD-MON-YYYY')
               ,x.finance_receipt_date
               ,SYSDATE
               ,x.dataline
               ,NULL
               ,SYSDATE
               ,USER);
  END LOOP;
  IF p_commit
    THEN
      COMMIT;
  END IF;
   
EXCEPTION
  WHEN dup_val_on_index THEN
    dbms_output.put_line('Duplicate Value on Index error - Skip over this line');

END UPLD_PAYMENTS_RECEIVED;
 
END UPLD_TRN_PKG;

/