CREATE OR REPLACE EDITIONABLE PACKAGE "LHHCOM"."DNLD_OHI_POLICIES_PKG" 

AS

/**
* <pre>
* ----------------------------------------------------------------------
* Project:     : Commission Self Build
*
*                Description  : General Procedures used for OHI Policies Procedures
*                File Name    : Liberty\plsql\packages\lhhcom\dnld_ohi_policies_pkg.sql
*                Author       : Sarel Eybers
*                Requirements : Access to LHHCOM schema
*                Call Syntax  : Anonymous Block Example below the package header
*
*                Amendments   :
*                Date        User     Change Description
*                ========    ======== =================================================
*                2017/12/01  Johan    Created First Procedures
*                2018/02/20  Sarel    Add to Comissions Source and Jobs
*                2018/09/13  Sarel    Additional Error Handling built in (also exclude incorrect countries) - OP-110
*                2018/09/13  Sarel    Change Character Set to UTF-8 for OHI - OM-424
*
* </pre>         */

PROCEDURE bulk_broker_load;
PROCEDURE broker_load                  (p_commit  IN  BOOLEAN DEFAULT FALSE);
PROCEDURE export_company_to_ohi        (p_id             IN  NUMBER
                                       ,p_return_msg     OUT VARCHAR2);

END DNLD_OHI_POLICIES_PKG;

/
--------------------------------------------------------
--  DDL for Package Body DNLD_OHI_POLICIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "LHHCOM"."DNLD_OHI_POLICIES_PKG" 

  AS

/**
  * Contains various OHI Procedures used in the Commissions System
  * */
  
/**********************************************************************************************************************/

 g_log_file_name     VARCHAR2(400);
 g_output_file_name  VARCHAR2(400);
 g_directory         VARCHAR2(100) DEFAULT 'LOGDATA';
 g_logger_identifier NUMBER;

PROCEDURE export_company_to_ohi        (p_id             IN  NUMBER
                                       ,p_return_msg     OUT VARCHAR2)

IS

  gc_scope_prefix       CONSTANT VARCHAR2(31)           
                                 := lower($$PLSQL_UNIT) || '.';
  l_scope                        logger_logs.scope%TYPE 
                                 := 'CommissionsSelfBuild: ' || gc_scope_prefix;
  l_params                       logger.tab_param;

  lv_company_id                  NUMBER;
  lv_broker_id                   NUMBER;
  lv_err                         VARCHAR2(1);
  lv_url                         VARCHAR(400);
  lv_username                    VARCHAR(400);
  lv_password                    VARCHAR(400);
  lv_ssl_wallet                  VARCHAR(400);
  lv_name                        VARCHAR2(30);
  lv_content                     VARCHAR2(4000);
  lv_country_string              VARCHAR2(4000);
  lv_country                     VARCHAR2(4000);
  lv_req                         utl_http.req;
  lv_res                         utl_http.resp;
  lv_response                    VARCHAR2(4000);
  lv_processed_cnt               NUMBER(5);
  lv_processed_failed            NUMBER(5);
  lv_header_name                 VARCHAR2(256);
  lv_header_value                VARCHAR2(256);
  
  CURSOR   c_get_companies IS
    SELECT c.company_id_no
          ,c.company_name
          ,NVL(c.effective_start_date, to_date(get_system_parameter('LB_HEALTH_COMMS','SYSTEM','SYSTEM_START_DATE'))) effective_start_date
          ,NVL(c.effective_end_date, to_date('3100/01/31', 'YYYY/MM/DD')) effective_end_date
      FROM company c
      JOIN company_country cc
        ON c.company_id_no = cc.company_id_no
     WHERE c.company_id_no = NVL(p_id, c.company_id_no);
  CURSOR   c_get_countries IS
    SELECT country_code
          ,NVL(effective_start_date, to_date(get_system_parameter('LB_HEALTH_COMMS','SYSTEM','SYSTEM_START_DATE'))) effective_start_date
          ,NVL(effective_end_date, to_date('3100/01/31', 'YYYY/MM/DD')) effective_end_date
      FROM company_country
     WHERE company_id_no = lv_company_id;

