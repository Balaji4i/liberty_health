CREATE OR REPLACE PROCEDURE "LHHCOM"."REFRESH_PAY_COMMS" (p_debug VARCHAR2 DEFAULT 'N')

AS

/**
* <pre>
* ----------------------------------------------------------------------
* Project:     : Commission Self Build
*
*                Description  : Procedures used to Refresh Commisionable Flags from OHI Policies
*                File Name    : Liberty\plsql\procedures\lhhcom\refresh_pay_comms.sql
*                Author       : Sarel Eybers
*                Requirements : Access to account SCHEMA
*                Call Syntax  : Anonymous Block Example below in Ad Hoc code below
*
*                Amendments   :
*                Date        User     Change Description
*                ========    ======== =================================================
*                2018/12/12  Sarel    Create Procedure
*                2019/01/12  Sarel    Change to New Spec
*
* </pre>         */

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
  lv_output                      CLOB;
  lv_processed_cnt               NUMBER(5);
  lv_processed_failed            NUMBER(5);
  lv_header_name                 VARCHAR2(256);
  lv_header_value                VARCHAR2(256);
  CURSOR c_pay_comms IS
    SELECT 
           j.data.id               id
          ,j.data.uuid             uuid
          ,j.data.CODE.code        premium_code
          ,j.data.COUNTRY.code     country_code
          ,to_date(j.data.startDate, 'YYYY-MM-DD')
                                   effective_start_date
          ,to_date(j.data.endDate, 'YYYY-MM-DD')
                                   effective_end_date
          ,j.data.COMCALC.code     calculate_comms
          ,j.data.links.href       rest_link
          ,j.data.lastUpdatedBy    last_updated_by
          ,to_timestamp_tz(regexp_replace(j.data.lastUpdatedDate.value, 'T', ' '), 'YYYY-MM-DD HH24:MI:SS.FFTZH:TZM')
                                   last_updated_datetime
      FROM globaltemp_json_workspace j
     WHERE interface = 'commissionsht'
     ORDER BY 3, 4, 5, 7;

BEGIN 
  -- Initialize values
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
  IF p_debug = 'Y' THEN
    dbms_output.put_line('      URL:      ' || lv_url || '
      Wallet:   ' || lv_ssl_wallet || '
      Username: ' || lv_username || '
      Password: ' || lv_password);
  END IF;
  BEGIN
    -- Initialize values for REST call
    lv_req                       := utl_http.begin_request(lv_url || 'referencesheetlines/commissionsht/', 'GET', 'HTTP/1.1');
    lv_content                   := '';
    lv_output                    := '';
    -- Get Response from API
    utl_http.set_header(lv_req, 'user-agent', 'mozilla/4.0');
    utl_http.set_header(lv_req, 'content-type', 'application/json'); 
    utl_http.set_header(lv_req, 'Content-Length', length(lv_content));   
    IF lv_username IS NOT NULL THEN
      utl_http.set_authentication(lv_req, lv_username, lv_password);
    END IF;
    utl_http.write_text(lv_req, lv_content);    
    lv_res := utl_http.get_response(lv_req);
    IF p_debug = 'Y' THEN
      -- Log the Content sent to HTTP call as well as the response
      dbms_output.put_line('Response Headers:');
    END IF;
    FOR i IN 1 .. utl_http.get_header_count(lv_res) LOOP
      utl_http.get_header(lv_res, i, lv_header_name, lv_header_value);
      IF p_debug = 'Y' THEN
        dbms_output.put_line(substr('   ' || i || ': ', -5) || lv_header_name || ': ' || lv_header_value);
      END IF;
    END LOOP;
    IF p_debug = 'Y' THEN
      dbms_output.put_line('Response Lines:');
    END IF;
    BEGIN
      LOOP
        utl_http.read_line(lv_res, lv_response);
        IF substr(lv_response, 1, 8) = '   "item' THEN
          lv_output := '{
';
        ELSIF substr(lv_response, 1, 7) IN ('   }, {', '   } ],') THEN
          lv_output := lv_output || '}';
          IF p_debug = 'Y' THEN
            dbms_output.put_line(lv_output);
          END IF;
          INSERT INTO globaltemp_json_workspace (interface, data) VALUES ('commissionsht', lv_output);
          lv_output := '{
';
          IF p_debug = 'Y' THEN
            dbms_output.put_line('  * * * *');
            dbms_output.put_line('  * * * * "INSERT INTO globaltemp_json_workspace" Success!!');
            dbms_output.put_line('  * * * *');
          END IF;
        ELSIF substr(lv_response, 1, 6) = '      ' THEN
          lv_output := lv_output || lv_response;
        ELSE
          NULL;
        END IF;
      END LOOP;
      utl_http.end_response(lv_res);
    EXCEPTION    
      WHEN utl_http.end_of_body THEN utl_http.end_response(lv_res);
    END;
  END;
  IF p_debug = 'Y' THEN
    dbms_output.put_line('
    Records interfaced . . .');
    BEGIN
      FOR x IN c_pay_comms LOOP
        dbms_output.put_line('ID (' || x.id 
          || '), UUID (' || x.uuid 
          || '), Premium (' || x.premium_code 
          || '), Country (' || x.country_code 
          || '), Start (' || x.effective_start_date
          || '), End (' || x.effective_end_date
          || '), Calc? (' || x.calculate_comms
          || '), Link (' || x.rest_link
          || '), Updated by (' || x.last_updated_by
          || '), on (' || x.last_updated_datetime
          || ')');
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('Unhandled Exception Error when reading GLOBALTEMP_JSON_WORKSPACE records: ' || sqlerrm);
    END;
  END IF;
 
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line(' - Unhandled Exception Error: ' || sqlerrm);

END REFRESH_PAY_COMMS;

/* Ad Hoc Code

-- Run to populate globaltemp_pay_comms
DECLARE
BEGIN
  lhhcom.refresh_pay_comms;
END;
SELECT * FROM globaltemp_pay_comms;
SELECT * FROM globaltemp_json_workspace;

-- Run to Debug
SET SERVEROUTPUT ON;
DECLARE
BEGIN
  lhhcom.refresh_pay_comms('Y');
END;

*/