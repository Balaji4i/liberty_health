CREATE OR REPLACE PACKAGE "LHHCOM"."DNLD_OHI_POLICIES_PKG" 

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
*
* </pre>         */

PROCEDURE bulk_broker_load;
PROCEDURE broker_load                  (p_commit  IN  BOOLEAN DEFAULT FALSE);
PROCEDURE export_company_to_ohi        (p_id             IN  NUMBER
                                       ,p_return_msg     OUT VARCHAR2);

END DNLD_OHI_POLICIES_PKG;
/

-- * Example of Procedures executed in an anonymous block
-- * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/*
DECLARE
  lv_return_msg         VARCHAR2(500);
BEGIN
--  DNLD_OHI_POLICIES_PKG.export_company_to_ohi(NULL, lv_return_msg);
--  dbms_output.put_line('  Message    : ' || lv_return_msg);
  DNLD_OHI_POLICIES_PKG.export_company_to_ohi(10000061, lv_return_msg);
  dbms_output.put_line('  Message    : ' || lv_return_msg);
END;
-- */

CREATE OR REPLACE PACKAGE BODY DNLD_OHI_POLICIES_PKG

  AS

/**
  * Contains various OHI Procedures used in the Commissions System
  * */
  
/**********************************************************************************************************************/

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
  lv_action                      VARCHAR2(6);
  lv_url_inp                     VARCHAR(400);
  lv_url                         VARCHAR(400);
  lv_name                        VARCHAR2(30);
  lv_content                     VARCHAR2(4000);
  lv_country_string              VARCHAR2(4000);
  lv_country                     VARCHAR2(4000);
  lv_req                         utl_http.req;
  lv_res                         utl_http.resp;
  lv_response                    VARCHAR2(4000);
  lv_processed_cnt               NUMBER(5);
  lv_processed_failed            NUMBER(5);
  
  CURSOR   c_get_companies IS
    SELECT company_id_no
          ,company_name
          ,effective_start_date
          ,effective_end_date
      FROM company
     WHERE company_id_no = NVL(p_id, company_id_no);
  CURSOR   c_get_countries IS
    SELECT country_code,
           effective_start_date,
           effective_end_date
      FROM company_country
     WHERE company_id_no = lv_company_id;

BEGIN 
  -- Initialize values
  p_return_msg                 := NULL;
  lv_url_inp                   := NULL;
  lv_url                       := NULL;
  lv_processed_cnt             := 0;
  lv_processed_failed          := 0;

  -- Get OHI Policies API server link
-- Existing Dev link
--  SELECT 'http://wlsohidevlz1:7211/api/generic/agents'
-- SSL Test Link
--  SELECT 'https://wlsohidevlz1:7711/api/generic/agents'
  SELECT get_system_parameter('LB_HEALTH_COMMS','OHI','SERVER_LINK') 
    INTO lv_url_inp 
    FROM dual;
  IF lv_url_inp IS NOT NULL THEN
    lv_url := SUBSTR(lv_url_inp, 1, LENGTH(lv_url_inp) - 6);
  END IF;

  -- Start with the Company Details
  FOR c IN c_get_companies LOOP

    -- Initialize values
    lv_company_id                := c.company_id_no;
    lv_broker_id                 := NULL;
    lv_action                    := NULL;
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
      lv_action := 'UPDATE';
      lv_req    := utl_http.begin_request(lv_url || 'brokers' || '/' || lv_broker_id, 'PUT', 'HTTP/1.1');
      --How to delete a Company record from OHI
      --lv_req    := utl_http.begin_request(lv_url || 'brokers' || '/' || lv_broker_id, 'DELETE', 'HTTP/1.1');
    ELSE
      lv_action := 'INSERT';
      lv_req    := utl_http.begin_request(lv_url || 'brokers', 'POST', 'HTTP/1.1');
    END IF;
    --dbms_output.put_line(lv_action || ' action for Broker ' || lv_company_id || ' (' || lv_broker_id || ')');

    -- Populate Country String
    FOR x IN c_get_countries LOOP
      lv_country_string := lv_country_string                             || ',
        {"value": "'     || x.country_code                               || '",
         "NAME": "'      || lv_name                                      || '",
         "startDate": "' || to_char(x.effective_start_date,'YYYY-MM-DD') || '",
         "endDate": "'   || to_char(x.effective_end_date,'YYYY-MM-DD')   || '"}'; 
    END LOOP;
    lv_country := SUBSTR(lv_country_string, 2);

    -- Build Request Content
    lv_content := ' 
     {"Broker id": "' || lv_broker_id                                  || '", 
      "code": "'      || lv_company_id                                 || '", 
      "name": "'      || c.company_name                                || '",
      "STARTDATE": "' || to_char(c.effective_start_date, 'YYYY-MM-DD') || '",
      "ENDDATE": "'   || to_char(c.effective_end_date, 'YYYY-MM-DD')   || '",
      "COUNTRY": [ '  || lv_country                                    || ']}';
    
    -- Get Response from API
    utl_http.set_header(lv_req, 'user-agent', 'mozilla/4.0');
    utl_http.set_header(lv_req, 'content-type', 'application/json'); 
    utl_http.set_header(lv_req, 'Content-Length', length(lv_content));   
    utl_http.write_text(lv_req, lv_content);    
    lv_res := utl_http.get_response(lv_req);
--  Log the Content sent to HTTP call
--    dbms_output.put_line('Content: ' || lv_content);

    -- Process the response from the HTTP call
    BEGIN
      LOOP
        utl_http.read_line(lv_res, lv_response);
--      Log the detailed response
--        dbms_output.put_line('Response: ' || lv_response);
        IF     lv_response like '%error%' THEN
          IF lv_err IS NULL THEN
            logger.append_param(l_params, 'Content:', lv_content);
          END IF;
          logger.append_param(l_params, 'Response:', lv_response);
          lv_err := 'Y';
        END IF;
        IF     lv_response like '%title%' THEN
          logger.append_param(l_params, 'Response:', lv_response);
          p_return_msg := 'ERROR: ' || lv_response;
--        Log only error lines from response
--          dbms_output.put_line('Response: ' || lv_response);
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
  IF l_params.LAST > 0 THEN
    logger.log_error('DNLD_OHI_POLICIES_PKG.EXPORT_COMPANY_TO_OHI: ' || 
      lv_processed_failed || ' of ' || lv_processed_cnt || 
      ' OHI Policies HTTP calls failed', l_scope, null, l_params);
    p_return_msg                 := 'ERROR:   ' ||
      lv_processed_cnt || ' OHI Policies HTTP calls processed and ' || 
      lv_processed_failed || ' failed';
  ELSE
    p_return_msg                 := 'SUCCESS: ' ||
      lv_processed_cnt || ' OHI Policies HTTP calls processed';
  END IF;
 
EXCEPTION
  WHEN OTHERS THEN
    logger.log_error('Unhandled Exception', l_scope, null, l_params);
    dbms_output.put_line(' - Unhandled Exception Error: ' || sqlerrm);
END export_company_to_ohi;

/**********************************************************************************************************************/

PROCEDURE bulk_broker_load

IS

  lv_return_msg         VARCHAR2(500);

BEGIN 
  DNLD_OHI_POLICIES_PKG.export_company_to_ohi(NULL, lv_return_msg);
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
  SELECT batch_no
    INTO lv_sequence
    FROM dnld_company
   WHERE batch_no = 0
     AND interf_system_id_no = 2
     AND ROWNUM = 1;
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