BEGIN 
  -- Initialize values
  p_return_msg                 := NULL;
  lv_url                       := NULL;
  lv_username                  := NULL;
  lv_password                  := NULL;
  lv_ssl_wallet                := NULL;
  lv_processed_cnt             := 0;
  lv_processed_failed          := 0;

  -- Get OHI Policies API server link, username, password and wallet address
  SELECT get_system_parameter('LB_HEALTH_COMMS','OHI','SERVER_LINK') 
    INTO lv_url 
    FROM dual;
  SELECT get_system_parameter('LB_HEALTH_COMMS','OHI','USERNAME') 
    INTO lv_username
    FROM dual;
  SELECT get_system_parameter('LB_HEALTH_COMMS','OHI','PASSWORD') 
    INTO lv_password
    FROM dual;
  SELECT get_system_parameter('LB_HEALTH_COMMS','OHI','SSL_WALLET') 
    INTO lv_ssl_wallet
    FROM dual;
  IF lv_ssl_wallet IS NOT NULL THEN
    utl_http.set_wallet(lv_ssl_wallet, null);
  END IF;

  -- Start with the Company Details
  FOR c IN c_get_companies LOOP
   commissions_pkg.write_to_file(  g_log_file_name,'Updated or new company information found to send to OHI '||c.company_id_no);
    -- Initialize values
    lv_company_id                := c.company_id_no;
    lv_broker_id                 := NULL;
    lv_country_string            := NULL;
    lv_country                   := NULL;
    lv_name                      := NULL;
    lv_req                       := NULL;
    lv_res                       := NULL;
    lv_err                       := NULL;
    lv_response                  := NULL;
    lv_processed_cnt             := lv_processed_cnt + 1;

    -- Get OHI Policies Broker ID if it exists
    SELECT max(br.id)
      INTO lv_broker_id    
      FROM pol_brokers_v@policies.liberty.co.za  br
     WHERE br.code = lv_company_id;

    -- Set INSERT/UPDATE action
    IF lv_broker_id IS NOT NULL THEN
      commissions_pkg.write_to_file(g_log_file_name,'Update for Broker ' || lv_company_id  || lv_broker_id ||
      'URL: ' || lv_url || 'brokers' || '/' || lv_broker_id || ' - PUT - HTTP/1.1');
     /* dbms_output.put_line('Update for Broker ' || lv_company_id || ' (' || lv_broker_id || ')
      URL: ' || lv_url || 'brokers' || '/' || lv_broker_id || ' - PUT - HTTP/1.1');*/
      lv_req    := utl_http.begin_request(lv_url || 'brokers' || '/' || lv_broker_id, 'PUT', 'HTTP/1.1');
      --How to delete a Company record from OHI
      --lv_req    := utl_http.begin_request(lv_url || 'brokers' || '/' || lv_broker_id, 'DELETE', 'HTTP/1.1');
    ELSE
      commissions_pkg.write_to_file(g_log_file_name,'Insert for Broker ' || lv_company_id || '
      URL: ' || lv_url || 'brokers - POST - HTTP/1.1');
    --  dbms_output.put_line('Insert for Broker ' || lv_company_id || '
    --  URL: ' || lv_url || 'brokers - POST - HTTP/1.1');
      lv_req    := utl_http.begin_request(lv_url || 'brokers', 'POST', 'HTTP/1.1');
    END IF;

    -- Populate Country String
    FOR x IN c_get_countries LOOP
      BEGIN
        SELECT DISTINCT 'X' into lv_country FROM fcod_country@policies.liberty.co.za WHERE code = x.country_code;
        IF x.effective_start_date < x.effective_end_date THEN
          lv_country_string := lv_country_string                             || ',
            {"value": "'     || x.country_code                               || '",
             "NAME": "'      || lv_name                                      || '",
             "startDate": "' || to_char(x.effective_start_date,'YYYY-MM-DD') || '",
             "endDate": "'   || to_char(x.effective_end_date,'YYYY-MM-DD')   || '"}'; 
        END IF;
      EXCEPTION    
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
    END LOOP;
    lv_country := SUBSTR(lv_country_string, 2);

    -- Build Request Content
    IF lv_country IS NOT NULL THEN
      lv_content := ' 
        {"Broker id": "' || lv_broker_id                                  || '", 
         "code": "'      || lv_company_id                                 || '", 
         "name": "'      || c.company_name                                || '",
         "STARTDATE": "' || to_char(c.effective_start_date, 'YYYY-MM-DD') || '",
         "ENDDATE": "'   || to_char(c.effective_end_date, 'YYYY-MM-DD')   || '",
         "COUNTRY": [ '  || lv_country                                    || ']}';
    ELSE
      lv_content := ' 
        {"Broker id": "' || lv_broker_id                                  || '", 
         "code": "'      || lv_company_id                                 || '", 
         "name": "'      || c.company_name                                || '",
         "STARTDATE": "' || to_char(c.effective_start_date, 'YYYY-MM-DD') || '",
         "ENDDATE": "'   || to_char(c.effective_end_date, 'YYYY-MM-DD')   || '"}';
    END IF;
    commissions_pkg.write_to_file(g_log_file_name,'Information Sent is: '||lv_content);

    -- Get Response from API
    utl_http.set_body_charset('UTF-8');
    utl_http.set_header(lv_req, 'user-agent', 'mozilla/4.0');
    utl_http.set_header(lv_req, 'content-type', 'application/json'); 
--    utl_http.set_header(lv_req, 'Content-Length', length(lv_content));   
    utl_http.set_header(lv_req, 'Content-Length', lengthb(lv_content));   
    IF lv_username IS NOT NULL THEN
      utl_http.set_authentication(lv_req, lv_username, lv_password);
    END IF;
--  Log the URL, Wallet and Username Detail
    dbms_output.put_line('      Wallet:   ' || lv_ssl_wallet || '
      Username: ' || lv_username || '
      Password: ' || lv_password);

--    utl_http.write_text(lv_req, lv_content);    
    utl_http.write_raw(lv_req, UTL_RAW.CAST_TO_RAW(lv_content));    
    lv_res := utl_http.get_response(lv_req);

--  Log the Content sent to HTTP call as well as the response
    dbms_output.put_line('      Content: ' || lv_content);
    dbms_output.put_line('
      Response Headers:');
    FOR i IN 1 .. utl_http.get_header_count(lv_res) LOOP
      utl_http.get_header(lv_res, i, lv_header_name, lv_header_value);
      dbms_output.put_line('        ' || i || ': ' || lv_header_name || ': ' || lv_header_value);
    END LOOP;
    dbms_output.put_line('
      Response Lines:');
    BEGIN
      LOOP
        utl_http.read_line(lv_res, lv_response);
        dbms_output.put_line('           ' || lv_response);
        IF     UPPER(lv_response) like '%ERROR%' THEN
          IF lv_err IS NULL THEN
            logger.append_param(l_params, 'Content', lv_content);
          END IF;
          logger.append_param(l_params, 'Response', lv_response);
          lv_err := 'Y';
        END IF;
        IF     lv_response like '%title%' THEN
          logger.append_param(l_params, 'Response', lv_response);
        END IF;
      END LOOP;
      utl_http.end_response(lv_res);
    EXCEPTION    
        WHEN utl_http.end_of_body THEN utl_http.end_response(lv_res);
    END;
    IF lv_err = 'Y' THEN
      lv_processed_failed          := lv_processed_failed + 1;
    END IF;
  END LOOP;
   commissions_pkg.write_to_file(g_log_file_name,'Export Brokerage Information to OHI: ');
  IF l_params.LAST > 0 THEN
   
    commissions_pkg.write_to_file(g_log_file_name,'Processed Count                    : '||lv_processed_cnt);
    commissions_pkg.write_to_file(g_log_file_name,'Failed Count                       : '||lv_processed_failed);
   /* logger.log_error('DNLD_OHI_POLICIES_PKG.EXPORT_COMPANY_TO_OHI: ' || 
      lv_processed_failed || ' of ' || lv_processed_cnt || 
      ' OHI Policies HTTP calls failed', l_scope, null, l_params);*/
    p_return_msg                 := 'ERROR:   ' ||
      lv_processed_cnt || ' OHI Policies HTTP calls processed and ' || 
      lv_processed_failed || ' failed';
  ELSE
    p_return_msg                 := 'SUCCESS: ' ||
      lv_processed_cnt || ' OHI Policies HTTP calls processed';
      commissions_pkg.write_to_file(g_log_file_name,'Processed Count - SUCCESS       : '||lv_processed_cnt);
  END IF;
 
EXCEPTION
  WHEN OTHERS THEN
    commissions_pkg.write_to_file(g_log_file_name,'Unexpected Error                   : '||SQLERRM);
    logger.log_error('DNLD_OHI_POLICIES_PKG.EXPORT_COMPANY_TO_OHI: Unhandled Exception', l_scope, null, l_params);
   -- dbms_output.put_line(' - Unhandled Exception Error: ' || sqlerrm);
    p_return_msg                 := 'ERROR:   ' || sqlerrm;
END export_company_to_ohi;

/**********************************************************************************************************************/

PROCEDURE bulk_broker_load

IS

  lv_return_msg         VARCHAR2(500);
  l_session_id          VARCHAR2(200);
  l_slave_id            NUMBER;
  
BEGIN 
 select sys_context('userenv','sid') INTO l_session_id from dual;
 select userenv('PID') into l_slave_id FROM DUAL;

 
 g_logger_identifier := get_scheduler_job_id(l_session_id,l_slave_id);
 dbms_output.put_line('the log number is '||g_logger_identifier);

 g_log_file_name    := g_logger_identifier||'.html';
 g_output_file_name := g_logger_identifier||'.csv';
 

  DNLD_OHI_POLICIES_PKG.export_company_to_ohi(NULL, lv_return_msg);
  
EXCEPTION
  WHEN OTHERS THEN
      commissions_pkg.write_to_file(g_log_file_name,'Unexpected Error '||SQLERRM);
END bulk_broker_load;

/**********************************************************************************************************************/

PROCEDURE broker_load                  (p_commit  IN  BOOLEAN DEFAULT FALSE)

IS

  gc_scope_prefix       CONSTANT VARCHAR2(31)           
                                 := lower($$PLSQL_UNIT) || '.';
  l_scope                        logger_logs.scope%TYPE 
                                 := 'CommissionsSelfBuild: ' || gc_scope_prefix;
  l_params                       logger.tab_param;

  lv_return_msg                  VARCHAR2(500);
  lv_sequence                    dnld_company.batch_no%TYPE;

  CURSOR   c_get_dnld_companies IS
    SELECT max(ROWID) AS row_id
          ,company_id_no
      FROM dnld_company
     WHERE batch_no = lv_sequence
       AND interf_system_id_no = 2
     GROUP BY company_id_no;

BEGIN 
  -- Setting the logger values in case of errors
  logger.append_param(l_params, 'RunDate', to_char(SYSDATE , 'yyyy-Mon-dd hh24:mi:ss'));
  lv_sequence := NULL;

  -- Find out if there is something to do
  BEGIN
    SELECT batch_no
      INTO lv_sequence
      FROM dnld_company
     WHERE batch_no = 0
       AND interf_system_id_no = 2
       AND ROWNUM = 1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END;
  IF lv_sequence = 0 THEN
    lv_sequence := dnld_batch_no_seq.NEXTVAL();
    UPDATE dnld_company
       SET batch_no = lv_sequence
     WHERE batch_no = 0
       AND interf_system_id_no = 2;
    FOR x IN c_get_dnld_companies LOOP
      BEGIN
        dnld_ohi_policies_pkg.export_company_to_ohi(x.company_id_no, lv_return_msg);
        --dbms_output.put_line('Company: ' || x.company_id_no || ', ' || x.row_id ||
        --  ' Return Message: ' || lv_return_msg);
        IF lv_return_msg like 'ERROR%' THEN
          raise_application_error(-20000,'An Error Needs to be Investigated and rerun');
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          UPDATE dnld_company
             SET batch_no = 0
           WHERE ROWID = x.row_id;
      END;
    END LOOP;
    IF p_commit
      THEN
        COMMIT;
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    logger.log_error('DNLD_OHI_POLICIES_PKG.BROKER_LOAD: Unhandled Error', l_scope, null, l_params);
    dbms_output.put_line(' - Unhandled Exception Error: ' || sqlerrm);
    ROLLBACK;
END broker_load;

/**********************************************************************************************************************/

END DNLD_OHI_POLICIES_PKG;

/
