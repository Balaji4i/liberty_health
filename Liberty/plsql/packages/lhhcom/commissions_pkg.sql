set define off;
/
--------------------------------------------------------
--  File created - Tuesday-November-20-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package COMMISSIONS_PKG
--------------------------------------------------------

CREATE OR REPLACE EDITIONABLE PACKAGE "LHHCOM"."COMMISSIONS_PKG" 
AS

/**
* <pre>
* ----------------------------------------------------------------------
* Project:     : Commission Self Build
*
*                Description  : General Procedures used for Commissions
*                File Name    : Liberty\plsql\packages\lhhcom\commissions_pkg.sql
*                Author       : Sarel Eybers
*                Requirements : Access to account SCHEMA
*                Call Syntax  : Anonymous Block Example below the package header
*
*                Amendments   :
*                Date        User    version   Change Description
*                ========    ======== =====     =================================================
*                2017/09/14  Sarel               Change the Comm Perc pick-up
*                2017/10/26  Sarel               Add get_hold_ind Procedure
*                2017/12/20  Sarel               Add get_poep_id Procedure
*                2018/01/10  Sarel               Add hourly_job Procedure
*                2018/05/29  Sarel               Add Errors for No POBR and No Company
*                2018/05/29  Sarel               Add Recalc to HalfHourly_Job and some housekeeping
*                2019/03/07  T.Percy     1.0     OP-121, OP-352, NIG-469 Changes to the Integration process Add new procedures to process fusion premiums
*                2020/09/14  Sarel       1.1     Cater for Orbit pgrade changes in 19.1, 19.2, 19.3, 20.1 and 20.2 (pol_assigned_adjustments_v)
* </pre>         */

PROCEDURE hourly_job;
PROCEDURE halfhourly_job;

PROCEDURE get_percentage       (p_date           IN  DATE     DEFAULT SYSDATE
                               ,p_company        IN  NUMBER   DEFAULT NULL
                               ,p_broker         IN  NUMBER   DEFAULT NULL
                               ,p_group          IN  VARCHAR2 DEFAULT NULL
                               ,p_product        IN  VARCHAR2 DEFAULT NULL
                               ,p_policy         IN  VARCHAR2 DEFAULT NULL
                               ,p_person         IN  VARCHAR2 DEFAULT NULL
                               ,p_poep           IN  VARCHAR2 DEFAULT NULL
                               ,p_percentage     OUT ohi_comm_perc.comm_perc%type
                               ,p_description    OUT ohi_comm_perc.comm_desc%type
                               ,p_return_msg     OUT VARCHAR2);

PROCEDURE get_hold_ind         (p_date           IN  DATE     DEFAULT SYSDATE
                               ,p_company        IN  NUMBER   DEFAULT NULL
                               ,p_broker         IN  NUMBER   DEFAULT NULL
                               ,p_group          IN  VARCHAR2 DEFAULT NULL
                               ,p_product        IN  VARCHAR2 DEFAULT NULL
                               ,p_policy         IN  VARCHAR2 DEFAULT NULL
                               ,p_person         IN  VARCHAR2 DEFAULT NULL
                               ,p_poep           IN  VARCHAR2 DEFAULT NULL
                               ,p_hold_ind       OUT ohi_hold_ind.hold_ind%type
                               ,p_hold_reason    OUT ohi_hold_ind.hold_reason%type
                               ,p_return_msg     OUT VARCHAR2);

PROCEDURE get_poep_id          (p_date           IN  DATE     DEFAULT SYSDATE
                               ,p_product        IN  VARCHAR2 DEFAULT NULL
                               ,p_policy         IN  VARCHAR2 DEFAULT NULL
                               ,p_person         IN  VARCHAR2 DEFAULT NULL
                               ,p_poep           OUT ohi_enrollment_products.poep_id%type
                               ,p_return_msg     OUT VARCHAR2);

PROCEDURE get_comp_template    (p_company        IN  NUMBER   DEFAULT NULL
                               ,p_date           IN  DATE     DEFAULT SYSDATE
                               ,p_template       OUT VARCHAR2
                               ,p_return_msg     OUT VARCHAR2);


PROCEDURE create_job           (
                                p_job_name    IN VARCHAR2 
                               ,p_job_type    IN VARCHAR2
                               ,p_job_action  IN VARCHAR2
                               ,p_start_date  IN DATE
                               ,p_no_arguments IN NUMBER
                               ,p_comments    IN VARCHAR2
                               );                               

PROCEDURE add_job_arguments   (
                                p_job_name            IN VARCHAR2 
                               ,p_argument_position   IN NUMBER
                               ,p_argument_char       IN VARCHAR2 DEFAULT NULL
                               ,p_argument_num        IN NUMBER DEFAULT NULL
                               ,p_argument_date       IN DATE   DEFAULT NULL
                              );

PROCEDURE add_job_arguments_name(
                                  p_job_name            IN VARCHAR2 
                                 ,p_argument_name       IN VARCHAR2
                                 ,p_argument_char       IN VARCHAR2 DEFAULT NULL
                                 ,p_argument_num        IN NUMBER DEFAULT NULL
                                 ,p_argument_date       IN DATE   DEFAULT NULL
                               );

PROCEDURE enable_job          (
                                p_job_name IN VARCHAR2
                              );                              


PROCEDURE drop_job            (
                                p_job_name IN VARCHAR2
                              );

PROCEDURE run_job            (
                                p_job_name IN VARCHAR2
                             );           

PROCEDURE write_to_file      (  
                                p_file_name IN VARCHAR2,
                                p_message   IN VARCHAR2
                              ); 

PROCEDURE create_file        (  
                                p_file_name     IN VARCHAR2,
                                p_process       IN VARCHAR2
                             );                               

PROCEDURE get_file           (
                                p_file_name IN VARCHAR2, 
                                p_output OUT BLOB
                             );   

/* 1.0 start */                             
PROCEDURE process_fusion_premiums;


PROCEDURE clear_processed_entries;

PROCEDURE invoke_rest_service(
                               p_bu IN VARCHAR2 DEFAULT NULL
                             ); 

PROCEDURE get_fusion_billing_group
                              (
                              p_group_code IN VARCHAR2
                              );

PROCEDURE process_fusion_payments(
                                  p_company_id_no IN VARCHAR2 DEFAULT NULL,
                                  p_invoice_no    IN VARCHAR2 DEFAULT NULL,
                                  p_from_date     IN VARCHAR2 DEFAULT NULL,
                                  p_to_date       IN VARCHAR2 DEFAULT NULL
                                 ); 
                                 
                                 
PROCEDURE fetch_fusion_payables_int
                                 (
                                  p_from_date     IN VARCHAR2,
                                  p_to_date       IN VARCHAR2,
                                  p_log_file_name IN VARCHAR2 DEFAULT NULL
                                 ); 
                                 
PROCEDURE process_fusion_payables(p_log_file_name IN VARCHAR2 DEFAULT NULL);                                 

PROCEDURE fetch_fusion_payments_int(p_log_file_name IN VARCHAR2 DEFAULT NULL);

/* 1.0 end */ 
END COMMISSIONS_PKG;
/
create or replace PACKAGE BODY          "COMMISSIONS_PKG" 

  AS
  
/**
  * Contains various Procedures used in the Commissions System
  * 
*  Project:     : Commission Self Build
*
*                Description  : General Procedures used for Commissions
*                File Name    : Liberty\plsql\packages\lhhcom\commissions_pkg.sql
*                Author       : Sarel Eybers
*                Requirements : Access to account SCHEMA
*                Call Syntax  : Anonymous Block Example below the package header
*
*                Amendments   :
*                Date        User      Version    Change Description
*                ========    ========  ========   =================================================
*                05/11/2018  T.Percy    1.0       Adding generic functionality to submit jobs asynchronously.
*                05/03/2019  T.Percy    1.2       Redesign of integration from Fusion to Self-build for Premiums with reconcilation
 */                          

-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  g_scope             logger_logs.scope%TYPE;
  g_job_id            NUMBER;
  g_directory         VARCHAR2(100) DEFAULT 'LOGDATA';
  g_log_file_name     VARCHAR2(400);
  g_output_file_name  VARCHAR2(400);
  g_logger_identifier NUMBER;
  g_url               VARCHAR2(30000);
  g_endpoint          VARCHAR2(5000);
  g_job_start_date    DATE;

  dml_errors          EXCEPTION;
  E_EXCEPTION         EXCEPTION;
  PRAGMA exception_init(dml_errors, -24381);



PROCEDURE create_file(  
                      p_file_name     IN VARCHAR2,
                      p_process       IN VARCHAR2
                    )  
                    AS

    l_log_file   utl_file.file_type;

BEGIN
    dbms_output.put_line('creating the file '||p_file_name);
    l_log_file := utl_file.fopen('LOGDATA',p_file_name,'w');
    utl_file.put_line(l_log_file,p_process);
    utl_file.put_line(l_log_file,'======================================');
    utl_file.fclose(l_log_file);

EXCEPTION 
  WHEN OTHERS THEN
    dbms_output.put_line('error creating the file '||sqlerrm);
   utl_file.fclose(l_log_file);
END;

PROCEDURE write_to_file(  
                      p_file_name IN VARCHAR2,
                      p_message   IN VARCHAR2
                    ) IS

 l_log_file         utl_file.file_type;
 l_dnld_folder      VARCHAR2(200)   := get_system_parameter('LB_HEALTH_COMMS','FUSION','SERVER_DNLD_FOLDER');



begin

    l_log_file := utl_file.fopen('LOGDATA',p_file_name,'a');


    utl_file.put_line(l_log_file,p_message);


	utl_file.fclose(l_log_file);

exception
  when others then
     utl_file.fclose(l_log_file);
end;

PROCEDURE write_csv(p_file_name IN VARCHAR2, p_query IN VARCHAR2) IS --1.0


          l_theCursor         INTEGER DEFAULT dbms_sql.open_cursor;
          l_columnValue       VARCHAR2(4000);
          l_status            INTEGER;
          l_descTbl           dbms_sql.desc_tab;
          l_colCnt            NUMBER;
          n                   NUMBER := 0;
          f                   utl_file.file_type;
          l_line              VARCHAR2(32767);


    BEGIN


      --generate a csv file from the select statement
      f := utl_file.fopen(g_directory,p_file_name,'a');

      --commissions_pkg.write_to_file(  p_file_name,p_query);
      dbms_sql.parse(l_theCursor,  p_query, dbms_sql.native );


      dbms_sql.describe_columns( l_theCursor, l_colCnt, l_descTbl );

      for i in 1 .. l_colCnt loop
         dbms_sql.define_column(l_theCursor, i, l_columnValue, 4000);
         l_line := l_line ||  l_descTbl(i).col_name||',';
      end loop;

      utl_file.put_line(f,l_line);

      l_status := dbms_sql.execute(l_theCursor);

      while ( dbms_sql.fetch_rows(l_theCursor) > 0 ) loop
        l_line := null;
        for i in 1 .. l_colCnt loop
           dbms_sql.column_value( l_theCursor, i, l_columnValue );
           l_line := l_line || l_columnValue ||',';
        end loop;
        utl_file.put_line(f,l_line);
      end loop;

      utl_file.fclose(f);

    EXCEPTION 
      WHEN OTHERS THEN
         utl_file.fclose(f);
    END write_csv; -- end 1.0

/**********************************************************************************************************************/

PROCEDURE hourly_job

IS

  gc_scope_prefix       CONSTANT VARCHAR2(31)           
                                 := lower($$PLSQL_UNIT) || '.';
  l_scope                        logger_logs.scope%TYPE 
                                 := 'Commissions: ' || gc_scope_prefix;
  l_params                       logger.tab_param;
  lv_return_msg         varchar2(500);

BEGIN
  -- Setting the logger values in case of errors
  g_job_id           := lhhcom.COMMS_JOB_ID_SEQ.nextval;
  logger.append_param(l_params, 'COMMISSIONS_PKG.HOURLY_JOB: ', 'RunDate ' 
                      || to_char(SYSDATE , 'yyyy-Mon-dd hh24:mi:ss'));
  logger.log_information('COMMISSIONS_PKG.HOURLY_JOB started');

  BEGIN -- Run COMMS_CALC_PKG.PROOF_OF_PAYMENT_UPDATE_RUN(user, lv_return_msg);
    dbms_session.set_identifier('PROOF_OF_PAYMENT_UPDATE_RUN' || g_job_id);
    logger.set_level('DEBUG',sys_context('userenv','client_identifier'));
    logger.log_information('COMMISSIONS_PKG.HOURLY_JOB - COMMS_CALC_PKG.PROOF_OF_PAYMENT_UPDATE_RUN(user, lv_return_msg)');
    comms_calc_pkg.proof_of_payment_update_run(USER, lv_return_msg);
    IF TRIM(lv_return_msg) IS NOT NULL THEN
      RAISE_APPLICATION_ERROR(-20020,'Recalc Error');
	  END IF;
    logger.unset_client_level(p_client_id => 'PROOF_OF_PAYMENT_UPDATE_RUN' || g_job_id);
  EXCEPTION
    WHEN OTHERS THEN
      logger.log_error('Unhandled Exception Error in COMMS_CALC_PKG.PROOF_OF_PAYMENT_UPDATE_RUN
        ' || lv_return_msg, l_scope, null, l_params);
      logger.unset_client_level(p_client_id => 'PROOF_OF_PAYMENT_UPDATE_RUN' || g_job_id);
  END;

  dbms_session.set_identifier('COMMISSIONS_PKG.HOURLY_JOB' || g_job_id);
  logger.log_information('COMMISSIONS_PKG.HOURLY_JOB ended');

EXCEPTION
  WHEN OTHERS THEN
    logger.log_error('Unhandled Exception Error in COMMISSIONS_PKG.HOURLY_JOB', l_scope, null, l_params);

END hourly_job;

/**********************************************************************************************************************/

PROCEDURE halfhourly_job

IS

  gc_scope_prefix       CONSTANT VARCHAR2(31)           
                                 := lower($$PLSQL_UNIT) || '.';
  l_scope                        logger_logs.scope%TYPE 
                                 := 'Commissions: ' || gc_scope_prefix;
  l_params                       logger.tab_param;
  lv_return_msg         varchar2(500);
  e_exception           exception;

BEGIN
  -- Setting the logger values in case of errors
  g_job_id           := lhhcom.COMMS_JOB_ID_SEQ.nextval;
  logger.append_param(l_params, 'COMMISSIONS_PKG.HALFHOURLY_JOB: ', 'RunDate ' 
                      || to_char(SYSDATE , 'yyyy-Mon-dd hh24:mi:ss'));
  logger.log_information('COMMISSIONS_PKG.HALFHOURLY_JOB started');

  BEGIN -- Run OHI_POLICIES_LOAD_PKG.POPULATE_ALL(true)
    dbms_session.set_identifier('OHI_POLICIES_LOAD_PKG.POPULATE_ALL' || g_job_id);
    logger.set_level('DEBUG',sys_context('userenv','client_identifier'));
    logger.log_information('COMMISSIONS_PKG.HALFHOURLY_JOB - OHI_POLICIES_LOAD_PKG.POPULATE_ALL(true)');
    ohi_policies_load_pkg.populate_all(TRUE);
    logger.unset_client_level(p_client_id => 'OHI_POLICIES_LOAD_PKG.POPULATE_ALL' || g_job_id);
  EXCEPTION
    WHEN OTHERS THEN
      logger.log_error('Unhandled Exception Error in OHI_POLICIES_LOAD_PKG.POPULATE_ALL(true)', l_scope, null, l_params);
      logger.unset_client_level(p_client_id => 'OHI_POLICIES_LOAD_PKG.POPULATE_ALL' || g_job_id);
  END;

  BEGIN -- Run DNLD_OHI_POLICIES_PKG.BROKER_LOAD(true)
    dbms_session.set_identifier('DNLD_OHI_POLICIES_PKG.BROKER_LOAD' || g_job_id);
    logger.set_level('DEBUG',sys_context('userenv','client_identifier'));
    logger.log_information('COMMISSIONS_PKG.HALFHOURLY_JOB - DNLD_OHI_POLICIES_PKG.BROKER_LOAD');
    dnld_ohi_policies_pkg.broker_load(TRUE);
    logger.unset_client_level(p_client_id => 'DNLD_OHI_POLICIES_PKG.BROKER_LOAD' || g_job_id);
  EXCEPTION
    WHEN OTHERS THEN
      logger.log_error('Unhandled Exception Error in DNLD_OHI_POLICIES_PKG.BROKER_LOAD', l_scope, null, l_params);
      logger.unset_client_level(p_client_id => 'DNLD_OHI_POLICIES_PKG.BROKER_LOAD' || g_job_id);
  END;

  dbms_session.set_identifier('COMMISSIONS_PKG.HALFHOURLY_JOB' || g_job_id);
  logger.log_information('COMMISSIONS_PKG.HALFHOURLY_JOB ended');

EXCEPTION
  WHEN OTHERS THEN
    logger.log_error('Unhandled Exception Error in COMMISSIONS_PKG.HALFHOURLY_JOB', l_scope, null, l_params);

END halfhourly_job;

/**********************************************************************************************************************/

/* Backup of Jobs
PROCEDURE hourly_job

IS

  gc_scope_prefix       CONSTANT VARCHAR2(31)           
                                 := lower($$PLSQL_UNIT) || '.';
  l_scope                        logger_logs.scope%TYPE 
                                 := 'Commissions: ' || gc_scope_prefix;
  l_params                       logger.tab_param;
  lv_return_msg         varchar2(500);
  e_exception           exception;



BEGIN
  -- Setting the logger values in case of errors
  logger.set_level('DEBUG',sys_context('userenv','client_identifier'));
  logger.append_param(l_params, 'COMMISSIONS_PKG.HOURLY_JOB: ', 'RunDate ' 
                      || to_char(SYSDATE , 'yyyy-Mon-dd hh24:mi:ss'));
  logger.log_information('COMMISSIONS_PKG.HOURLY_JOB started');

  BEGIN -- Run COMMS_CALC_PKG.PROOF_OF_PAYMENT_UPDATE_RUN(user, lv_return_msg);
    logger.log_information('COMMISSIONS_PKG.HOURLY_JOB - COMMS_CALC_PKG.PROOF_OF_PAYMENT_UPDATE_RUN(user, lv_return_msg)');
    g_job_id           := lhhcom.COMMS_JOB_ID_SEQ.nextval;
    dbms_session.set_identifier('PROOF_OF_PAYMENT_UPDATE_RUN'||g_job_id);
    COMMS_CALC_PKG.PROOF_OF_PAYMENT_UPDATE_RUN(user, lv_return_msg);
  	IF lv_return_msg IS NOT NULL THEN
	    RAISE e_exception;
	  END IF;
  EXCEPTION
    WHEN e_exception THEN
	    logger.log_error('Exception in COMMS_CALC_PKG.PROOF_OF_PAYMENT_UPDATE_RUN reported: '||lv_return_msg, l_scope, null, l_params);
    WHEN OTHERS THEN
      logger.log_error('Unhandled Exception Error in COMMS_CALC_PKG.PROOF_OF_PAYMENT_UPDATE_RUN', l_scope, null, l_params);
  END;
  logger.unset_client_level(p_client_id => 'PROOF_OF_PAYMENT_UPDATE_RUN'||g_job_id);

  dbms_session.set_identifier('COMMISSIONS_PKG.HOURLY_JOB'||g_job_id);
  logger.log_information('COMMISSIONS_PKG.HOURLY_JOB ended');

EXCEPTION
  WHEN OTHERS THEN
    logger.log_error('Unhandled Exception Error in COMMISSIONS_PKG.HOURLY_JOB', l_scope, null, l_params);
    logger.unset_client_level(p_client_id => 'PROOF_OF_PAYMENT_UPDATE_RUN'||g_job_id);
END hourly_job;

PROCEDURE halfhourly_job

IS

  gc_scope_prefix       CONSTANT VARCHAR2(31)           
                                 := lower($$PLSQL_UNIT) || '.';
  l_scope                        logger_logs.scope%TYPE 
                                 := 'Commissions: ' || gc_scope_prefix;
  l_params                       logger.tab_param;
  lv_return_msg         varchar2(500);
  e_exception           exception;

BEGIN
  -- Setting the logger values in case of errors
  g_job_id           := lhhcom.COMMS_JOB_ID_SEQ.nextval;
  dbms_session.set_identifier('OHI_POLICIES_LOAD_PKG'||g_job_id);

  logger.set_level('DEBUG',sys_context('userenv','client_identifier'));
  logger.append_param(l_params, 'COMMISSIONS_PKG.HALFHOURLY_JOB: ', 'RunDate ' 
                      || to_char(SYSDATE , 'yyyy-Mon-dd hh24:mi:ss'));

  logger.log_information('COMMISSIONS_PKG.HALFHOURLY_JOB started');

  BEGIN -- Run OHI_POLICIES_LOAD_PKG.POPULATE_ALL(true)
    logger.log_information('COMMISSIONS_PKG.HALFHOURLY_JOB - OHI_POLICIES_LOAD_PKG.POPULATE_ALL(true)');
    ohi_policies_load_pkg.populate_all(TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      logger.log_error('Unhandled Exception Error in OHI_POLICIES_LOAD_PKG.POPULATE_ALL(true)', l_scope, null, l_params);
  END;

  BEGIN -- Run DNLD_OHI_POLICIES_PKG.BROKER_LOAD(true)
    logger.log_information('COMMISSIONS_PKG.HALFHOURLY_JOB - DNLD_OHI_POLICIES_PKG.BROKER_LOAD');
    dnld_ohi_policies_pkg.broker_load(TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      logger.log_error('Unhandled Exception Error in DNLD_OHI_POLICIES_PKG.BROKER_LOAD', l_scope, null, l_params);
  END;

  logger.log_information('COMMISSIONS_PKG.HALFHOURLY_JOB ended');
  logger.unset_client_level(p_client_id => 'OHI_POLICIES_LOAD_PKG'||g_job_id);
EXCEPTION
  WHEN OTHERS THEN
    logger.log_error('Unhandled Exception Error in COMMISSIONS_PKG.HALFHOURLY_JOB', l_scope, null, l_params);
    logger.unset_client_level(p_client_id => 'OHI_POLICIES_LOAD_PKG'||g_job_id);
END halfhourly_job;
*/

/**********************************************************************************************************************/

PROCEDURE get_percentage       (p_date           IN  DATE     DEFAULT SYSDATE
                               ,p_company        IN  NUMBER   DEFAULT NULL
                               ,p_broker         IN  NUMBER   DEFAULT NULL
                               ,p_group          IN  VARCHAR2 DEFAULT NULL
                               ,p_product        IN  VARCHAR2 DEFAULT NULL
                               ,p_policy         IN  VARCHAR2 DEFAULT NULL
                               ,p_person         IN  VARCHAR2 DEFAULT NULL
                               ,p_poep           IN  VARCHAR2 DEFAULT NULL
                               ,p_percentage     OUT ohi_comm_perc.comm_perc%type
                               ,p_description    OUT ohi_comm_perc.comm_desc%type
                               ,p_return_msg     OUT VARCHAR2)

IS

  gc_scope_prefix       CONSTANT VARCHAR2(31)           
                                 := lower($$PLSQL_UNIT) || '.';
  l_scope                        logger_logs.scope%TYPE 
                                 := 'Commissions: ' || gc_scope_prefix;
  l_params                       logger.tab_param;
  l_return_tmp                   VARCHAR2(100);

BEGIN
  p_percentage                 := NULL;
  p_description                := NULL;
  p_return_msg                 := NULL;

  -- Setting the logger values in case of errors
  logger.append_param(l_params, 'get_percentage:', 'Date ' || p_date
    || ' Company ' || p_company || ' Broker ' || p_broker || ' Group ' || p_group
    || ' Product ' || p_product || ' policy ' || p_policy || ' Person ' || p_person
    || ' POEP ' || p_poep);



  IF  -- Not NULL Parameters Check
         p_company IS NULL 
     AND p_broker  IS NULL
     AND p_group   IS NULL
     AND p_product IS NULL
     AND p_policy  IS NULL
     AND p_person  IS NULL
     AND p_poep    IS NULL THEN
    p_return_msg := 'ERROR: Cannot Retrieve a Commission Percentage when all paramaters are NULL.';
    RETURN;
  END IF; -- Not NULL Parameters Check

  IF  -- Populated POEP Id Check
         p_poep IS NOT NULL THEN
    BEGIN
      SELECT 
             CASE WHEN pobr.pobr_id        IS  NULL THEN NULL
                  WHEN comp.company_id_no  IS  NULL THEN NULL
                  WHEN poepcp.comm_perc IS NOT NULL THEN poepcp.comm_perc
                  WHEN insecp.comm_perc IS NOT NULL THEN insecp.comm_perc
                  WHEN policp.comm_perc IS NOT NULL THEN policp.comm_perc
                  WHEN grprcp.comm_perc IS NOT NULL THEN grprcp.comm_perc
                  WHEN graccp.comm_perc IS NOT NULL THEN graccp.comm_perc
                  WHEN brokcp.comm_perc IS NOT NULL THEN brokcp.comm_perc
                  WHEN compcp.comm_perc IS NOT NULL THEN compcp.comm_perc
                  ELSE NULL
             END
            ,CASE WHEN pobr.pobr_id        IS  NULL THEN NULL
                  WHEN comp.company_id_no  IS  NULL THEN NULL
                  WHEN poepcp.comm_perc IS NOT NULL THEN poepcp.comm_desc
                  WHEN insecp.comm_perc IS NOT NULL THEN insecp.comm_desc
                  WHEN policp.comm_perc IS NOT NULL THEN policp.comm_desc
                  WHEN grprcp.comm_perc IS NOT NULL THEN grprcp.comm_desc
                  WHEN graccp.comm_perc IS NOT NULL THEN graccp.comm_desc
                  WHEN brokcp.comm_perc IS NOT NULL THEN brokcp.comm_desc
                  WHEN compcp.comm_perc IS NOT NULL THEN compcp.comm_desc
                  ELSE NULL
             END
            ,CASE WHEN pobr.pobr_id        IS  NULL THEN 'No Policy - Broker Link found'
                  WHEN comp.company_id_no  IS  NULL THEN 'No Valid Company found'
                  WHEN poepcp.comm_perc IS NOT NULL THEN 'derived from POEP Id ' || poepcp.poep_id
                  WHEN insecp.comm_perc IS NOT NULL THEN 'derived from Person Code ' || insecp.inse_code
                  WHEN policp.comm_perc IS NOT NULL THEN 'derived from Policy Code ' || policp.policy_code
                  WHEN grprcp.comm_perc IS NOT NULL THEN 'derived from Group Code ' || grprcp.group_code || ', Product Code ' || grprcp.product_code
                  WHEN graccp.comm_perc IS NOT NULL THEN 'derived from Group Code ' || graccp.group_code
                  WHEN brokcp.comm_perc IS NOT NULL THEN 'derived from Broker ID ' || brokcp.broker_id_no
                  WHEN compcp.comm_perc IS NOT NULL THEN 'derived from Company ID ' || compcp.company_id_no
                  ELSE NULL
             END
        INTO p_percentage
            ,p_description
            ,l_return_tmp
        FROM 
             lhhcom.ohi_enrollment_products     poep
        LEFT OUTER 
        JOIN lhhcom.ohi_comm_perc               poepcp
          ON     poepcp.product_code  IS NULL
             AND poepcp.poep_id       = poep.poep_id
             AND poepcp.inse_code     IS NULL
             AND poepcp.policy_code   IS NULL
             AND poepcp.group_code    IS NULL
             AND poepcp.broker_id_no  IS NULL
             AND poepcp.company_id_no IS NULL
             AND poepcp.auth_username IS NOT NULL
             AND p_date               BETWEEN     poepcp.effective_start_date 
                                              AND poepcp.effective_end_date
        LEFT OUTER
        JOIN lhhcom.ohi_policy_enrollments      poen
          ON     poep.poen_id = poen.poen_id
        LEFT OUTER
        JOIN lhhcom.ohi_insured_entities        inse
          ON     poen.inse_id = inse.inse_id
        LEFT OUTER 
        JOIN lhhcom.ohi_comm_perc               insecp
          ON     insecp.product_code  IS NULL
             AND insecp.poep_id       IS NULL
             AND insecp.inse_code     = inse.inse_code
             AND insecp.policy_code   IS NULL
             AND insecp.group_code    IS NULL
             AND insecp.broker_id_no  IS NULL
             AND insecp.company_id_no IS NULL
             AND insecp.auth_username IS NOT NULL
             AND p_date               BETWEEN     insecp.effective_start_date 
                                              AND insecp.effective_end_date
        LEFT OUTER
        JOIN lhhcom.ohi_policies                poli
          ON     poen.poli_id = poli.poli_id
        LEFT OUTER 
        JOIN lhhcom.ohi_comm_perc               policp
          ON     policp.product_code  IS NULL
             AND policp.poep_id       IS NULL
             AND policp.inse_code     IS NULL
             AND policp.policy_code   = poli.policy_code
             AND policp.group_code    IS NULL
             AND policp.broker_id_no  IS NULL
             AND policp.company_id_no IS NULL
             AND policp.auth_username IS NOT NULL
             AND p_date               BETWEEN     policp.effective_start_date 
                                              AND policp.effective_end_date
        LEFT OUTER
        JOIN lhhcom.ohi_policy_groups           pogr
          ON     poli.poli_id = pogr.poli_id
             AND p_date               BETWEEN     pogr.effective_start_date 
                                              AND pogr.effective_end_date
        LEFT OUTER
        JOIN lhhcom.ohi_groups                  grac
          ON     pogr.grac_id = grac.grac_id
             AND p_date               BETWEEN     grac.effective_start_date 
                                              AND grac.effective_end_date
        LEFT OUTER
        JOIN lhhcom.ohi_products                enpr
          ON     poep.enpr_id = enpr.enpr_id
        LEFT OUTER 
        JOIN lhhcom.ohi_comm_perc               grprcp
          ON     grprcp.product_code  = enpr.product_code
             AND grprcp.poep_id       IS NULL
             AND grprcp.inse_code     IS NULL
             AND grprcp.policy_code   IS NULL
             AND grprcp.group_code    = grac.group_code
             AND grprcp.broker_id_no  IS NULL
             AND grprcp.company_id_no IS NULL
             AND grprcp.auth_username IS NOT NULL
             AND p_date               BETWEEN     grprcp.effective_start_date 
                                              AND grprcp.effective_end_date
        LEFT OUTER 
        JOIN lhhcom.ohi_comm_perc               graccp
          ON     graccp.product_code  IS NULL
             AND graccp.poep_id       IS NULL
             AND graccp.inse_code     IS NULL
             AND graccp.policy_code   IS NULL
             AND graccp.group_code    = grac.group_code
             AND graccp.broker_id_no  IS NULL
             AND graccp.company_id_no IS NULL
             AND graccp.auth_username IS NOT NULL
             AND p_date               BETWEEN     graccp.effective_start_date 
                                              AND graccp.effective_end_date
        LEFT OUTER
        JOIN lhhcom.ohi_policy_brokers          pobr
          ON     poli.poli_id = pobr.poli_id
             AND p_date               BETWEEN     pobr.effective_start_date 
                                              AND pobr.effective_end_date
        LEFT OUTER 
        JOIN lhhcom.broker                      brok
          ON     pobr.broker_id_no = brok.broker_id_no
        LEFT OUTER 
        JOIN lhhcom.ohi_comm_perc               brokcp
          ON     brokcp.product_code  IS NULL
             AND brokcp.poep_id       IS NULL
             AND brokcp.inse_code     IS NULL
             AND brokcp.policy_code   IS NULL
             AND brokcp.group_code    IS NULL
             AND brokcp.broker_id_no  = brok.broker_id_no
             AND brokcp.company_id_no IS NULL
             AND brokcp.auth_username IS NOT NULL
             AND p_date               BETWEEN     brokcp.effective_start_date 
                                              AND brokcp.effective_end_date
        LEFT OUTER 
        JOIN lhhcom.company                     comp
          ON     nvl(brok.company_id_no, pobr.company_id_no) = comp.company_id_no
        LEFT OUTER 
        JOIN lhhcom.ohi_comm_perc               compcp
          ON     compcp.product_code  IS NULL
             AND compcp.poep_id       IS NULL
             AND compcp.inse_code     IS NULL
             AND compcp.policy_code   IS NULL
             AND compcp.group_code    IS NULL
             AND compcp.broker_id_no  IS NULL
             AND compcp.company_id_no = comp.company_id_no
             AND compcp.auth_username IS NOT NULL
             AND p_date               BETWEEN     compcp.effective_start_date 
                                              AND compcp.effective_end_date
       WHERE poep.poep_id             = p_poep
         AND p_date BETWEEN           poep.effective_start_date 
                                  AND poep.effective_end_date;
      IF p_percentage IS NOT NULL THEN
        p_return_msg             := 'Success: Date ' || p_date || ', POEP ' || p_poep 
                                 || ' returned ' || p_percentage || '% '
                                 || l_return_tmp;
        RETURN;
      END IF;
      RAISE NO_DATA_FOUND;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN 
        p_return_msg             := 'Failure: Date ' || p_date || ', POEP ' || p_poep 
                                 || ' could not return any Commission Percentage';
        RETURN;
    END;
  END IF; -- Populated POEP Id Check

  IF  -- Populated Person Code Check
         p_person IS NOT NULL THEN
    BEGIN
      SELECT 
             CASE WHEN pobr.pobr_id        IS  NULL THEN NULL
                  WHEN comp.company_id_no  IS  NULL THEN NULL
                  WHEN insecp.comm_perc IS NOT NULL THEN insecp.comm_perc
                  WHEN policp.comm_perc IS NOT NULL THEN policp.comm_perc
                  WHEN grprcp.comm_perc IS NOT NULL THEN grprcp.comm_perc
                  WHEN graccp.comm_perc IS NOT NULL THEN graccp.comm_perc
                  WHEN brokcp.comm_perc IS NOT NULL THEN brokcp.comm_perc
                  WHEN compcp.comm_perc IS NOT NULL THEN compcp.comm_perc
                  ELSE NULL
             END
            ,CASE WHEN pobr.pobr_id        IS  NULL THEN NULL
                  WHEN comp.company_id_no  IS  NULL THEN NULL
                  WHEN insecp.comm_perc IS NOT NULL THEN insecp.comm_desc
                  WHEN policp.comm_perc IS NOT NULL THEN policp.comm_desc
                  WHEN grprcp.comm_perc IS NOT NULL THEN grprcp.comm_desc
                  WHEN graccp.comm_perc IS NOT NULL THEN graccp.comm_desc
                  WHEN brokcp.comm_perc IS NOT NULL THEN brokcp.comm_desc
                  WHEN compcp.comm_perc IS NOT NULL THEN compcp.comm_desc
                  ELSE NULL
             END
            ,CASE WHEN pobr.pobr_id        IS  NULL THEN 'No Policy - Broker Link found'
                  WHEN comp.company_id_no  IS  NULL THEN 'No Valid Company found'
                  WHEN insecp.comm_perc IS NOT NULL THEN 'derived from Person Code ' || insecp.inse_code
                  WHEN policp.comm_perc IS NOT NULL THEN 'derived from Policy Code ' || policp.policy_code
                  WHEN grprcp.comm_perc IS NOT NULL THEN 'derived from Group Code ' || grprcp.group_code || ', Product Code ' || grprcp.product_code
                  WHEN graccp.comm_perc IS NOT NULL THEN 'derived from Group Code ' || graccp.group_code
                  WHEN brokcp.comm_perc IS NOT NULL THEN 'derived from Broker ID ' || brokcp.broker_id_no
                  WHEN compcp.comm_perc IS NOT NULL THEN 'derived from Company ID ' || compcp.company_id_no
                  ELSE NULL
             END
        INTO p_percentage
            ,p_description
            ,l_return_tmp
        FROM 
             lhhcom.ohi_policy_enrollments      poen
        LEFT OUTER
        JOIN lhhcom.ohi_insured_entities        inse
          ON     poen.inse_id = inse.inse_id
        LEFT OUTER 
        JOIN lhhcom.ohi_comm_perc               insecp
          ON     insecp.product_code  IS NULL
             AND insecp.poep_id       IS NULL
             AND insecp.inse_code     = inse.inse_code
             AND insecp.policy_code   IS NULL
             AND insecp.group_code    IS NULL
             AND insecp.broker_id_no  IS NULL
             AND insecp.company_id_no IS NULL
             AND insecp.auth_username IS NOT NULL
             AND p_date               BETWEEN     insecp.effective_start_date 
                                              AND insecp.effective_end_date
        LEFT OUTER
        JOIN lhhcom.ohi_policies                poli
          ON     poen.poli_id = poli.poli_id
        LEFT OUTER 
        JOIN lhhcom.ohi_comm_perc               policp
          ON     policp.product_code  IS NULL
             AND policp.poep_id       IS NULL
             AND policp.inse_code     IS NULL
             AND policp.policy_code   = poli.policy_code
             AND policp.group_code    IS NULL
             AND policp.broker_id_no  IS NULL
             AND policp.company_id_no IS NULL
             AND policp.auth_username IS NOT NULL
             AND p_date               BETWEEN     policp.effective_start_date 
                                              AND policp.effective_end_date
        LEFT OUTER
        JOIN lhhcom.ohi_policy_groups           pogr
          ON     poli.poli_id = pogr.poli_id
             AND p_date               BETWEEN     pogr.effective_start_date 
                                              AND pogr.effective_end_date
        LEFT OUTER
        JOIN lhhcom.ohi_groups                  grac
          ON     pogr.grac_id = grac.grac_id
             AND p_date               BETWEEN     grac.effective_start_date 
                                              AND grac.effective_end_date
        LEFT OUTER 
        JOIN lhhcom.ohi_comm_perc               grprcp
          ON     grprcp.product_code  = p_product
             AND grprcp.poep_id       IS NULL
             AND grprcp.inse_code     IS NULL
             AND grprcp.policy_code   IS NULL
             AND grprcp.group_code    = grac.group_code
             AND grprcp.broker_id_no  IS NULL
             AND grprcp.company_id_no IS NULL
             AND grprcp.auth_username IS NOT NULL
             AND p_date               BETWEEN     grprcp.effective_start_date 
                                              AND grprcp.effective_end_date
        LEFT OUTER 
        JOIN lhhcom.ohi_comm_perc               graccp
          ON     graccp.product_code  IS NULL
             AND graccp.poep_id       IS NULL
             AND graccp.inse_code     IS NULL
             AND graccp.policy_code   IS NULL
             AND graccp.group_code    = grac.group_code
             AND graccp.broker_id_no  IS NULL
             AND graccp.company_id_no IS NULL
             AND graccp.auth_username IS NOT NULL
             AND p_date               BETWEEN     graccp.effective_start_date 
                                              AND graccp.effective_end_date
        LEFT OUTER
        JOIN lhhcom.ohi_policy_brokers          pobr
          ON     poli.poli_id = pobr.poli_id
             AND p_date               BETWEEN     pobr.effective_start_date 
                                              AND pobr.effective_end_date
        LEFT OUTER 
        JOIN lhhcom.broker                      brok
          ON     pobr.broker_id_no = brok.broker_id_no
        LEFT OUTER 
        JOIN lhhcom.ohi_comm_perc               brokcp
          ON     brokcp.product_code  IS NULL
             AND brokcp.poep_id       IS NULL
             AND brokcp.inse_code     IS NULL
             AND brokcp.policy_code   IS NULL
             AND brokcp.group_code    IS NULL
             AND brokcp.broker_id_no  = brok.broker_id_no
             AND brokcp.company_id_no IS NULL
             AND brokcp.auth_username IS NOT NULL
             AND p_date               BETWEEN     brokcp.effective_start_date 
                                              AND brokcp.effective_end_date
        LEFT OUTER 
        JOIN lhhcom.company                     comp
          ON     nvl(brok.company_id_no, pobr.company_id_no) = comp.company_id_no
        LEFT OUTER 
        JOIN lhhcom.ohi_comm_perc               compcp
          ON     compcp.product_code  IS NULL
             AND compcp.poep_id       IS NULL
             AND compcp.inse_code     IS NULL
             AND compcp.policy_code   IS NULL
             AND compcp.group_code    IS NULL
             AND compcp.broker_id_no  IS NULL
             AND compcp.company_id_no = comp.company_id_no
             AND compcp.auth_username IS NOT NULL
             AND p_date               BETWEEN     compcp.effective_start_date 
                                              AND compcp.effective_end_date
       WHERE inse.inse_code = p_person;
      IF p_percentage IS NOT NULL THEN
        p_return_msg             := 'Success: Date ' || p_date || ', Person ' || p_person 
                                 || ' returned ' || p_percentage || '% '
                                 || l_return_tmp;
        RETURN;
      END IF;
      RAISE NO_DATA_FOUND;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN 
        p_return_msg             := 'Failure: Date ' || p_date || ', Person ' || p_person
                                 || ' could not return any Commission Percentage';
        RETURN;
    END;
  END IF; -- Populated Person Code Check

  IF  -- Populated Policy Code Check
         p_policy IS NOT NULL THEN
    BEGIN
      SELECT 
             CASE WHEN pobr.pobr_id        IS  NULL THEN NULL
                  WHEN comp.company_id_no  IS  NULL THEN NULL
                  WHEN policp.comm_perc IS NOT NULL THEN policp.comm_perc
                  WHEN grprcp.comm_perc IS NOT NULL THEN grprcp.comm_perc
                  WHEN graccp.comm_perc IS NOT NULL THEN graccp.comm_perc
                  WHEN brokcp.comm_perc IS NOT NULL THEN brokcp.comm_perc
                  WHEN compcp.comm_perc IS NOT NULL THEN compcp.comm_perc
                  ELSE NULL
             END
            ,CASE WHEN pobr.pobr_id        IS  NULL THEN NULL
                  WHEN comp.company_id_no  IS  NULL THEN NULL
                  WHEN policp.comm_perc IS NOT NULL THEN policp.comm_desc
                  WHEN grprcp.comm_perc IS NOT NULL THEN grprcp.comm_desc
                  WHEN graccp.comm_perc IS NOT NULL THEN graccp.comm_desc
                  WHEN brokcp.comm_perc IS NOT NULL THEN brokcp.comm_desc
                  WHEN compcp.comm_perc IS NOT NULL THEN compcp.comm_desc
                  ELSE NULL
             END
            ,CASE WHEN pobr.pobr_id        IS  NULL THEN 'No Policy - Broker Link found'
                  WHEN comp.company_id_no  IS  NULL THEN 'No Valid Company found'
                  WHEN policp.comm_perc IS NOT NULL THEN 'derived from Policy Code ' || policp.policy_code
                  WHEN grprcp.comm_perc IS NOT NULL THEN 'derived from Group Code ' || grprcp.group_code || ', Product Code ' || grprcp.product_code
                  WHEN graccp.comm_perc IS NOT NULL THEN 'derived from Group Code ' || graccp.group_code
                  WHEN brokcp.comm_perc IS NOT NULL THEN 'derived from Broker ID ' || brokcp.broker_id_no
                  WHEN compcp.comm_perc IS NOT NULL THEN 'derived from Company ID ' || compcp.company_id_no
                  ELSE NULL
             END
        INTO p_percentage
            ,p_description
            ,l_return_tmp
        FROM 
             lhhcom.ohi_policies                poli
        LEFT OUTER 
        JOIN lhhcom.ohi_comm_perc               policp
          ON     policp.product_code  IS NULL
             AND policp.poep_id       IS NULL
             AND policp.inse_code     IS NULL
             AND policp.policy_code   = poli.policy_code
             AND policp.group_code    IS NULL
             AND policp.broker_id_no  IS NULL
             AND policp.company_id_no IS NULL
             AND policp.auth_username IS NOT NULL
             AND p_date               BETWEEN     policp.effective_start_date 
                                              AND policp.effective_end_date
        LEFT OUTER
        JOIN lhhcom.ohi_policy_groups           pogr
          ON     poli.poli_id = pogr.poli_id
             AND p_date               BETWEEN     pogr.effective_start_date 
                                              AND pogr.effective_end_date
        LEFT OUTER
        JOIN lhhcom.ohi_groups                  grac
          ON     pogr.grac_id = grac.grac_id
             AND p_date               BETWEEN     grac.effective_start_date 
                                              AND grac.effective_end_date
        LEFT OUTER 
        JOIN lhhcom.ohi_comm_perc               grprcp
          ON     grprcp.product_code  = p_product
             AND grprcp.poep_id       IS NULL
             AND grprcp.inse_code     IS NULL
             AND grprcp.policy_code   IS NULL
             AND grprcp.group_code    = grac.group_code
             AND grprcp.broker_id_no  IS NULL
             AND grprcp.company_id_no IS NULL
             AND grprcp.auth_username IS NOT NULL
             AND p_date               BETWEEN     grprcp.effective_start_date 
                                              AND grprcp.effective_end_date
        LEFT OUTER 
        JOIN lhhcom.ohi_comm_perc               graccp
          ON     graccp.product_code  IS NULL
             AND graccp.poep_id       IS NULL
             AND graccp.inse_code     IS NULL
             AND graccp.policy_code   IS NULL
             AND graccp.group_code    = grac.group_code
             AND graccp.broker_id_no  IS NULL
             AND graccp.company_id_no IS NULL
             AND graccp.auth_username IS NOT NULL
             AND p_date               BETWEEN     graccp.effective_start_date 
                                              AND graccp.effective_end_date
        LEFT OUTER
        JOIN lhhcom.ohi_policy_brokers          pobr
          ON     poli.poli_id = pobr.poli_id
             AND p_date               BETWEEN     pobr.effective_start_date 
                                              AND pobr.effective_end_date
        LEFT OUTER 
        JOIN lhhcom.broker                      brok
          ON     pobr.broker_id_no = brok.broker_id_no
        LEFT OUTER 
        JOIN lhhcom.ohi_comm_perc               brokcp
          ON     brokcp.product_code  IS NULL
             AND brokcp.poep_id       IS NULL
             AND brokcp.inse_code     IS NULL
             AND brokcp.policy_code   IS NULL
             AND brokcp.group_code    IS NULL
             AND brokcp.broker_id_no  = brok.broker_id_no
             AND brokcp.company_id_no IS NULL
             AND brokcp.auth_username IS NOT NULL
             AND p_date               BETWEEN     brokcp.effective_start_date 
                                              AND brokcp.effective_end_date
        LEFT OUTER 
        JOIN lhhcom.company                     comp
          ON     nvl(brok.company_id_no, pobr.company_id_no) = comp.company_id_no
        LEFT OUTER 
        JOIN lhhcom.ohi_comm_perc               compcp
          ON     compcp.product_code  IS NULL
             AND compcp.poep_id       IS NULL
             AND compcp.inse_code     IS NULL
             AND compcp.policy_code   IS NULL
             AND compcp.group_code    IS NULL
             AND compcp.broker_id_no  IS NULL
             AND compcp.company_id_no = comp.company_id_no
             AND compcp.auth_username IS NOT NULL
             AND p_date               BETWEEN     compcp.effective_start_date 
                                              AND compcp.effective_end_date
       WHERE poli.policy_code = p_policy;
      IF p_percentage IS NOT NULL THEN
        p_return_msg             := 'Success: Date ' || p_date || ', Policy ' || p_policy 
                                 || ' returned ' || p_percentage || '% '
                                 || l_return_tmp;
        RETURN;
      END IF;
      RAISE NO_DATA_FOUND;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN 
        p_return_msg             := 'Failure: Date ' || p_date || ', Policy ' || p_policy
                                 || ' could not return any Commission Percentage';
        RETURN;
    END;
  END IF; -- Populated Policy Code Check

/* ***********************************************

Continue from here and remember to still do Hold Ind also

**************************************************
*/

  IF  -- Populated Group and Product Code Check
         p_group IS NOT NULL
     AND p_product IS NOT NULL THEN
    BEGIN
      SELECT 
             CASE WHEN grprcp.comm_perc IS NOT NULL THEN grprcp.comm_perc
                  WHEN graccp.comm_perc IS NOT NULL THEN graccp.comm_perc
                  WHEN brokcp.comm_perc IS NOT NULL THEN brokcp.comm_perc
                  WHEN compcp.comm_perc IS NOT NULL THEN compcp.comm_perc
                  ELSE NULL
             END
            ,CASE WHEN grprcp.comm_perc IS NOT NULL THEN grprcp.comm_desc
                  WHEN graccp.comm_perc IS NOT NULL THEN graccp.comm_desc
                  WHEN brokcp.comm_perc IS NOT NULL THEN brokcp.comm_desc
                  WHEN compcp.comm_perc IS NOT NULL THEN compcp.comm_desc
                  ELSE NULL
             END
            ,CASE WHEN grprcp.comm_perc IS NOT NULL THEN NULL
                  WHEN graccp.comm_perc IS NOT NULL THEN 'derived from Group Code ' || graccp.group_code
                  WHEN brokcp.comm_perc IS NOT NULL THEN 'derived from Broker ID ' || brokcp.broker_id_no
                  WHEN compcp.comm_perc IS NOT NULL THEN 'derived from Company ID ' || compcp.company_id_no
                  ELSE NULL
             END
        INTO p_percentage
            ,p_description
            ,l_return_tmp
        FROM 
             ohi_groups                  grac
        LEFT OUTER JOIN
             ohi_comm_perc               grprcp
          ON grprcp.product_code  = p_product
         AND grprcp.poep_id       IS NULL
         AND grprcp.inse_code     IS NULL
         AND grprcp.policy_code   IS NULL
         AND grprcp.group_code    = grac.group_code
         AND grprcp.broker_id_no  IS NULL
         AND grprcp.company_id_no IS NULL
         AND grprcp.auth_username IS NOT NULL
         AND p_date BETWEEN grprcp.effective_start_date 
                        AND grprcp.effective_end_date
        LEFT OUTER JOIN
             ohi_comm_perc               graccp
          ON graccp.product_code  IS NULL
         AND graccp.poep_id       IS NULL
         AND graccp.inse_code     IS NULL
         AND graccp.policy_code   IS NULL
         AND graccp.group_code    = grac.group_code
         AND graccp.broker_id_no  IS NULL
         AND graccp.company_id_no IS NULL
         AND graccp.auth_username IS NOT NULL
         AND p_date BETWEEN graccp.effective_start_date 
                        AND graccp.effective_end_date
        INNER JOIN
             ohi_policy_groups           pogr
          ON grac.grac_id = pogr.grac_id
         AND p_date BETWEEN pogr.effective_start_date 
                        AND pogr.effective_end_date
        LEFT OUTER JOIN
             ohi_policies                poli
          ON pogr.poli_id = poli.poli_id
        LEFT OUTER JOIN
             ohi_policy_brokers          pobr
          ON poli.poli_id = pobr.poli_id
         AND p_date BETWEEN pobr.effective_start_date 
                        AND pobr.effective_end_date
        LEFT OUTER JOIN
             broker                      brok
          ON pobr.broker_id_no = brok.broker_id_no
        LEFT OUTER JOIN
             ohi_comm_perc               brokcp
          ON brokcp.product_code  IS NULL
         AND brokcp.poep_id       IS NULL
         AND brokcp.inse_code     IS NULL
         AND brokcp.policy_code   IS NULL
         AND brokcp.group_code    IS NULL
         AND brokcp.broker_id_no  = brok.broker_id_no
         AND brokcp.company_id_no IS NULL
         AND brokcp.auth_username IS NOT NULL
         AND p_date BETWEEN brokcp.effective_start_date 
                        AND brokcp.effective_end_date
        INNER JOIN
             company                     comp
          ON nvl(brok.company_id_no, pobr.company_id_no) = comp.company_id_no
        LEFT OUTER JOIN
             ohi_comm_perc               compcp
          ON compcp.product_code  IS NULL
         AND compcp.poep_id       IS NULL
         AND compcp.inse_code     IS NULL
         AND compcp.policy_code   IS NULL
         AND compcp.group_code    IS NULL
         AND compcp.broker_id_no  IS NULL
         AND compcp.company_id_no = comp.company_id_no
         AND compcp.auth_username IS NOT NULL
         AND p_date BETWEEN compcp.effective_start_date 
                        AND compcp.effective_end_date
       WHERE grac.group_code = p_group
         AND p_date BETWEEN grac.effective_start_date 
                        AND grac.effective_end_date
         AND ROWNUM = 1;
      IF p_percentage IS NOT NULL THEN
        p_return_msg             := 'Success: Date ' || p_date || ', Group ' || p_group || ', Product ' || p_product
                                 || ' returned ' || p_percentage || '% '
                                 || l_return_tmp;
        RETURN;
      END IF;
      RAISE NO_DATA_FOUND;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN 
        p_return_msg             := 'Failure: Date ' || p_date || ', Group ' || p_group || ', Product ' || p_product
                                 || ' could not return any Commission Percentage';
        RETURN;
    END;
  END IF; -- Populated Group and Product Code Check

  IF  -- Populated Group Code Check
         p_group IS NOT NULL THEN
    BEGIN
      SELECT 
             CASE WHEN graccp.comm_perc IS NOT NULL THEN graccp.comm_perc
                  WHEN brokcp.comm_perc IS NOT NULL THEN brokcp.comm_perc
                  WHEN compcp.comm_perc IS NOT NULL THEN compcp.comm_perc
                  ELSE NULL
             END
            ,CASE WHEN graccp.comm_perc IS NOT NULL THEN graccp.comm_desc
                  WHEN brokcp.comm_perc IS NOT NULL THEN brokcp.comm_desc
                  WHEN compcp.comm_perc IS NOT NULL THEN compcp.comm_desc
                  ELSE NULL
             END
            ,CASE WHEN graccp.comm_perc IS NOT NULL THEN NULL
                  WHEN brokcp.comm_perc IS NOT NULL THEN 'derived from Broker ID ' || brokcp.broker_id_no
                  WHEN compcp.comm_perc IS NOT NULL THEN 'derived from Company ID ' || compcp.company_id_no
                  ELSE NULL
             END
        INTO p_percentage
            ,p_description
            ,l_return_tmp
        FROM 
             ohi_groups                  grac
        LEFT OUTER JOIN
             ohi_comm_perc               graccp
          ON graccp.product_code  IS NULL
         AND graccp.poep_id       IS NULL
         AND graccp.inse_code     IS NULL
         AND graccp.policy_code   IS NULL
         AND graccp.group_code    = grac.group_code
         AND graccp.broker_id_no  IS NULL
         AND graccp.company_id_no IS NULL
         AND graccp.auth_username IS NOT NULL
         AND p_date BETWEEN graccp.effective_start_date 
                        AND graccp.effective_end_date
        INNER JOIN
             ohi_policy_groups           pogr
          ON grac.grac_id = pogr.grac_id
         AND p_date BETWEEN pogr.effective_start_date 
                        AND pogr.effective_end_date
        LEFT OUTER JOIN
             ohi_policies                poli
          ON pogr.poli_id = poli.poli_id
        LEFT OUTER JOIN
             ohi_policy_brokers          pobr
          ON poli.poli_id = pobr.poli_id
         AND p_date BETWEEN pobr.effective_start_date 
                        AND pobr.effective_end_date
        LEFT OUTER JOIN
             broker                      brok
          ON pobr.broker_id_no = brok.broker_id_no
        LEFT OUTER JOIN
             ohi_comm_perc               brokcp
          ON brokcp.product_code  IS NULL
         AND brokcp.poep_id       IS NULL
         AND brokcp.inse_code     IS NULL
         AND brokcp.policy_code   IS NULL
         AND brokcp.group_code    IS NULL
         AND brokcp.broker_id_no  = brok.broker_id_no
         AND brokcp.company_id_no IS NULL
         AND brokcp.auth_username IS NOT NULL
         AND p_date BETWEEN brokcp.effective_start_date 
                        AND brokcp.effective_end_date
        INNER JOIN
             company                     comp
          ON nvl(brok.company_id_no, pobr.company_id_no) = comp.company_id_no
        LEFT OUTER JOIN
             ohi_comm_perc               compcp
          ON compcp.product_code  IS NULL
         AND compcp.poep_id       IS NULL
         AND compcp.inse_code     IS NULL
         AND compcp.policy_code   IS NULL
         AND compcp.group_code    IS NULL
         AND compcp.broker_id_no  IS NULL
         AND compcp.company_id_no = comp.company_id_no
         AND compcp.auth_username IS NOT NULL
         AND p_date BETWEEN compcp.effective_start_date 
                        AND compcp.effective_end_date
       WHERE grac.group_code = p_group
         AND p_date BETWEEN grac.effective_start_date 
                        AND grac.effective_end_date
         AND ROWNUM = 1;
      IF p_percentage IS NOT NULL THEN
        p_return_msg             := 'Success: Date ' || p_date || ', Group ' || p_group
                                 || ' returned ' || p_percentage || '% '
                                 || l_return_tmp;
        RETURN;
      END IF;
      RAISE NO_DATA_FOUND;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN 
        p_return_msg             := 'Failure: Date ' || p_date || ', Group ' || p_group
                                 || ' could not return any Commission Percentage';
        RETURN;
    END;
  END IF; -- Populated Group Code Check

  IF  -- Populated  Broker ID Check
         p_broker IS NOT NULL THEN
    BEGIN
      SELECT 
             CASE WHEN brokcp.comm_perc IS NOT NULL THEN brokcp.comm_perc
                  WHEN compcp.comm_perc IS NOT NULL THEN compcp.comm_perc
                  ELSE NULL
             END
            ,CASE WHEN brokcp.comm_perc IS NOT NULL THEN brokcp.comm_desc
                  WHEN compcp.comm_perc IS NOT NULL THEN compcp.comm_desc
                  ELSE NULL
             END
            ,CASE WHEN brokcp.comm_perc IS NOT NULL THEN NULL
                  WHEN compcp.comm_perc IS NOT NULL THEN 'derived from Company ID ' || compcp.company_id_no
                  ELSE NULL
             END
        INTO p_percentage
            ,p_description
            ,l_return_tmp
        FROM 
             broker                      brok
        LEFT OUTER JOIN
             ohi_comm_perc               brokcp
          ON brokcp.product_code  IS NULL
         AND brokcp.poep_id       IS NULL
         AND brokcp.inse_code     IS NULL
         AND brokcp.policy_code   IS NULL
         AND brokcp.group_code    IS NULL
         AND brokcp.broker_id_no  = brok.broker_id_no
         AND brokcp.company_id_no IS NULL
         AND brokcp.auth_username IS NOT NULL
         AND p_date BETWEEN brokcp.effective_start_date 
                        AND brokcp.effective_end_date
        INNER JOIN
             company                     comp
          ON brok.company_id_no = comp.company_id_no
        LEFT OUTER JOIN
             ohi_comm_perc               compcp
          ON compcp.product_code  IS NULL
         AND compcp.poep_id       IS NULL
         AND compcp.inse_code     IS NULL
         AND compcp.policy_code   IS NULL
         AND compcp.group_code    IS NULL
         AND compcp.broker_id_no  IS NULL
         AND compcp.company_id_no = comp.company_id_no
         AND compcp.auth_username IS NOT NULL
         AND p_date BETWEEN compcp.effective_start_date 
                        AND compcp.effective_end_date
       WHERE brok.broker_id_no = p_broker;
      IF p_percentage IS NOT NULL THEN
        p_return_msg             := 'Success: Date ' || p_date || ', Broker ' || p_broker
                                 || ' returned ' || p_percentage || '% '
                                 || l_return_tmp;
        RETURN;
      END IF;
      RAISE NO_DATA_FOUND;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN 
        p_return_msg             := 'Failure: Date ' || p_date || ', Broker ' || p_broker
                                 || ' could not return any Commission Percentage';
        RETURN;
    END;
  END IF; -- Populated Broker ID Check

  IF  -- Populated  Company ID Check
         p_company IS NOT NULL THEN
    BEGIN
      SELECT 
             CASE WHEN compcp.comm_perc IS NOT NULL THEN compcp.comm_perc
                  ELSE NULL
             END
            ,CASE WHEN compcp.comm_perc IS NOT NULL THEN compcp.comm_desc
                  ELSE NULL
             END
            ,CASE WHEN compcp.comm_perc IS NOT NULL THEN NULL
                  ELSE NULL
             END
        INTO p_percentage
            ,p_description
            ,l_return_tmp
        FROM 
             company                     comp
        LEFT OUTER JOIN
             ohi_comm_perc               compcp
          ON compcp.product_code  IS NULL
         AND compcp.poep_id       IS NULL
         AND compcp.inse_code     IS NULL
         AND compcp.policy_code   IS NULL
         AND compcp.group_code    IS NULL
         AND compcp.broker_id_no  IS NULL
         AND compcp.company_id_no = comp.company_id_no
         AND compcp.auth_username IS NOT NULL
         AND p_date BETWEEN compcp.effective_start_date 
                        AND compcp.effective_end_date
       WHERE comp.company_id_no = p_company;
      IF p_percentage IS NOT NULL THEN
        p_return_msg             := 'Success: Date ' || p_date || ', Company ' || p_company
                                 || ' returned ' || p_percentage || '% '
                                 || l_return_tmp;
        RETURN;
      END IF;
      RAISE NO_DATA_FOUND;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN 
        p_return_msg             := 'Failure: Date ' || p_date || ', Company ' || p_company
                                 || ' could not return any Commission Percentage';
        RETURN;
    END;
  END IF; -- Populated Company ID Check

  IF p_return_msg IS NULL THEN
     p_return_msg := 'ERROR: Nothing Done for Parameter set.';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1422 THEN
      p_return_msg := 'ERROR: Data Integrity Error. More than one record retrieved for date '||p_date||', ';
      IF p_company IS NOT NULL THEN
  		   p_return_msg := p_return_msg||' and Brokerage Code '||p_company||'.';
 		  END IF;
      IF p_poep IS NOT NULL THEN
		     p_return_msg := p_return_msg||' and Enrollment Product Code '||p_poep||'.';
      END IF;
		  IF p_group IS NOT NULL THEN
		    p_return_msg := p_return_msg||' and Employer Group Code '||p_group||'.';
		  END IF;
	    IF p_product IS NOT NULL THEN
		    p_return_msg := p_return_msg||' and Benefit Plan Code '||p_product||'.';
		  END IF;
	    IF p_policy IS NOT NULL THEN
		    p_return_msg := p_return_msg||' and Policy Code '||p_policy||'.';
		  END IF;
	    IF p_person IS NOT NULL THEN
		    p_return_msg := p_return_msg||' and Member Code '||p_person||'.';
		  END IF;
	    IF p_broker IS NOT NULL THEN
		    p_return_msg := p_return_msg||' and Broker Code '||p_broker||'.';
		  END IF;
    ELSE
      p_return_msg := 'ERROR: Get_Percentage failed with exception error: ' || sqlerrm;
      logger.log_error('Unhandled Exception', l_scope, null, l_params);
    END IF;

END get_percentage;

/**********************************************************************************************************************/

PROCEDURE get_hold_ind         (p_date           IN  DATE     DEFAULT SYSDATE
                               ,p_company        IN  NUMBER   DEFAULT NULL
                               ,p_broker         IN  NUMBER   DEFAULT NULL
                               ,p_group          IN  VARCHAR2 DEFAULT NULL
                               ,p_product        IN  VARCHAR2 DEFAULT NULL
                               ,p_policy         IN  VARCHAR2 DEFAULT NULL
                               ,p_person         IN  VARCHAR2 DEFAULT NULL
                               ,p_poep           IN  VARCHAR2 DEFAULT NULL
                               ,p_hold_ind       OUT ohi_hold_ind.hold_ind%type
                               ,p_hold_reason    OUT ohi_hold_ind.hold_reason%type
                               ,p_return_msg     OUT VARCHAR2)

IS

  gc_scope_prefix       CONSTANT VARCHAR2(31)           
                                 := lower($$PLSQL_UNIT) || '.';
  l_scope                        logger_logs.scope%TYPE 
                                 := 'Commissions: ' || gc_scope_prefix;
  l_params                       logger.tab_param;
  l_return_tmp                   VARCHAR2(100);

BEGIN
  p_hold_ind                   := NULL;
  p_hold_reason                := NULL;
  p_return_msg                 := NULL;

  -- Setting the logger values in case of errors
  logger.append_param(l_params, 'get_hold_ind:', 'Date ' || p_date
    || ' Company ' || p_company || ' Broker ' || p_broker || ' Group ' || p_group
    || ' Product ' || p_product || ' policy ' || p_policy || ' Person ' || p_person
    || ' POEP ' || p_poep);

  IF  -- Not NULL Parameters Check
         p_company IS NULL 
     AND p_broker  IS NULL
     AND p_group   IS NULL
     AND p_product IS NULL
     AND p_policy  IS NULL
     AND p_person  IS NULL
     AND p_poep    IS NULL THEN
    p_return_msg := 'ERROR: Cannot Retrieve a Hold Indicator when all paramaters are NULL.';
    RETURN;
  END IF; -- Not NULL Parameters Check

  IF  -- Populated POEP Id Check
         p_poep IS NOT NULL THEN
    BEGIN
      SELECT 
             CASE WHEN poephi.hold_ind = 'Y' THEN poephi.hold_ind
                  WHEN insehi.hold_ind = 'Y' THEN insehi.hold_ind
                  WHEN polihi.hold_ind = 'Y' THEN polihi.hold_ind
                  WHEN grprhi.hold_ind = 'Y' THEN grprhi.hold_ind
                  WHEN grachi.hold_ind = 'Y' THEN grachi.hold_ind
                  WHEN brokhi.hold_ind = 'Y' THEN brokhi.hold_ind
                  WHEN comphi.hold_ind = 'Y' THEN comphi.hold_ind
                  ELSE NULL
             END
            ,CASE WHEN poephi.hold_ind = 'Y' THEN poephi.hold_reason
                  WHEN insehi.hold_ind = 'Y' THEN insehi.hold_reason
                  WHEN polihi.hold_ind = 'Y' THEN polihi.hold_reason
                  WHEN grprhi.hold_ind = 'Y' THEN grprhi.hold_reason
                  WHEN grachi.hold_ind = 'Y' THEN grachi.hold_reason
                  WHEN brokhi.hold_ind = 'Y' THEN brokhi.hold_reason
                  WHEN comphi.hold_ind = 'Y' THEN comphi.hold_reason
                  ELSE NULL
             END
            ,CASE WHEN poephi.hold_ind = 'Y' THEN NULL
                  WHEN insehi.hold_ind = 'Y' THEN 'derived from Person Code ' || insehi.inse_code
                  WHEN polihi.hold_ind = 'Y' THEN 'derived from Policy Code ' || polihi.policy_code
                  WHEN grprhi.hold_ind = 'Y' THEN 'derived from Group Code ' || grprhi.group_code || ', Product Code ' || grprhi.product_code
                  WHEN grachi.hold_ind = 'Y' THEN 'derived from Group Code ' || grachi.group_code
                  WHEN brokhi.hold_ind = 'Y' THEN 'derived from Broker ID ' || brokhi.broker_id_no
                  WHEN comphi.hold_ind = 'Y' THEN 'derived from Company ID ' || comphi.company_id_no
                  ELSE NULL
             END
        INTO p_hold_ind
            ,p_hold_reason
            ,l_return_tmp
        FROM 
             ohi_enrollment_products     poep
        LEFT OUTER JOIN
             ohi_hold_ind                poephi
          ON poephi.product_code  IS NULL
         AND poephi.poep_id       = poep.poep_id
         AND poephi.inse_code     IS NULL
         AND poephi.policy_code   IS NULL
         AND poephi.group_code    IS NULL
         AND poephi.broker_id_no  IS NULL
         AND poephi.company_id_no IS NULL
         AND p_date BETWEEN poephi.effective_start_date 
                        AND poephi.effective_end_date
        INNER JOIN
             ohi_policy_enrollments      poen
          ON poep.poen_id = poen.poen_id
        INNER JOIN
             ohi_insured_entities        inse
          ON poen.inse_id = inse.inse_id
        LEFT OUTER JOIN
             ohi_hold_ind                insehi
          ON insehi.product_code  IS NULL
         AND insehi.poep_id       IS NULL
         AND insehi.inse_code     = inse.inse_code
         AND insehi.policy_code   IS NULL
         AND insehi.group_code    IS NULL
         AND insehi.broker_id_no  IS NULL
         AND insehi.company_id_no IS NULL
         AND p_date BETWEEN insehi.effective_start_date 
                        AND insehi.effective_end_date
        INNER JOIN
             ohi_policies                poli
          ON poen.poli_id = poli.poli_id
        LEFT OUTER JOIN
             ohi_hold_ind                polihi
          ON polihi.product_code  IS NULL
         AND polihi.poep_id       IS NULL
         AND polihi.inse_code     IS NULL
         AND polihi.policy_code   = poli.policy_code
         AND polihi.group_code    IS NULL
         AND polihi.broker_id_no  IS NULL
         AND polihi.company_id_no IS NULL
         AND p_date BETWEEN polihi.effective_start_date 
                        AND polihi.effective_end_date
        INNER JOIN
             ohi_policy_groups           pogr
          ON poli.poli_id = pogr.poli_id
         AND p_date BETWEEN pogr.effective_start_date 
                        AND pogr.effective_end_date
        INNER JOIN
             ohi_groups                  grac
          ON pogr.grac_id = grac.grac_id
         AND p_date BETWEEN grac.effective_start_date 
                        AND grac.effective_end_date
        INNER JOIN
             ohi_products                enpr
          ON poep.enpr_id = enpr.enpr_id
        LEFT OUTER JOIN
             ohi_hold_ind                grprhi
          ON grprhi.product_code  = enpr.product_code
         AND grprhi.poep_id       IS NULL
         AND grprhi.inse_code     IS NULL
         AND grprhi.policy_code   IS NULL
         AND grprhi.group_code    = grac.group_code
         AND grprhi.broker_id_no  IS NULL
         AND grprhi.company_id_no IS NULL
         AND p_date BETWEEN grprhi.effective_start_date 
                        AND grprhi.effective_end_date
        LEFT OUTER JOIN
             ohi_hold_ind                grachi
          ON grachi.product_code  IS NULL
         AND grachi.poep_id       IS NULL
         AND grachi.inse_code     IS NULL
         AND grachi.policy_code   IS NULL
         AND grachi.group_code    = grac.group_code
         AND grachi.broker_id_no  IS NULL
         AND grachi.company_id_no IS NULL
         AND p_date BETWEEN grachi.effective_start_date 
                        AND grachi.effective_end_date
        LEFT OUTER JOIN
             ohi_policy_brokers          pobr
          ON poli.poli_id = pobr.poli_id
         AND p_date BETWEEN pobr.effective_start_date 
                        AND pobr.effective_end_date
        LEFT OUTER JOIN
             broker                      brok
          ON pobr.broker_id_no = brok.broker_id_no
        LEFT OUTER JOIN
             ohi_hold_ind                brokhi
          ON brokhi.product_code  IS NULL
         AND brokhi.poep_id       IS NULL
         AND brokhi.inse_code     IS NULL
         AND brokhi.policy_code   IS NULL
         AND brokhi.group_code    IS NULL
         AND brokhi.broker_id_no  = brok.broker_id_no
         AND brokhi.company_id_no IS NULL
         AND p_date BETWEEN brokhi.effective_start_date 
                        AND brokhi.effective_end_date
        INNER JOIN
             company                     comp
          ON nvl(brok.company_id_no, pobr.company_id_no) = comp.company_id_no
        LEFT OUTER JOIN
             ohi_hold_ind                comphi
          ON comphi.product_code  IS NULL
         AND comphi.poep_id       IS NULL
         AND comphi.inse_code     IS NULL
         AND comphi.policy_code   IS NULL
         AND comphi.group_code    IS NULL
         AND comphi.broker_id_no  IS NULL
         AND comphi.company_id_no = comp.company_id_no
         AND p_date BETWEEN comphi.effective_start_date 
                        AND comphi.effective_end_date
       WHERE poep.poep_id = p_poep
         AND p_date BETWEEN poep.effective_start_date 
                        AND poep.effective_end_date;
      IF p_hold_ind = 'Y' THEN
        p_return_msg             := 'Success: Date ' || p_date || ', POEP ' || p_poep 
                                 || ' returned Hold Ind - ' || p_hold_ind || ' '
                                 || l_return_tmp;
        RETURN;
      END IF;
      RAISE NO_DATA_FOUND;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN 
        p_return_msg             := 'Failure: Date ' || p_date || ', POEP ' || p_poep 
                                 || ' could not return any Hold Indicator';
        RETURN;
    END;
  END IF; -- Populated POEP Id Check

  IF  -- Populated Person Code Check
         p_person IS NOT NULL THEN
    BEGIN
      SELECT 
             CASE WHEN insehi.hold_ind = 'Y' THEN insehi.hold_ind
                  WHEN polihi.hold_ind = 'Y' THEN polihi.hold_ind
                  WHEN grprhi.hold_ind = 'Y' THEN grprhi.hold_ind
                  WHEN grachi.hold_ind = 'Y' THEN grachi.hold_ind
                  WHEN brokhi.hold_ind = 'Y' THEN brokhi.hold_ind
                  WHEN comphi.hold_ind = 'Y' THEN comphi.hold_ind
                  ELSE NULL
             END
            ,CASE WHEN insehi.hold_ind = 'Y' THEN insehi.hold_reason
                  WHEN polihi.hold_ind = 'Y' THEN polihi.hold_reason
                  WHEN grprhi.hold_ind = 'Y' THEN grprhi.hold_reason
                  WHEN grachi.hold_ind = 'Y' THEN grachi.hold_reason
                  WHEN brokhi.hold_ind = 'Y' THEN brokhi.hold_reason
                  WHEN comphi.hold_ind = 'Y' THEN comphi.hold_reason
                  ELSE NULL
             END
            ,CASE WHEN insehi.hold_ind = 'Y' THEN NULL
                  WHEN polihi.hold_ind = 'Y' THEN 'derived from Policy Code ' || polihi.policy_code
                  WHEN grprhi.hold_ind = 'Y' THEN 'derived from Group Code ' || grprhi.group_code || ', Product Code ' || grprhi.product_code
                  WHEN grachi.hold_ind = 'Y' THEN 'derived from Group Code ' || grachi.group_code
                  WHEN brokhi.hold_ind = 'Y' THEN 'derived from Broker ID ' || brokhi.broker_id_no
                  WHEN comphi.hold_ind = 'Y' THEN 'derived from Company ID ' || comphi.company_id_no
                  ELSE NULL
             END
        INTO p_hold_ind
            ,p_hold_reason
            ,l_return_tmp
        FROM 
             ohi_policy_enrollments      poen
        INNER JOIN
             ohi_insured_entities        inse
          ON poen.inse_id = inse.inse_id
        LEFT OUTER JOIN
             ohi_hold_ind                insehi
          ON insehi.product_code  IS NULL
         AND insehi.poep_id       IS NULL
         AND insehi.inse_code     = inse.inse_code
         AND insehi.policy_code   IS NULL
         AND insehi.group_code    IS NULL
         AND insehi.broker_id_no  IS NULL
         AND insehi.company_id_no IS NULL
         AND p_date BETWEEN insehi.effective_start_date 
                        AND insehi.effective_end_date
        INNER JOIN
             ohi_policies                poli
          ON poen.poli_id = poli.poli_id
        LEFT OUTER JOIN
             ohi_hold_ind                polihi
          ON polihi.product_code  IS NULL
         AND polihi.poep_id       IS NULL
         AND polihi.inse_code     IS NULL
         AND polihi.policy_code   = poli.policy_code
         AND polihi.group_code    IS NULL
         AND polihi.broker_id_no  IS NULL
         AND polihi.company_id_no IS NULL
         AND p_date BETWEEN polihi.effective_start_date 
                        AND polihi.effective_end_date
        INNER JOIN
             ohi_policy_groups           pogr
          ON poli.poli_id = pogr.poli_id
         AND p_date BETWEEN pogr.effective_start_date 
                        AND pogr.effective_end_date
        INNER JOIN
             ohi_groups                  grac
          ON pogr.grac_id = grac.grac_id
         AND p_date BETWEEN grac.effective_start_date 
                        AND grac.effective_end_date
        LEFT OUTER JOIN
             ohi_hold_ind                grprhi
          ON grprhi.product_code  = p_product
         AND grprhi.poep_id       IS NULL
         AND grprhi.inse_code     IS NULL
         AND grprhi.policy_code   IS NULL
         AND grprhi.group_code    = grac.group_code
         AND grprhi.broker_id_no  IS NULL
         AND grprhi.company_id_no IS NULL
         AND p_date BETWEEN grprhi.effective_start_date 
                        AND grprhi.effective_end_date
        LEFT OUTER JOIN
             ohi_hold_ind                grachi
          ON grachi.product_code  IS NULL
         AND grachi.poep_id       IS NULL
         AND grachi.inse_code     IS NULL
         AND grachi.policy_code   IS NULL
         AND grachi.group_code    = grac.group_code
         AND grachi.broker_id_no  IS NULL
         AND grachi.company_id_no IS NULL
         AND p_date BETWEEN grachi.effective_start_date 
                        AND grachi.effective_end_date
        LEFT OUTER JOIN
             ohi_policy_brokers          pobr
          ON poli.poli_id = pobr.poli_id
         AND p_date BETWEEN pobr.effective_start_date 
                        AND pobr.effective_end_date
        LEFT OUTER JOIN
             broker                      brok
          ON pobr.broker_id_no = brok.broker_id_no
        LEFT OUTER JOIN
             ohi_hold_ind                brokhi
          ON brokhi.product_code  IS NULL
         AND brokhi.poep_id       IS NULL
         AND brokhi.inse_code     IS NULL
         AND brokhi.policy_code   IS NULL
         AND brokhi.group_code    IS NULL
         AND brokhi.broker_id_no  = brok.broker_id_no
         AND brokhi.company_id_no IS NULL
         AND p_date BETWEEN brokhi.effective_start_date 
                        AND brokhi.effective_end_date
        INNER JOIN
             company                     comp
          ON nvl(brok.company_id_no, pobr.company_id_no) = comp.company_id_no
        LEFT OUTER JOIN
             ohi_hold_ind                comphi
          ON comphi.product_code  IS NULL
         AND comphi.poep_id       IS NULL
         AND comphi.inse_code     IS NULL
         AND comphi.policy_code   IS NULL
         AND comphi.group_code    IS NULL
         AND comphi.broker_id_no  IS NULL
         AND comphi.company_id_no = comp.company_id_no
         AND p_date BETWEEN comphi.effective_start_date 
                        AND comphi.effective_end_date
       WHERE inse.inse_code = p_person;
      IF p_hold_ind = 'Y' THEN
        p_return_msg             := 'Success: Date ' || p_date || ', Person ' || p_person 
                                 || ' returned Hold Ind - ' || p_hold_ind || ' '
                                 || l_return_tmp;
        RETURN;
      END IF;
      RAISE NO_DATA_FOUND;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN 
        p_return_msg             := 'Failure: Date ' || p_date || ', Person ' || p_person
                                 || ' could not return any Hold Indicator';
        RETURN;
    END;
  END IF; -- Populated Person Code Check

  IF  -- Populated Policy Code Check
         p_policy IS NOT NULL THEN
    BEGIN
      SELECT 
             CASE WHEN polihi.hold_ind = 'Y' THEN polihi.hold_ind
                  WHEN grprhi.hold_ind = 'Y' THEN grprhi.hold_ind
                  WHEN grachi.hold_ind = 'Y' THEN grachi.hold_ind
                  WHEN brokhi.hold_ind = 'Y' THEN brokhi.hold_ind
                  WHEN comphi.hold_ind = 'Y' THEN comphi.hold_ind
                  ELSE NULL
             END
            ,CASE WHEN polihi.hold_ind = 'Y' THEN polihi.hold_reason
                  WHEN grprhi.hold_ind = 'Y' THEN grprhi.hold_reason
                  WHEN grachi.hold_ind = 'Y' THEN grachi.hold_reason
                  WHEN brokhi.hold_ind = 'Y' THEN brokhi.hold_reason
                  WHEN comphi.hold_ind = 'Y' THEN comphi.hold_reason
                  ELSE NULL
             END
            ,CASE WHEN polihi.hold_ind = 'Y' THEN NULL
                  WHEN grprhi.hold_ind = 'Y' THEN 'derived from Group Code ' || grprhi.group_code || ', Product Code ' || grprhi.product_code
                  WHEN grachi.hold_ind = 'Y' THEN 'derived from Group Code ' || grachi.group_code
                  WHEN brokhi.hold_ind = 'Y' THEN 'derived from Broker ID ' || brokhi.broker_id_no
                  WHEN comphi.hold_ind = 'Y' THEN 'derived from Company ID ' || comphi.company_id_no
                  ELSE NULL
             END
        INTO p_hold_ind
            ,p_hold_reason
            ,l_return_tmp
        FROM 
             ohi_policies                poli
        LEFT OUTER JOIN
             ohi_hold_ind                polihi
          ON polihi.product_code  IS NULL
         AND polihi.poep_id       IS NULL
         AND polihi.inse_code     IS NULL
         AND polihi.policy_code   = poli.policy_code
         AND polihi.group_code    IS NULL
         AND polihi.broker_id_no  IS NULL
         AND polihi.company_id_no IS NULL
         AND p_date BETWEEN polihi.effective_start_date 
                        AND polihi.effective_end_date
        INNER JOIN
             ohi_policy_groups           pogr
          ON poli.poli_id = pogr.poli_id
         AND p_date BETWEEN pogr.effective_start_date 
                        AND pogr.effective_end_date
        INNER JOIN
             ohi_groups                  grac
          ON pogr.grac_id = grac.grac_id
         AND p_date BETWEEN grac.effective_start_date 
                        AND grac.effective_end_date
        LEFT OUTER JOIN
             ohi_hold_ind                grprhi
          ON grprhi.product_code  = p_product
         AND grprhi.poep_id       IS NULL
         AND grprhi.inse_code     IS NULL
         AND grprhi.policy_code   IS NULL
         AND grprhi.group_code    = grac.group_code
         AND grprhi.broker_id_no  IS NULL
         AND grprhi.company_id_no IS NULL
         AND p_date BETWEEN grprhi.effective_start_date 
                        AND grprhi.effective_end_date
        LEFT OUTER JOIN
             ohi_hold_ind                grachi
          ON grachi.product_code  IS NULL
         AND grachi.poep_id       IS NULL
         AND grachi.inse_code     IS NULL
         AND grachi.policy_code   IS NULL
         AND grachi.group_code    = grac.group_code
         AND grachi.broker_id_no  IS NULL
         AND grachi.company_id_no IS NULL
         AND p_date BETWEEN grachi.effective_start_date 
                        AND grachi.effective_end_date
        LEFT OUTER JOIN
             ohi_policy_brokers          pobr
          ON poli.poli_id = pobr.poli_id
         AND p_date BETWEEN pobr.effective_start_date 
                        AND pobr.effective_end_date
        LEFT OUTER JOIN
             broker                      brok
          ON pobr.broker_id_no = brok.broker_id_no
        LEFT OUTER JOIN
             ohi_hold_ind                brokhi
          ON brokhi.product_code  IS NULL
         AND brokhi.poep_id       IS NULL
         AND brokhi.inse_code     IS NULL
         AND brokhi.policy_code   IS NULL
         AND brokhi.group_code    IS NULL
         AND brokhi.broker_id_no  = brok.broker_id_no
         AND brokhi.company_id_no IS NULL
         AND p_date BETWEEN brokhi.effective_start_date 
                        AND brokhi.effective_end_date
        INNER JOIN
             company                     comp
          ON nvl(brok.company_id_no, pobr.company_id_no) = comp.company_id_no
        LEFT OUTER JOIN
             ohi_hold_ind                comphi
          ON comphi.product_code  IS NULL
         AND comphi.poep_id       IS NULL
         AND comphi.inse_code     IS NULL
         AND comphi.policy_code   IS NULL
         AND comphi.group_code    IS NULL
         AND comphi.broker_id_no  IS NULL
         AND comphi.company_id_no = comp.company_id_no
         AND p_date BETWEEN comphi.effective_start_date 
                        AND comphi.effective_end_date
       WHERE poli.policy_code = p_policy;
      IF p_hold_ind = 'Y' THEN
        p_return_msg             := 'Success: Date ' || p_date || ', Policy ' || p_policy 
                                 || ' returned Hold Ind - ' || p_hold_ind || ' '
                                 || l_return_tmp;
        RETURN;
      END IF;
      RAISE NO_DATA_FOUND;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN 
        p_return_msg             := 'Failure: Date ' || p_date || ', Policy ' || p_policy
                                 || ' could not return any Hold Indicator';
        RETURN;
    END;
  END IF; -- Populated Policy Code Check

  IF  -- Populated Group and Product Code Check
         p_group IS NOT NULL
     AND p_product IS NOT NULL THEN
    BEGIN
      SELECT 
             CASE WHEN grprhi.hold_ind = 'Y' THEN grprhi.hold_ind
                  WHEN grachi.hold_ind = 'Y' THEN grachi.hold_ind
                  WHEN brokhi.hold_ind = 'Y' THEN brokhi.hold_ind
                  WHEN comphi.hold_ind = 'Y' THEN comphi.hold_ind
                  ELSE NULL
             END
            ,CASE WHEN grprhi.hold_ind = 'Y' THEN grprhi.hold_reason
                  WHEN grachi.hold_ind = 'Y' THEN grachi.hold_reason
                  WHEN brokhi.hold_ind = 'Y' THEN brokhi.hold_reason
                  WHEN comphi.hold_ind = 'Y' THEN comphi.hold_reason
                  ELSE NULL
             END
            ,CASE WHEN grprhi.hold_ind = 'Y' THEN NULL
                  WHEN grachi.hold_ind = 'Y' THEN 'derived from Group Code ' || grachi.group_code
                  WHEN brokhi.hold_ind = 'Y' THEN 'derived from Broker ID ' || brokhi.broker_id_no
                  WHEN comphi.hold_ind = 'Y' THEN 'derived from Company ID ' || comphi.company_id_no
                  ELSE NULL
             END
        INTO p_hold_ind
            ,p_hold_reason
            ,l_return_tmp
        FROM 
             ohi_groups                  grac
        LEFT OUTER JOIN
             ohi_hold_ind                grprhi
          ON grprhi.product_code  = p_product
         AND grprhi.poep_id       IS NULL
         AND grprhi.inse_code     IS NULL
         AND grprhi.policy_code   IS NULL
         AND grprhi.group_code    = grac.group_code
         AND grprhi.broker_id_no  IS NULL
         AND grprhi.company_id_no IS NULL
         AND p_date BETWEEN grprhi.effective_start_date 
                        AND grprhi.effective_end_date
        LEFT OUTER JOIN
             ohi_hold_ind                grachi
          ON grachi.product_code  IS NULL
         AND grachi.poep_id       IS NULL
         AND grachi.inse_code     IS NULL
         AND grachi.policy_code   IS NULL
         AND grachi.group_code    = grac.group_code
         AND grachi.broker_id_no  IS NULL
         AND grachi.company_id_no IS NULL
         AND p_date BETWEEN grachi.effective_start_date 
                        AND grachi.effective_end_date
        INNER JOIN
             ohi_policy_groups           pogr
          ON grac.grac_id = pogr.grac_id
         AND p_date BETWEEN pogr.effective_start_date 
                        AND pogr.effective_end_date
        LEFT OUTER JOIN
             ohi_policies                poli
          ON pogr.poli_id = poli.poli_id
        LEFT OUTER JOIN
             ohi_policy_brokers          pobr
          ON poli.poli_id = pobr.poli_id
         AND p_date BETWEEN pobr.effective_start_date 
                        AND pobr.effective_end_date
        LEFT OUTER JOIN
             broker                      brok
          ON pobr.broker_id_no = brok.broker_id_no
        LEFT OUTER JOIN
             ohi_hold_ind                brokhi
          ON brokhi.product_code  IS NULL
         AND brokhi.poep_id       IS NULL
         AND brokhi.inse_code     IS NULL
         AND brokhi.policy_code   IS NULL
         AND brokhi.group_code    IS NULL
         AND brokhi.broker_id_no  = brok.broker_id_no
         AND brokhi.company_id_no IS NULL
         AND p_date BETWEEN brokhi.effective_start_date 
                        AND brokhi.effective_end_date
        INNER JOIN
             company                     comp
          ON nvl(brok.company_id_no, pobr.company_id_no) = comp.company_id_no
        LEFT OUTER JOIN
             ohi_hold_ind                comphi
          ON comphi.product_code  IS NULL
         AND comphi.poep_id       IS NULL
         AND comphi.inse_code     IS NULL
         AND comphi.policy_code   IS NULL
         AND comphi.group_code    IS NULL
         AND comphi.broker_id_no  IS NULL
         AND comphi.company_id_no = comp.company_id_no
         AND p_date BETWEEN comphi.effective_start_date 
                        AND comphi.effective_end_date
       WHERE grac.group_code = p_group
         AND p_date BETWEEN grac.effective_start_date 
                        AND grac.effective_end_date
         AND ROWNUM = 1;
      IF p_hold_ind = 'Y' THEN
        p_return_msg             := 'Success: Date ' || p_date || ', Group ' || p_group || ', Product ' || p_product
                                 || ' returned Hold Ind - ' || p_hold_ind || ' '
                                 || l_return_tmp;
        RETURN;
      END IF;
      RAISE NO_DATA_FOUND;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN 
        p_return_msg             := 'Failure: Date ' || p_date || ', Group ' || p_group || ', Product ' || p_product
                                 || ' could not return any Hold Indicator';
        RETURN;
    END;
  END IF; -- Populated Group and Product Code Check

  IF  -- Populated Group Code Check
         p_group IS NOT NULL THEN
    BEGIN
      SELECT 
             CASE WHEN grachi.hold_ind = 'Y' THEN grachi.hold_ind
                  WHEN brokhi.hold_ind = 'Y' THEN brokhi.hold_ind
                  WHEN comphi.hold_ind = 'Y' THEN comphi.hold_ind
                  ELSE NULL
             END
            ,CASE WHEN grachi.hold_ind = 'Y' THEN grachi.hold_reason
                  WHEN brokhi.hold_ind = 'Y' THEN brokhi.hold_reason
                  WHEN comphi.hold_ind = 'Y' THEN comphi.hold_reason
                  ELSE NULL
             END
            ,CASE WHEN grachi.hold_ind = 'Y' THEN NULL
                  WHEN brokhi.hold_ind = 'Y' THEN 'derived from Broker ID ' || brokhi.broker_id_no
                  WHEN comphi.hold_ind = 'Y' THEN 'derived from Company ID ' || comphi.company_id_no
                  ELSE NULL
             END
        INTO p_hold_ind
            ,p_hold_reason
            ,l_return_tmp
        FROM 
             ohi_groups                  grac
        LEFT OUTER JOIN
             ohi_hold_ind                grachi
          ON grachi.product_code  IS NULL
         AND grachi.poep_id       IS NULL
         AND grachi.inse_code     IS NULL
         AND grachi.policy_code   IS NULL
         AND grachi.group_code    = grac.group_code
         AND grachi.broker_id_no  IS NULL
         AND grachi.company_id_no IS NULL
         AND p_date BETWEEN grachi.effective_start_date 
                        AND grachi.effective_end_date
        INNER JOIN
             ohi_policy_groups           pogr
          ON grac.grac_id = pogr.grac_id
         AND p_date BETWEEN pogr.effective_start_date 
                        AND pogr.effective_end_date
        LEFT OUTER JOIN
             ohi_policies                poli
          ON pogr.poli_id = poli.poli_id
        LEFT OUTER JOIN
             ohi_policy_brokers          pobr
          ON poli.poli_id = pobr.poli_id
         AND p_date BETWEEN pobr.effective_start_date 
                        AND pobr.effective_end_date
        LEFT OUTER JOIN
             broker                      brok
          ON pobr.broker_id_no = brok.broker_id_no
        LEFT OUTER JOIN
             ohi_hold_ind                brokhi
          ON brokhi.product_code  IS NULL
         AND brokhi.poep_id       IS NULL
         AND brokhi.inse_code     IS NULL
         AND brokhi.policy_code   IS NULL
         AND brokhi.group_code    IS NULL
         AND brokhi.broker_id_no  = brok.broker_id_no
         AND brokhi.company_id_no IS NULL
         AND p_date BETWEEN brokhi.effective_start_date 
                        AND brokhi.effective_end_date
        INNER JOIN
             company                     comp
          ON nvl(brok.company_id_no, pobr.company_id_no) = comp.company_id_no
        LEFT OUTER JOIN
             ohi_hold_ind                comphi
          ON comphi.product_code  IS NULL
         AND comphi.poep_id       IS NULL
         AND comphi.inse_code     IS NULL
         AND comphi.policy_code   IS NULL
         AND comphi.group_code    IS NULL
         AND comphi.broker_id_no  IS NULL
         AND comphi.company_id_no = comp.company_id_no
         AND p_date BETWEEN comphi.effective_start_date 
                        AND comphi.effective_end_date
       WHERE grac.group_code = p_group
         AND p_date BETWEEN grac.effective_start_date 
                        AND grac.effective_end_date
         AND ROWNUM = 1;
      IF p_hold_ind = 'Y' THEN
        p_return_msg             := 'Success: Date ' || p_date || ', Group ' || p_group
                                 || ' returned Hold Ind - ' || p_hold_ind || ' '
                                 || l_return_tmp;
        RETURN;
      END IF;
      RAISE NO_DATA_FOUND;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN 
        p_return_msg             := 'Failure: Date ' || p_date || ', Group ' || p_group
                                 || ' could not return any Hold Indicator';
        RETURN;
    END;
  END IF; -- Populated Group Code Check

  IF  -- Populated  Broker ID Check
         p_broker IS NOT NULL THEN
    BEGIN
      SELECT 
             CASE WHEN brokhi.hold_ind = 'Y' THEN brokhi.hold_ind
                  WHEN comphi.hold_ind = 'Y' THEN comphi.hold_ind
                  ELSE NULL
             END
            ,CASE WHEN brokhi.hold_ind = 'Y' THEN brokhi.hold_reason
                  WHEN comphi.hold_ind = 'Y' THEN comphi.hold_reason
                  ELSE NULL
             END
            ,CASE WHEN brokhi.hold_ind = 'Y' THEN NULL
                  WHEN comphi.hold_ind = 'Y' THEN 'derived from Company ID ' || comphi.company_id_no
                  ELSE NULL
             END
        INTO p_hold_ind
            ,p_hold_reason
            ,l_return_tmp
        FROM 
             broker                      brok
        LEFT OUTER JOIN
             ohi_hold_ind                brokhi
          ON brokhi.product_code  IS NULL
         AND brokhi.poep_id       IS NULL
         AND brokhi.inse_code     IS NULL
         AND brokhi.policy_code   IS NULL
         AND brokhi.group_code    IS NULL
         AND brokhi.broker_id_no  = brok.broker_id_no
         AND brokhi.company_id_no IS NULL
         AND p_date BETWEEN brokhi.effective_start_date 
                        AND brokhi.effective_end_date
        INNER JOIN
             company                     comp
          ON brok.company_id_no = comp.company_id_no
        LEFT OUTER JOIN
             ohi_hold_ind                comphi
          ON comphi.product_code  IS NULL
         AND comphi.poep_id       IS NULL
         AND comphi.inse_code     IS NULL
         AND comphi.policy_code   IS NULL
         AND comphi.group_code    IS NULL
         AND comphi.broker_id_no  IS NULL
         AND comphi.company_id_no = comp.company_id_no
         AND p_date BETWEEN comphi.effective_start_date 
                        AND comphi.effective_end_date
       WHERE brok.broker_id_no = p_broker;
      IF p_hold_ind = 'Y' THEN
        p_return_msg             := 'Success: Date ' || p_date || ', Broker ' || p_broker
                                 || ' returned Hold Ind - ' || p_hold_ind || ' '
                                 || l_return_tmp;
        RETURN;
      END IF;
      RAISE NO_DATA_FOUND;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN 
        p_return_msg             := 'Failure: Date ' || p_date || ', Broker ' || p_broker
                                 || ' could not return any Hold Indicator';
        RETURN;
    END;
  END IF; -- Populated Broker ID Check

  IF  -- Populated  Company ID Check
         p_company IS NOT NULL THEN
    BEGIN
      SELECT 
             CASE WHEN comphi.hold_ind = 'Y' THEN comphi.hold_ind
                  ELSE NULL
             END
            ,CASE WHEN comphi.hold_ind = 'Y' THEN comphi.hold_reason
                  ELSE NULL
             END
            ,CASE WHEN comphi.hold_ind = 'Y' THEN NULL
                  ELSE NULL
             END
        INTO p_hold_ind
            ,p_hold_reason
            ,l_return_tmp
        FROM 
             company                     comp
        LEFT OUTER JOIN
             ohi_hold_ind                comphi
          ON comphi.product_code  IS NULL
         AND comphi.poep_id       IS NULL
         AND comphi.inse_code     IS NULL
         AND comphi.policy_code   IS NULL
         AND comphi.group_code    IS NULL
         AND comphi.broker_id_no  IS NULL
         AND comphi.company_id_no = comp.company_id_no
         AND p_date BETWEEN comphi.effective_start_date 
                        AND comphi.effective_end_date
       WHERE comp.company_id_no = p_company;
      IF p_hold_ind = 'Y' THEN
        p_return_msg             := 'Success: Date ' || p_date || ', Company ' || p_company
                                 || ' returned Hold Ind - ' || p_hold_ind || ' '
                                 || l_return_tmp;
        RETURN;
      END IF;
      RAISE NO_DATA_FOUND;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN 
        p_return_msg             := 'Failure: Date ' || p_date || ', Company ' || p_company
                                 || ' could not return any Hold Indicator';
        RETURN;
    END;
  END IF; -- Populated Company ID Check

  p_return_msg := 'ERROR: Nothing Done for Parameter set.';

EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1422 THEN
      p_return_msg := 'ERROR: Data Integrity Error. More than one record retrieved for Parameters.';
    ELSE
      p_return_msg := 'ERROR: Get_Hold_Ind failed with exception error: ' || sqlerrm;
      logger.log_error('Unhandled Exception', l_scope, null, l_params);
    END IF;

END get_hold_ind;

/**********************************************************************************************************************/

PROCEDURE get_poep_id          (p_date           IN  DATE     DEFAULT SYSDATE
                               ,p_product        IN  VARCHAR2 DEFAULT NULL
                               ,p_policy         IN  VARCHAR2 DEFAULT NULL
                               ,p_person         IN  VARCHAR2 DEFAULT NULL
                               ,p_poep           OUT ohi_enrollment_products.poep_id%type
                               ,p_return_msg     OUT VARCHAR2)

IS

  gc_scope_prefix       CONSTANT VARCHAR2(31)           
                                 := lower($$PLSQL_UNIT) || '.';
  l_scope                        logger_logs.scope%TYPE 
                                 := 'Commissions: ' || gc_scope_prefix;
  l_params                       logger.tab_param;
  lv_poep_id                     ohi_enrollment_products.poep_id%TYPE;

BEGIN
  p_poep                         := NULL;
  p_return_msg                   := NULL;

  BEGIN -- Policy Person Check
    IF p_policy IS NULL AND p_person IS NULL THEN
      raise_application_error(-20010,'Policy or Person MUST be specified (compulsory fields).');
    END IF;
  END;  -- Policy Person Check

  BEGIN -- Get POEP Id Check
    lv_poep_id := NULL;
    SELECT MAX(poep_id) INTO lv_poep_id
      FROM ohi_enrollment_products poep
      JOIN ohi_products            enpr
        ON enpr.enpr_id = poep.enpr_id
      JOIN ohi_policy_enrollments  poen
        ON poen.poen_id = poep.poen_id
      JOIN ohi_insured_entities    inse
        ON inse.inse_id = poen.inse_id
      JOIN ohi_policies            poli
        ON poli.poli_id = poen.poli_id
     WHERE enpr.product_code = nvl(p_product, enpr.product_code)
       AND poli.policy_code  = nvl(p_policy,  poli.policy_code)
       AND inse.inse_code    = nvl(p_person,  inse.inse_code)
       AND p_date between poep.effective_start_date and poep.effective_end_date;
  END;  -- Get POEP Id Check
  IF lv_poep_id > 0 THEN
    p_poep               := lv_poep_id;
    p_return_msg         := 'SUCCESS: POEP Id ' || lv_poep_id || ' returned from Date (' || p_date ||
                            '), Product (' || p_product || '), Policy (' || p_policy || 
                            ') and Person (' || p_person || ')';
    RETURN;
  END IF;

  p_return_msg := 'ERROR: Nothing Done for Parameter set.';

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('ERROR: Date (' || p_date || '), Product (' || p_product || 
                         '), Policy (' || p_policy || ') and Person (' || p_person || ') returned no data');
    p_return_msg := 'ERROR: Date (' || p_date || '), Product (' || p_product || 
                    '), Policy (' || p_policy || ') and Person (' || p_person || ') returned no data';
  WHEN OTHERS THEN
    IF SQLCODE = -20010 THEN
      dbms_output.put_line('Policy or Person MUST be specified (compulsory fields).');
      p_return_msg := 'Policy or Person MUST be specified (compulsory fields).';
    END IF;

END get_poep_id;

/**********************************************************************************************************************/

PROCEDURE get_comp_template    (p_company        IN  NUMBER   DEFAULT NULL
                               ,p_date           IN  DATE     DEFAULT SYSDATE
                               ,p_template       OUT VARCHAR2
                               ,p_return_msg     OUT VARCHAR2)

IS

BEGIN
  p_template    := NULL;
  p_return_msg  := NULL;
  SELECT
         ctt.company_table_type_desc
    INTO
         p_template
    FROM company comp
    JOIN company_table ct
      ON ct.company_table_desc = 'Corr Template'
     AND p_date BETWEEN ct.effective_start_date AND ct.effective_end_date
    JOIN company_function cf
      ON cf.company_table_id_no = ct.company_table_id_no
     AND cf.company_id_no = comp.company_id_no
     AND p_date BETWEEN cf.effective_start_date AND cf.effective_end_date
    JOIN COMPANY_TABLE_TYPE ctt
      ON ctt.company_table_id_no = ct.company_table_id_no
     AND ctt.company_table_type_id_no = cf.company_table_type_id_no
     AND p_date BETWEEN ctt.effective_start_date AND ctt.effective_end_date
   WHERE comp.company_id_no = p_company;
  IF p_template IS NOT NULL THEN
    p_return_msg         := 'SUCCESS: Template ' || p_template || ' returned from Date (' || p_date ||
                            ') and Company (' || p_company || ')';
    RETURN;
  END IF;
  p_return_msg := 'ERROR: Nothing Returned for Date (' || p_date ||
                            ') and Company (' || p_company || ')';

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('ERROR: Date (' || p_date || '), and Company (' || p_company || ') returned no data');
    p_return_msg := 'ERROR: Date (' || p_date || '), and Company (' || p_company || ') returned no data';
  WHEN TOO_MANY_ROWS THEN
    dbms_output.put_line('ERROR: Date (' || p_date || '), and Company (' || p_company || ') returned more than one record');
    p_return_msg := 'ERROR: Date (' || p_date || '), and Company (' || p_company || ') returned more than one record';
  WHEN OTHERS THEN
    dbms_output.put_line('ERROR: Date (' || p_date || '), and Company (' || p_company || ') returned an unexpected error: ' || sqlerrm);
    p_return_msg := 'ERROR: Date (' || p_date || '), and Company (' || p_company || ') returned an unexpected error: ' || sqlerrm;

END get_comp_template;

/**********************************************************************************************************************/
/* 1.0 start */
PROCEDURE create_job(p_job_name    IN VARCHAR2 
                     ,p_job_type    IN VARCHAR2
                     ,p_job_action  IN VARCHAR2 -- the actual call i.e. pkg.proc
                     ,p_start_date  IN DATE
                     ,p_no_arguments IN NUMBER
                     ,p_comments    IN VARCHAR2 -- any additional comments
                   ) IS

    l_job_name VARCHAR2(100) DEFAULT NULL;    
    gc_scope_prefix       CONSTANT VARCHAR2(31)           
                                 := lower($$PLSQL_UNIT) || '.';
    l_scope                        logger_logs.scope%TYPE 
                                 := 'Commissions: ' || gc_scope_prefix;

BEGIN
   --g_job_id           := lhhcom.commissions_job_id.nextval;

   dbms_session.set_identifier(p_job_name);
   logger.set_level('DEBUG',sys_context('userenv','client_identifier'));
 -- check if the job already exists - if so drop the job

   BEGIN
     SELECT 'X' INTO l_job_name FROM all_scheduler_jobs where UPPER(JOB_NAME) = UPPER(p_job_name);

     drop_job(l_job_name); 


   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        null; --acceptable error
     WHEN OTHERS        THEN
       logger.log_error('Unexpected error occurred in if job exists '||gc_scope_prefix||SQLERRM);
   END;

   logger.log_information('job arguments passed '||p_job_action);

  IF p_no_arguments = 0 THEN
     DBMS_SCHEDULER.CREATE_JOB (
       job_name           =>  p_job_name,
       job_type           =>  p_job_type, --'STORED_PROCEDURE',
     --  number_of_arguments => p_no_arguments,
       job_action         =>  p_job_action, 
      -- start_date         =>  SYSDATE + 10/(24*60*60),--p_start_date,
       auto_drop          =>  TRUE,
      -- job_class          =>  p_job_class,
       comments           =>  p_comments);
  ELSE
    DBMS_SCHEDULER.CREATE_JOB (
       job_name           =>  p_job_name,
       job_type           =>  p_job_type, --'STORED_PROCEDURE',
       number_of_arguments => p_no_arguments,
       job_action         =>  p_job_action, 
     --  start_date         =>  SYSDATE + 10/(24*60*60), --p_start_date,
       auto_drop          =>  TRUE,
      -- job_class          =>  p_job_class,
       comments           =>  p_comments);
   END IF;    
    COMMIT;   

    logger.unset_client_level(p_client_id => p_job_name);
EXCEPTION
  WHEN OTHERS THEN
      logger.log_error('Unexpected error occurred in '||gc_scope_prefix||SQLERRM);
      logger.unset_client_level(p_client_id => p_job_name);
END create_job;


PROCEDURE add_job_arguments(
                      p_job_name            IN VARCHAR2 
                     ,p_argument_position   IN NUMBER
                     ,p_argument_char       IN VARCHAR2 DEFAULT NULL
                     ,p_argument_num        IN NUMBER   DEFAULT NULL
                     ,p_argument_date       IN DATE     DEFAULT NULL
                    ) IS

      gc_scope_prefix       CONSTANT VARCHAR2(31)           
                                 := lower($$PLSQL_UNIT) || '.';
      l_scope                        logger_logs.scope%TYPE 
                                 := 'Commissions: ' || gc_scope_prefix;



BEGIN

 --  g_job_id           := lhhcom.commissions_job_id.nextval;

   dbms_session.set_identifier(p_job_name);
   logger.set_level('DEBUG',sys_context('userenv','client_identifier'));
   logger.log_information(' p_job_name         '||p_job_name);
   logger.log_information(' p_argument_position'||p_argument_position  );
   logger.log_information(' p_argument_char    '||p_argument_char   );
   logger.log_information(' p_argument_num     '||p_argument_num  );
   logger.log_information(' p_argument_date    '||p_argument_date  );

    IF p_argument_char IS NOT NULL THEN


        DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE (
           job_name                => p_job_name,
           argument_position       => p_argument_position,
           argument_value          => p_argument_char);

    ELSIF p_argument_num IS NOT NULL THEN        

          DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE (
           job_name                => p_job_name,
           argument_position       => p_argument_position,
           argument_value          => p_argument_num);

    ELSIF p_argument_date IS NOT NULL THEN       

          DBMS_SCHEDULER.SET_JOB_ANYDATA_VALUE (
           job_name                => p_job_name,
           argument_position       => p_argument_position,
           argument_value          => SYS.ANYDATA.convertDate(p_argument_date)
           );

    ELSE
        DBMS_SCHEDULER.SET_JOB_ANYDATA_VALUE (
           job_name                => p_job_name,
           argument_position       => p_argument_position,
           argument_value          => ANYDATA.CONVERTINTERVALYM(NULL));

    END IF;
     logger.unset_client_level(p_client_id => p_job_name);       
EXCEPTION
   WHEN OTHERS THEN
     logger.log_error('Unexpected error occurred in '||gc_scope_prefix||SQLERRM);
     logger.unset_client_level(p_client_id => p_job_name);


END add_job_arguments;

PROCEDURE add_job_arguments_name(
                      p_job_name            IN VARCHAR2 
                     ,p_argument_name       IN VARCHAR2
                     ,p_argument_char       IN VARCHAR2 DEFAULT NULL
                     ,p_argument_num        IN NUMBER DEFAULT NULL
                     ,p_argument_date       IN DATE   DEFAULT NULL
                    ) IS

      gc_scope_prefix       CONSTANT VARCHAR2(31)           
                                 := lower($$PLSQL_UNIT) || '.';
      l_scope                        logger_logs.scope%TYPE 
                                 := 'Commissions: ' || gc_scope_prefix;



BEGIN

 --  g_job_id           := lhhcom.commissions_job_id.nextval;

   dbms_session.set_identifier(p_job_name);
   logger.set_level('DEBUG',sys_context('userenv','client_identifier'));
   logger.log_information(' p_job_name         '||p_job_name);
   logger.log_information(' p_argument_position'||p_argument_name  );
   logger.log_information(' p_argument_char    '||p_argument_char   );
   logger.log_information(' p_argument_num     '||p_argument_num  );
   logger.log_information(' p_argument_date    '||p_argument_date  );

    IF p_argument_char IS NOT NULL THEN


        DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE (
           job_name                => p_job_name,
           argument_name           => p_argument_name,
           argument_value          => p_argument_char);

    ELSIF p_argument_num IS NOT NULL THEN        

          DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE (
           job_name                => p_job_name,
           argument_name           => p_argument_name,
           argument_value          => p_argument_num);

    ELSIF p_argument_date IS NOT NULL THEN       

          DBMS_SCHEDULER.SET_JOB_ANYDATA_VALUE (
           job_name                => p_job_name,
           argument_name           => p_argument_name,
           argument_value          => SYS.ANYDATA.convertDate(p_argument_date)
           );

    ELSE
       NULL;
    END IF;
     logger.unset_client_level(p_client_id => p_job_name);       
EXCEPTION
   WHEN OTHERS THEN
     logger.log_error('Unexpected error occurred in '||gc_scope_prefix||SQLERRM);
     logger.unset_client_level(p_client_id => p_job_name);


END add_job_arguments_name;

PROCEDURE enable_job(p_job_name IN VARCHAR2) IS
    gc_scope_prefix       CONSTANT VARCHAR2(31)           
                                 := lower($$PLSQL_UNIT) || '.';
    l_scope                        logger_logs.scope%TYPE 
                                 := 'Commissions: ' || gc_scope_prefix;
BEGIN
    --g_job_id           := lhhcom.commissions_job_id.nextval;

   dbms_session.set_identifier(p_job_name);
   logger.set_level('DEBUG',sys_context('userenv','client_identifier'));
   COMMIT;
   dbms_scheduler.enable(p_job_name);


   --ENABLE THE JOB AND ADD BOTH A SUCCESS AND FAILURE NOTIFICATION PROCESS
   -- THE ADF SCREEN WILL AUTOREFRESH
    /*DBMS_SCHEDULER.add_job_email_notification (
    job_name      => p_job_name
    ,recipients   => 'tanya.percy@libertyhealth.net' --commissions@libertyhealth.net
    ,subject      => p_job_name||'-.%JOB_NAME%-%EVENT_TYPE%-@%EVENT_TIMESTAMP%'
    ,events       => 'JOB_FAILED'
    );

     DBMS_SCHEDULER.add_job_email_notification (
    job_name      => p_job_name
    ,recipients   => 'tanya.percy@libertyhealth.net' -- commissions@libertyhealth.net
    ,subject      => p_job_name||'-.%JOB_NAME%-%EVENT_TYPE%-@%EVENT_TIMESTAMP%'
    ,events       => 'JOB_SUCCEEDED'
    );*/
    logger.unset_client_level(p_client_id => p_job_name); 
    COMMIT;
EXCEPTION
   WHEN OTHERS THEN
     logger.log_error('Unexpected error occurred in '||gc_scope_prefix||SQLERRM);
     logger.unset_client_level(p_client_id => p_job_name);

END enable_job;

PROCEDURE drop_job(p_job_name IN VARCHAR2) IS


BEGIN

 DBMS_SCHEDULER.DROP_JOB (p_job_name);
 COMMIT;
EXCEPTION
  WHEN OTHERS THEN
     NULL;

END drop_job;
/* 1.0 end*/

PROCEDURE run_job (p_job_name IN VARCHAR2) IS


BEGIN

 dbms_scheduler.run_job(
                        JOB_NAME => p_job_name,
                        USE_CURRENT_SESSION => FALSE
                        );

EXCEPTION
 WHEN OTHERS THEN
     null;
END run_job;

PROCEDURE get_file(p_file_name IN VARCHAR2, p_output OUT BLOB) IS

  l_directory              VARCHAR2(200) DEFAULT 'LOGDATA';

BEGIN

  --SELECT directory_path INTO l_directory FROM ALL_DIRECTORIES WHERE DIRECTORY_NAME = 'LOGDATA';


  read_in_zipfle_prc(p_file_name, l_directory, p_output);

EXCEPTION
 WHEN OTHERS THEN
     null;
END get_file;

/* start 1.2 */

PROCEDURE call_api IS

   utl_req         UTL_HTTP.req;
   utl_resp        UTL_HTTP.resp;

   l_text          VARCHAR2(32766);
   l_resp_line     CLOB;     
   l_username      VARCHAR2(30);
   l_password      VARCHAR2(30);

BEGIN

        commissions_pkg.write_to_file(  g_log_file_name,'start of calling the WSO2 process '||g_url);    
        utl_http.set_transfer_timeout(60);
        utl_http.set_wallet('file:/export/home/oracle/wallet', NULL); 

        IF l_username IS NOT NULL AND l_password IS NOT NULL THEN
            UTL_HTTP.set_authentication(utl_req, l_username, l_password);
        END IF;

        utl_req    := utl_http.begin_request(g_url, 'GET', 'HTTP/1.1');

        utl_resp   := utl_http.get_response(utl_req);


        BEGIN
            <<loop_resp>>
            LOOP

                utl_http.read_line(utl_resp, l_text, true);           
                l_resp_line        := l_resp_line || l_text;

            END LOOP;
            commissions_pkg.write_to_file(  g_log_file_name,'Response from the wso2 process is '||l_resp_line); 
            dbms_output.put_line('WS_SOAP_DOCM_PKG.HTTP_POST_XML_FNC - end of parsing response loop');

            utl_http.end_response(utl_resp);


           dbms_output.put_line('WS_SOAP_DOCM_PKG.HTTP_POST_XML_FNC - done');

        exception
            WHEN utl_http.transfer_timeout THEN
                  DBMS_OUTPUT.put_line('Timeout');
              dbms_output.put_line('WS_SOAP_DOCM_PKG.HTTP_POST_XML_FNC - err :' || utl_http.get_detailed_sqlcode || ' - ' ||
                             utl_http.get_detailed_sqlerrm );
                   commit;
            WHEN utl_http.end_of_body then
                dbms_output.put_line('WS_SOAP_DOCM_PKG.HTTP_POST_XML_FNC - ERROR - utl_http.end_of_body');
                utl_http.end_response(utl_resp);
                 commit;
            WHEN others then
                dbms_output.put_line('WS_SOAP_DOCM_PKG.HTTP_POST_XML_FNC - ERROR - ' || sqlerrm);
                dbms_output.put_line('WS_SOAP_DOCM_PKG.HTTP_POST_XML_FNC -err_other:' || utl_http.get_detailed_sqlcode || utl_http.get_detailed_sqlerrm);
                commit;
                raise;
        END loop_resp;


     -- utl_resp := UTL_HTTP.get_response (utl_req);

      utl_http.end_response(utl_resp);


EXCEPTION
  WHEN UTL_HTTP.TOO_MANY_REQUESTS THEN
      dbms_output.put_line(' closing the http response ');
      UTL_HTTP.END_RESPONSE(utl_resp); 
  WHEN OTHERS THEN 
     dbms_output.put_line(' error - inside call_api '||sqlerrm);
      UTL_HTTP.END_RESPONSE(utl_resp); 
END;




PROCEDURE clear_processed_entries IS


BEGIN

  DELETE FROM WS_SOAP_INBOUND where process_name NOT IN ( 'FUSION_PAYABLES_INTERFACE','FUSION_ORGANIZATIONS','FUSION_PAYMENTS_RECON','FUSION_BILLING_GROUP');
   dbms_output.put_line(' cleared entries in WS_SOAP_INBOUND table '||sqlerrm);
  COMMIT;


  -- as this is called each time the commissions application is opened it can also be used to control the partial receipts table
  -- for the active flag
  FOR c_rec IN (
  SELECT comms_partial_pk 
    FROM comms_on_partial_receipt
   WHERE TRUNC(effective_end_date) < TRUNC(SYSDATE) ) LOOP

   UPDATE comms_on_partial_receipt
     SET  active_yn        = 'N'
    WHERE comms_partial_pk = c_rec.comms_partial_pk;

  END LOOP; 

   FOR c_rec IN (
  SELECT comms_partial_pk 
    FROM comms_on_partial_receipt
   WHERE TRUNC(effective_end_date) >= TRUNC(SYSDATE) ) LOOP

   UPDATE comms_on_partial_receipt
     SET  active_yn        = 'Y'
    WHERE comms_partial_pk = c_rec.comms_partial_pk
      AND approved_by      IS NOT NULL;

  END LOOP; 

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN

     dbms_output.put_line(' error '||sqlerrm);

END clear_processed_entries;

PROCEDURE mark_processed_entries IS


BEGIN

  UPDATE WS_SOAP_INBOUND SET STATUS = 'Y';
   dbms_output.put_line(' marked all entries as processed WS_SOAP_INBOUND table '||sqlerrm);
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN

     dbms_output.put_line(' error '||sqlerrm);

END mark_processed_entries;

PROCEDURE get_fusion_billing_group
          (
          p_group_code IN VARCHAR2
          ) IS

BEGIN

  DELETE FROM WS_SOAP_INBOUND WHERE PROCESS_NAME = 'FUSION_BILLING_GROUP';

  g_endpoint := get_system_parameter('LB_HEALTH_COMMS','WSO2','SERVER_LINK');

  g_url := g_endpoint||
  '/PublicReportServiceOther?bu=ALL&processName=FUSION_BILLING_GROUP&reportDef=%2FCustom%2FFinancials%2FIntegration%2FAR%2FLiberty_Invoice_Balances_report.xdo&groupCode='||REPLACE(p_group_code,' ','%20')||'&trxNumbers=%27%27&appId=%27%27&receiptId=%27%27';

  call_api;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
      null;
END get_fusion_billing_group;

PROCEDURE fetch_fusion_payments_int(p_log_file_name IN VARCHAR2 DEFAULT NULL) IS
  
  l_session_id     VARCHAR2(200);
  l_slave_id       NUMBER;
  
  l_out_message    VARCHAR2(30000);

BEGIN
-- first remove any left over clobs in the payload table
  DELETE FROM ws_soap_inbound WHERE process_name = 'FUSION_PAYMENTS';
  DELETE FROM ws_soap_inbound WHERE process_name = 'FUSION_PAYMENTS_INTERFACE';
  COMMIT;

  IF p_log_file_name IS NULL THEN
  -- start logging information for the payment run
    SELECT sys_context('userenv','sid') INTO l_session_id     FROM dual;
    SELECT userenv('PID')               INTO l_slave_id       FROM DUAL;
    SELECT SYSDATE                      INTO g_job_start_date FROM dual;
  
  

    g_logger_identifier := get_scheduler_job_id(l_session_id,l_slave_id);

    g_log_file_name    := g_logger_identifier||'.html';
    g_output_file_name := g_logger_identifier||'.csv';
  ELSE
   
    g_log_file_name := p_log_file_name;
    
  END IF;
  
  
    IF p_log_file_name IS NULL THEN
      --open up a log and output file to store the run and output information for reference
        commissions_pkg.create_file(  
                              p_file_name     => g_log_file_name,
                              p_process       => 'Fetching Fusion Payments Interface Information'
                            );
    
        commissions_pkg.create_file(  
                              p_file_name     => g_output_file_name,
                              p_process       => 'Fetching Fusion Payments Interface Information'
                            ); 
    
                              
    END IF;
    
    commissions_pkg.write_to_file(  g_log_file_name,'Calling the web services - Fetching Fusion Payments Interface Information');  
     
    g_endpoint := get_system_parameter('LB_HEALTH_COMMS','WSO2','SERVER_LINK');

     g_url := g_endpoint||
           '/PublicReportServicePay?bu=ALL&processName=FUSION_PAYMENTS_INTERFACE&reportDef=%2FCustom%2FFinancials%2FIntegration%2FPayments%2Fliberty_ap_payments_balances_report.xdo&companyIdNo=%27%27&payFromDate=%27%27&payToDate=%27%27&invNumber=%27%27';
           commissions_pkg.write_to_file(  g_log_file_name,'Calling the web services - url '||g_url); 
           call_api;
           
           COMMIT;
           
       --next check what values differ between Fusion and CSB and fetch the information which is missing
     FOR c_rec IN 
        (SELECT SUPPLIER_NUMBER,
                INVOICE_NUM,
                OPERATING_UNIT_NAME,
                SOURCE,
                LINE_TYPE_LOOKUP_CODE,
                SUM(APPLIED_AMT)  fusion_payment,
                 csb.payment_amt
           FROM ws_soap_inbound t,    
                XMLTABLE('//DATA_DS/G_1' PASSING XMLTYPE(t.payload)    
                COLUMNS     
                SUPPLIER_NUMBER VARCHAR2(150) PATH 'SUPPLIER_NUMBER/text()',    
                INVOICE_NUM         VARCHAR2(150) PATH 'INVOICE_NUM/text()',    
                OPERATING_UNIT_NAME       VARCHAR2(150) PATH 'OPERATING_UNIT_NAME/text()',    
                SOURCE           VARCHAR2(150) PATH 'SOURCE/text()',    
                LINE_TYPE_LOOKUP_CODE   VARCHAR2(150) PATH 'LINE_TYPE_LOOKUP_CODE/text()',
                APPLIED_AMT   VARCHAR2(150) PATH 'APPLIED_AMT/text()'
                ) fusion,
                (SELECT invoice_no, NVL(payment_amt,0) payment_amt
                   FROM invoice
                )  csb
          WHERE PROCESS_NAME = 'FUSION_PAYMENTS_INTERFACE'
            AND LINE_TYPE_LOOKUP_CODE = 'ITEM'
            AND csb.invoice_no = fusion.INVOICE_NUM
          GROUP BY
                 SUPPLIER_NUMBER,
                 INVOICE_NUM,
                 OPERATING_UNIT_NAME,
                 SOURCE,
                 LINE_TYPE_LOOKUP_CODE,
                 csb.payment_amt
         HAVING SUM(APPLIED_AMT) <> csb.payment_amt
      ) LOOP
                 
         g_url := g_endpoint||
           '/PublicReportServicePay?bu='||REPLACE(c_rec.OPERATING_UNIT_NAME,' ','%20')||'&processName=FUSION_PAYMENTS&reportDef=%2FCustom%2FFinancials%2FIntegration%2FPayments%2Fliberty_ap_payments_report.xdo&companyIdNo='||c_rec.supplier_number||'&payFromDate='||TO_CHAR(SYSDATE-7,'MM-DD-YYYY')||'&payToDate='||TO_CHAR(SYSDATE,'MM-DD-YYYY')||'&invNumber='||c_rec.invoice_num;
         --  commissions_pkg.write_to_file(  g_log_file_name,'Calling the web services - url '||g_url); 
           call_api;
       
      END LOOP;                 
      
     
EXCEPTION
  WHEN OTHERS THEN
     
     IF g_log_file_name IS NOT NULL THEN 
      commissions_pkg.write_to_file(  g_log_file_name,'Error in process fusion Payments ');     
      commissions_pkg.write_to_file(  g_log_file_name,SQLERRM);
     END IF;
     
END fetch_fusion_payments_int;


PROCEDURE fetch_fusion_payables_int
                                  (
                                    p_from_date     IN VARCHAR2,
                                    p_to_date       IN VARCHAR2,
                                    p_log_file_name IN VARCHAR2 DEFAULT NULL
                                  ) IS
  
  l_session_id     VARCHAR2(200);
  l_slave_id       NUMBER;

BEGIN
-- first remove any left over clobs in the payload table
  DELETE FROM ws_soap_inbound WHERE process_name = 'FUSION_PAYABLES_INTERFACE';
  COMMIT;

  IF p_log_file_name IS NULL THEN
  -- start logging information for the payment run
    SELECT sys_context('userenv','sid') INTO l_session_id     FROM dual;
    SELECT userenv('PID')               INTO l_slave_id       FROM DUAL;
    SELECT SYSDATE                      INTO g_job_start_date FROM dual;


    g_logger_identifier := get_scheduler_job_id(l_session_id,l_slave_id);

    g_log_file_name    := g_logger_identifier||'.html';
    g_output_file_name := g_logger_identifier||'.csv';
   ELSE
     g_log_file_name := p_log_file_name;
   END IF;
 
   IF p_log_file_name IS NULL THEN
      --open up a log and output file to store the run and output information for reference
    commissions_pkg.create_file(  
                          p_file_name     => g_log_file_name,
                          p_process       => 'Fetching Fusion Payables Interface Information'
                        );

    commissions_pkg.create_file(  
                          p_file_name     => g_output_file_name,
                          p_process       => 'Fetching Fusion Payables Interface Information'
                        ); 
   END IF;
     commissions_pkg.write_to_file(  g_log_file_name,'Calling the web services - Fetching Fusion Payables Interface Information');                        
     g_endpoint := get_system_parameter('LB_HEALTH_COMMS','WSO2','SERVER_LINK');

     g_url := g_endpoint||
           '/PublicReportServicePay?bu=ALL&processName=FUSION_PAYABLES_INTERFACE&reportDef=%2FCustom%2FFinancials%2FIntegration%2FPayments%2FLiberty_ap_interface_recon_report.xdo&companyIdNo=%27%27&payFromDate='||p_from_date||'&payToDate='||p_to_date||'&invNumber=%27%27';
           commissions_pkg.write_to_file(  g_log_file_name,'Calling the web services - url '||g_url); 
           call_api;
           
           COMMIT;
           
   
           
        
EXCEPTION
  WHEN OTHERS THEN
      commissions_pkg.write_to_file(  g_log_file_name,'Error in process fusion Payments ');     
      commissions_pkg.write_to_file(  g_log_file_name,SQLERRM);
  
END fetch_fusion_payables_int;

PROCEDURE process_fusion_payables(p_log_file_name IN VARCHAR2 DEFAULT NULL) IS


BEGIN


  fetch_fusion_payables_int(TO_CHAR(SYSDATE-7,'MM-DD-YYYY'), TO_CHAR(SYSDATE,'MM-DD-YYYY'),p_log_file_name);
   
  --run the payables import process for any invoices in the interface table which have not been processed
  FOR c_Rec in (SELECT DISTINCT
                      bu.organization_name as bu
                    , bu.organization_id business_unit_id 
                    , bu.ledger_id
              from invoice i, 
                   invoice_detail id, 
                   company c, 
                    ( SELECT ORGANIZATION_NAME,
                             LEDGER_ID,
                             LEDGER_NAME,
                             COUNTRY,
                             ORGANIZATION_ID
                        FROM ws_soap_inbound t,    
                              XMLTABLE('//DATA_DS/G_1' PASSING XMLTYPE(t.payload)    
                              COLUMNS     
                              ORGANIZATION_NAME VARCHAR2(150) PATH 'ORGANIZATION_NAME/text()',    
                              LEDGER_ID         VARCHAR2(150) PATH 'LEDGER_ID/text()',    
                              LEDGER_NAME       VARCHAR2(150) PATH 'LEDGER_NAME/text()',    
                              COUNTRY           VARCHAR2(150) PATH 'COUNTRY/text()',    
                              ORGANIZATION_ID   VARCHAR2(150) PATH 'ORGANIZATION_ID/text()')
                         WHERE PROCESS_NAME = 'FUSION_ORGANIZATIONS') bu,
                       (select DISTINCT di.invoice_no, ccs.bu 
                              from invoice di,
                                   comms_calc_snapshot ccs
                              where 1=1
                                AND ccs.invoice_no     = di.invoice_no
                         ) inv,
                         (SELECT INT_STATUS STATUS 
                                ,OPERATING_UNIT BU 
                                ,INVOICE_NUM INVOICE_NUMBER 
                                ,INVOICE_TYPE_LOOKUP_CODE INVOICE_TYPE 
                                ,SUBSTR(INVOICE_DATE,1,10) INVOICE_DATE 
                                ,VENDOR_NUM VENDOR_NUMBER 
                                ,VENDOR_NAME  VENDOR_NAME 
                                ,VENDOR_SITE_CODE VENDOR_SITE 
                                ,INVOICE_AMOUNT INVOICE_AMT 
                                ,INVOICE_CURRENCY_CODE INVOICE_CURRENCY 
                                ,TERMS_NAME TERMS 
                                ,DESCRIPTION DESCRIPTION 
                                ,SUBSTR(CREATION_DTE,1,10)  CREATION_DATE 
                                ,CREATED_BY CREATED_BY 
                           FROM ws_soap_inbound t,     
                                XMLTABLE('//DATA_DS/G_1' PASSING XMLTYPE(t.payload)     
                                      COLUMNS      
                                      INVOICE_NUM                      VARCHAR2(150) PATH 'INVOICE_NUM/text()',     
                                      INVOICE_TYPE_LOOKUP_CODE         VARCHAR2(150) PATH 'INVOICE_TYPE_LOOKUP_CODE/text()',     
                                      INVOICE_DATE                     VARCHAR2(150) PATH 'INVOICE_DATE/text()',     
                                      VENDOR_NUM                       VARCHAR2(150) PATH 'VENDOR_NUM/text()',     
                                      VENDOR_NAME                      VARCHAR2(150) PATH 'VENDOR_NAME/text()', 
                                      VENDOR_SITE_CODE                 VARCHAR2(150) PATH 'VENDOR_SITE_CODE/text()', 
                                      INVOICE_AMOUNT                   VARCHAR2(150) PATH 'INVOICE_AMOUNT/text()', 
                                      INVOICE_CURRENCY_CODE            VARCHAR2(150) PATH 'INVOICE_CURRENCY_CODE/text()', 
                                      TERMS_NAME                       VARCHAR2(150) PATH 'TERMS_NAME/text()', 
                                      DESCRIPTION                      VARCHAR2(150) PATH 'DESCRIPTION/text()', 
                                      CREATION_DTE                     VARCHAR2(150) PATH 'CREATION_DATE/text()', 
                                      CREATED_BY                       VARCHAR2(150) PATH 'CREATED_BY/text()', 
                                      OPERATING_UNIT                   VARCHAR2(150) PATH 'OPERATING_UNIT/text()', 
                                      INT_STATUS                       VARCHAR2(150) PATH 'STATUS/text()') 
                           WHERE PROCESS_NAME                          = 'FUSION_PAYABLES_INTERFACE'
                             AND INT_STATUS                            IS NULL
                    ) inter
              where i.company_id_no                                            = c.company_id_no
                and i.invoice_no                                               = id.invoice_no
                and inv.invoice_no                                             = i.invoice_no
                AND bu.organization_name                                       = inv.bu
                AND i.release_date                                             IS NOT NULL
                AND inter.invoice_number                                       = i.invoice_no
     ) LOOP
    
    
    g_endpoint := get_system_parameter('LB_HEALTH_COMMS','WSO2','SERVER_LINK');

    g_url := g_endpoint||
    '/runFusionPayables?businessUnitId='||c_rec.business_unit_id||'&source=LH_CSB&glId='||c_rec.ledger_id||'';

  call_api;

  COMMIT;
    
    
    END LOOP;



EXCEPTION
  WHEN OTHERS THEN
     NULL;
  
END process_fusion_payables;

PROCEDURE process_fusion_payments(
                                  p_company_id_no IN VARCHAR2 DEFAULT NULL,
                                  p_invoice_no    IN VARCHAR2 DEFAULT NULL,
                                  p_from_date     IN VARCHAR2 DEFAULT NULL,
                                  p_to_date       IN VARCHAR2 DEFAULT NULL
                                 ) IS

  l_session_id     VARCHAR2(200);
  l_slave_id       NUMBER;

BEGIN
  -- first remove any left over clobs in the payload table
  DELETE FROM ws_soap_inbound WHERE process_name = 'FUSION_PAYMENTS_RECON';
  COMMIT;

  -- start logging information for the payment run
    SELECT sys_context('userenv','sid') INTO l_session_id     FROM dual;
    SELECT userenv('PID')               INTO l_slave_id       FROM DUAL;
    SELECT SYSDATE                      INTO g_job_start_date FROM dual;


    g_logger_identifier := get_scheduler_job_id(l_session_id,l_slave_id);

    g_log_file_name    := g_logger_identifier||'.html';
    g_output_file_name := g_logger_identifier||'.csv';


      --open up a log and output file to store the run and output information for reference
    commissions_pkg.create_file(  
                          p_file_name     => g_log_file_name,
                          p_process       => 'Processing Fusion Premiums'
                        );

    commissions_pkg.create_file(  
                          p_file_name     => g_output_file_name,
                          p_process       => 'Processing Fusion Premiums'
                        ); 

     commissions_pkg.write_to_file(  g_log_file_name,'Calling the web services - for Fusion Payment Information');                        
     -- fetch all payment information for all the company id no in the invoices table
     -- the query cannot only be limited to where payment date is null as there may be void information 
     -- also identify the prepayments.
     g_endpoint := get_system_parameter('LB_HEALTH_COMMS','WSO2','SERVER_LINK');

     IF p_invoice_no IS NULL THEN
         FOR c_rec IN (SELECT DISTINCT company_id_no,TO_CHAR(SYSDATE-7,'MM-DD-YYYY') from_date, TO_CHAR(SYSDATE,'MM-DD-YYYY') to_date FROM invoice) LOOP 

           -- set the date check to always check today and -7 days back just in case there were errors and entries were not processed

           g_url := g_endpoint||
           '/PublicReportServicePay?bu=ALL&processName=FUSION_PAYMENTS&reportDef=%2FCustom%2FFinancials%2FIntegration%2FPayments%2Fliberty_ap_payments_report.xdo&companyIdNo='||c_rec.company_id_no||'&payFromDate='||c_rec.from_date||'&payToDate='||c_rec.to_date||'&invNumber=ALL';
           commissions_pkg.write_to_file(  g_log_file_name,'Calling the web services - url '||g_url); 
           call_api;
         END LOOP;
     ELSE

         g_url := g_endpoint||
           '/PublicReportServicePay?bu=ALL&processName=FUSION_PAYMENTS_RECON&reportDef=%2FCustom%2FFinancials%2FIntegration%2FPayments%2Fliberty_ap_payments_report.xdo&companyIdNo='||p_company_id_no||'&payFromDate='||p_from_date||'&payToDate='||p_to_date||'&invNumber='||p_invoice_no;
            commissions_pkg.write_to_file(  g_log_file_name,'Calling the web services - url '||g_url); 
           call_api;
     END IF;
EXCEPTION
  WHEN OTHERS THEN
      commissions_pkg.write_to_file(  g_log_file_name,'Error in process fusion Payments ');     
      commissions_pkg.write_to_file(  g_log_file_name,SQLERRM);
END process_fusion_payments;





--start 1.2
PROCEDURE invoke_rest_service(
                               p_bu IN VARCHAR2 DEFAULT NULL
                             ) IS
--PRAGMA AUTONOMOUS_TRANSACTION;

  l_process        VARCHAR2(1);
  l_billing_completed VARCHAR2(1);

  l_total_paid     NUMBER;
  l_total_credit   NUMBER;
  l_no_orgs        NUMBER;
  l_bu             VARCHAR2(500);
  l_session_id     VARCHAR2(200);
  l_slave_id       NUMBER;
  l_running        VARCHAR2(1);
  
  l_continue       BOOLEAN;
  
  FUNCTION application_exists(
               p_receipt_number            IN VARCHAR2,
               p_receivable_application_id IN NUMBER, 
               p_group_code                IN VARCHAR2, 
               p_invoice_no                IN VARCHAR2, 
               p_business_unit             IN VARCHAR2) RETURN BOOLEAN IS
               
      l_exists VARCHAR2(1);
  
  BEGIN
     
      SELECT DISTINCT 'X'
        INTO l_exists
        FROM comms_payments_received
       WHERE (application_id     = p_receivable_application_id 
         AND finance_receipt_no  = p_receipt_number
         AND finance_invoice_no  = p_invoice_no
         AND group_code          = p_group_code
         );
         
       RETURN TRUE;  
  
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        
        RETURN FALSE;
  
    WHEN OTHERS THEN
        
        RETURN TRUE;
  END application_exists;

BEGIN

   BEGIN
      SELECT 'X' 
        INTO l_running 
        FROM all_scheduler_jobs 
       WHERE job_name = 'FUSION_PREMIUMS_SCHEDULED' 
         AND state = 'RUNNING';
      
      l_continue := FALSE; 
       
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
         l_continue := TRUE;
   END;  
   
   IF l_continue THEN
    SELECT sys_context('userenv','sid') INTO l_session_id     FROM dual;
    SELECT userenv('PID')               INTO l_slave_id       FROM DUAL;
    SELECT SYSDATE                      INTO g_job_start_date FROM dual;


      g_logger_identifier := get_scheduler_job_id(l_session_id,l_slave_id);

      g_log_file_name    := g_logger_identifier||'.html';
      g_output_file_name := g_logger_identifier||'.csv';


      --open up a log and output file to store the run and output information for reference
      commissions_pkg.create_file(  
                          p_file_name     => g_log_file_name,
                          p_process       => 'Processing Fusion Premiums'
                        );

      commissions_pkg.create_file(  
                          p_file_name     => g_output_file_name,
                          p_process       => 'Processing Fusion Premiums'
                        ); 

        commissions_pkg.write_to_file(  g_log_file_name,'Calling the web services');     

   
      
   -- the calls must run in order
   -- 1. get the billing information for all the invoices 
   -- delete the existing billing entry as this is critical for evaluation
   clear_processed_entries;
   -- call the WSO2 Process with parameters

  g_endpoint := get_system_parameter('LB_HEALTH_COMMS','WSO2','SERVER_LINK');

  --call organizations in the instance new bu's have gone live
   g_url := g_endpoint||
  '/PublicReportServiceOther?bu=LH%20Uganda%20BU&processName=FUSION_ORGANIZATIONS&reportDef=%2FCustom%2FFinancials%2FIntegration%2FOrganizations%2FLiberty_Active_Organizations_Report.xdo&groupCode=%27%27&trxNumbers=%27%27&appId=%27%27&receiptId=%27%27';

   call_api;

   COMMIT;
   
   
   --process any outstanding payables invoices
   process_fusion_payables;



  IF p_bu IS NULL OR p_bu = 'null' THEN 
      g_url := g_endpoint||
      '/PublicReportServiceOther?bu=ALL&processName=FUSION_BILLING&reportDef=%2FCustom%2FFinancials%2FIntegration%2FAR%2FLiberty_Invoice_Balances_report.xdo&groupCode=ALL&trxNumbers=%27%27&appId=%27%27&receiptId=%27%27';
  ELSE
      g_url := g_endpoint||
      '/PublicReportServiceOther?bu='||REPLACE(p_bu,' ','%20')||'&processName=FUSION_BILLING&reportDef=%2FCustom%2FFinancials%2FIntegration%2FAR%2FLiberty_Invoice_Balances_report.xdo&groupCode=ALL&trxNumbers=%27%27&appId=%27%27&receiptId=%27%27';

  END IF;

   commissions_pkg.write_to_file(  g_log_file_name,'url is '||g_url);     
  call_api;

  COMMIT;



   -- check that table populated with orgs as critical for the Application if it is populated i.e. more than one row with
   -- process type FUSION_ORGANIZATIONS remove the min date record
   BEGIN
       SELECT COUNT(1)
         INTO l_no_orgs
         FROM ws_soap_inbound
        WHERE process_name = 'FUSION_ORGANIZATIONS';
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        l_no_orgs := 0;
   END;
   IF l_no_orgs > 1 THEN
     DELETE 
       FROM ws_soap_inbound 
      WHERE process_name = 'FUSION_ORGANIZATIONS' AND creation_date = (
                                                                       SELECT MIN(creation_date)
                                                                         FROM ws_soap_inbound
                                                                        WHERE process_name = 'FUSION_ORGANIZATIONS'
                                                                       );
     COMMIT;
   END IF;


  --need to put in logic for partials then call a different 
  FOR c_rec IN ( 
                
  SELECT DISTINCT
          CUSTOMER_NUMBER||INVOICE_NO KEY
          ,ORGANIZATION_NAME bu
          ,CUSTOMER_NUMBER group_code
          ,INVOICE_NO
          ,INVOICE_AMT          
          ,PAYMENT_AMT  
          ,NVL(cpr.total_Receipt_amt,0) selfbuild_total
          ,ADJUSTMENTS         
          ,CREDIT_MEMO        
          ,TAX_AMOUNT           
          ,BALANCE_AMT       
      FROM  (  select group_code||FINANCE_INVOICE_NO key,FINANCE_INVOICE_NO,group_code,NVL(partial_yn,'N') partial_yn, SUM(FINANCE_RECEIPT_AMT) total_Receipt_amt       
          from comms_payments_Received cpr       
          where 1=1 
          and group_code <> 'UGIND' 
          group by FINANCE_INVOICE_NO,group_code,NVL(partial_yn,'N')
          union all 
           select policy_code||FINANCE_INVOICE_NO key,FINANCE_INVOICE_NO,policy_code,NVL(partial_yn,'N') partial_yn, SUM(FINANCE_RECEIPT_AMT) total_Receipt_amt       
          from comms_payments_Received cpr    
          where 1=1 
          and group_code = 'UGIND' 
          group by FINANCE_INVOICE_NO,policy_code,NVL(partial_yn,'N')) cpr, 
          ws_soap_inbound t,    
          XMLTABLE('//DATA_DS/G_1' PASSING XMLTYPE(t.payload)    
          COLUMNS     
          ORGANIZATION_NAME VARCHAR2(150) PATH 'ORGANIZATION_NAME/text()',    
          CUSTOMER_NAME     VARCHAR2(150) PATH 'CUSTOMER_NAME/text()',    
          CUSTOMER_NUMBER   VARCHAR2(150) PATH 'CUSTOMER_NUMBER/text()',    
          INVOICE_TYPE      VARCHAR2(150) PATH 'INVOICE_TYPE/text()',    
          INVOICE_NO        VARCHAR2(150) PATH 'INVOICE_NO/text()',    
          DUE_DATE          DATE          PATH 'DUE_DATE/text()',    
          TRX_DATE          DATE          PATH 'TRX_DATE/text()',    
          GL_DATE           DATE          PATH 'GL_DATE/text()',    
          GL_DATE_CLOSED    DATE          PATH 'GL_DATE_CLOSED/text()',    
          CURRENCY_CODE     VARCHAR2(20)  PATH 'CURRENCY_CODE/text()',    
          CITY              VARCHAR2(200) PATH 'CITY/text()',    
          PAYMENT_SCHEDULE_CLASS         VARCHAR2(100) PATH 'PAYMENT_SCHEDULE_CLASS/text()',    
          INVOICE_AMT       NUMBER        PATH 'INVOICE_AMT/text()',    
          PAYMENT_AMT       NUMBER        PATH 'PAYMENT_AMT/text()',    
          ADJUSTMENTS       NUMBER        PATH  'ADJUSTMENTS/text()',    
          CREDIT_MEMO       NUMBER        PATH 'CREDIT_MEMO/text()',    
          TAX_AMOUNT        NUMBER        PATH 'TAX_AMOUNT/text()',    
          BALANCE_AMT       NUMBER        PATH 'BALANCE_AMT/text()') 
      WHERE t.process_name     = 'FUSION_BILLING'
     -- AND INVOICE_NO = '2276'
       AND cpr.key          = CUSTOMER_NUMBER||INVOICE_NO
       AND t.creation_date    = (SELECT MAX(creation_date) 
                                   FROM ws_soap_inbound 
                                  WHERE process_name = 'FUSION_BILLING' 
                                )
    --   AND cpr.finance_invoice_no = invoice_no 
       and NVL(partial_yn,'N')    = 'N'
       AND ROUND(NVL(cpr.total_Receipt_amt,0)) <> ROUND(PAYMENT_AMT)
     UNION  
     SELECT DISTINCT
          CUSTOMER_NUMBER||INVOICE_NO KEY
          ,ORGANIZATION_NAME bu
          ,CUSTOMER_NUMBER group_code
          ,INVOICE_NO
          ,INVOICE_AMT          
          ,PAYMENT_AMT  
          ,NVL(cpr.total_Receipt_amt,0) selfbuild_total
          ,ADJUSTMENTS         
          ,CREDIT_MEMO        
          ,TAX_AMOUNT           
          ,BALANCE_AMT       
      FROM  (   select group_code||FINANCE_INVOICE_NO key,FINANCE_INVOICE_NO,group_code,NVL(partial_yn,'N') partial_yn, SUM(FINANCE_RECEIPT_AMT) total_Receipt_amt       
          from comms_payments_Received cpr       
          where 1=1 
          and group_code <> 'UGIND' 
          group by FINANCE_INVOICE_NO,group_code,NVL(partial_yn,'N')
          union all 
           select policy_code||FINANCE_INVOICE_NO key,FINANCE_INVOICE_NO,policy_code,NVL(partial_yn,'N') partial_yn, SUM(FINANCE_RECEIPT_AMT) total_Receipt_amt       
          from comms_payments_Received cpr    
          where 1=1 
          and group_code = 'UGIND' 
          group by FINANCE_INVOICE_NO,policy_code,NVL(partial_yn,'N')) cpr, 
          ws_soap_inbound t,    
          XMLTABLE('//DATA_DS/G_1' PASSING XMLTYPE(t.payload)    
          COLUMNS     
          ORGANIZATION_NAME VARCHAR2(150) PATH 'ORGANIZATION_NAME/text()',    
          CUSTOMER_NAME     VARCHAR2(150) PATH 'CUSTOMER_NAME/text()',    
          CUSTOMER_NUMBER   VARCHAR2(150) PATH 'CUSTOMER_NUMBER/text()',    
          INVOICE_TYPE      VARCHAR2(150) PATH 'INVOICE_TYPE/text()',    
          INVOICE_NO        VARCHAR2(150) PATH 'INVOICE_NO/text()',    
          DUE_DATE          DATE          PATH 'DUE_DATE/text()',    
          TRX_DATE          DATE          PATH 'TRX_DATE/text()',    
          GL_DATE           DATE          PATH 'GL_DATE/text()',    
          GL_DATE_CLOSED    DATE          PATH 'GL_DATE_CLOSED/text()',    
          CURRENCY_CODE     VARCHAR2(20)  PATH 'CURRENCY_CODE/text()',    
          CITY              VARCHAR2(200) PATH 'CITY/text()',    
          PAYMENT_SCHEDULE_CLASS         VARCHAR2(100) PATH 'PAYMENT_SCHEDULE_CLASS/text()',    
          INVOICE_AMT       NUMBER        PATH 'INVOICE_AMT/text()',    
          PAYMENT_AMT       NUMBER        PATH 'PAYMENT_AMT/text()',    
          ADJUSTMENTS       NUMBER        PATH  'ADJUSTMENTS/text()',    
          CREDIT_MEMO       NUMBER        PATH 'CREDIT_MEMO/text()',    
          TAX_AMOUNT        NUMBER        PATH 'TAX_AMOUNT/text()',    
          BALANCE_AMT       NUMBER        PATH 'BALANCE_AMT/text()') 
      WHERE t.process_name     = 'FUSION_BILLING'
       --AND INVOICE_NO = '2276'
       AND cpr.key(+)          = CUSTOMER_NUMBER||INVOICE_NO
       AND t.creation_date    = (SELECT MAX(creation_date) 
                                   FROM ws_soap_inbound 
                                  WHERE process_name = 'FUSION_BILLING' 
                                )
       and (
           (ORGANIZATION_NAME = 'LH Uganda BU' AND ROUND(BALANCE_AMT,2) BETWEEN 0.01 AND 1 ) OR -- tolerance check agreed by business
            -- comment this section is for brokers with commission payments allowed on partial receipts
            (customer_number IN (SELECT DISTINCT group_code 
                                  FROM comms_on_partial_receipt 
                                 WHERE trunc(TRX_DATE) BETWEEN trunc(effective_Start_date) AND trunc(effective_end_date)
                                   AND NVL(interface_to_comms,'Y') = 'Y'
                                   AND NVL(active_yn,'N') = 'Y')
                                   AND (payment_amt <> 0 AND balance_amt <> 0) 
            )
            )
          AND ROUND(NVL(cpr.total_Receipt_amt,0)) <> ROUND(PAYMENT_AMT) -- added as some equal so unecessary calls to Fusion   
          UNION 
            SELECT DISTINCT
          CUSTOMER_NUMBER||INVOICE_NO KEY
          ,ORGANIZATION_NAME bu
          ,CUSTOMER_NUMBER group_code
          ,INVOICE_NO
          ,INVOICE_AMT          
          ,PAYMENT_AMT  
          ,NVL(cpr.total_Receipt_amt,0) selfbuild_total
          ,ADJUSTMENTS         
          ,CREDIT_MEMO        
          ,TAX_AMOUNT           
          ,BALANCE_AMT       
      FROM  ( select group_code||FINANCE_INVOICE_NO key,FINANCE_INVOICE_NO,group_code,NVL(partial_yn,'N') partial_yn, SUM(FINANCE_RECEIPT_AMT) total_Receipt_amt       
          from comms_payments_Received cpr       
          where 1=1 
          and group_code <> 'UGIND' 
          group by FINANCE_INVOICE_NO,group_code,NVL(partial_yn,'N')
          union all 
           select policy_code||FINANCE_INVOICE_NO key,FINANCE_INVOICE_NO,policy_code,NVL(partial_yn,'N') partial_yn, SUM(FINANCE_RECEIPT_AMT) total_Receipt_amt       
          from comms_payments_Received cpr    
          where 1=1 
          and group_code = 'UGIND' 
          group by FINANCE_INVOICE_NO,policy_code,NVL(partial_yn,'N')) cpr, 
          ws_soap_inbound t,    
          XMLTABLE('//DATA_DS/G_1' PASSING XMLTYPE(t.payload)    
          COLUMNS     
          ORGANIZATION_NAME VARCHAR2(150) PATH 'ORGANIZATION_NAME/text()',    
          CUSTOMER_NAME     VARCHAR2(150) PATH 'CUSTOMER_NAME/text()',    
          CUSTOMER_NUMBER   VARCHAR2(150) PATH 'CUSTOMER_NUMBER/text()',    
          INVOICE_TYPE      VARCHAR2(150) PATH 'INVOICE_TYPE/text()',    
          INVOICE_NO        VARCHAR2(150) PATH 'INVOICE_NO/text()',    
          DUE_DATE          DATE          PATH 'DUE_DATE/text()',    
          TRX_DATE          DATE          PATH 'TRX_DATE/text()',    
          GL_DATE           DATE          PATH 'GL_DATE/text()',    
          GL_DATE_CLOSED    DATE          PATH 'GL_DATE_CLOSED/text()',    
          CURRENCY_CODE     VARCHAR2(20)  PATH 'CURRENCY_CODE/text()',    
          CITY              VARCHAR2(200) PATH 'CITY/text()',    
          PAYMENT_SCHEDULE_CLASS         VARCHAR2(100) PATH 'PAYMENT_SCHEDULE_CLASS/text()',    
          INVOICE_AMT       NUMBER        PATH 'INVOICE_AMT/text()',    
          PAYMENT_AMT       NUMBER        PATH 'PAYMENT_AMT/text()',    
          ADJUSTMENTS       NUMBER        PATH  'ADJUSTMENTS/text()',    
          CREDIT_MEMO       NUMBER        PATH 'CREDIT_MEMO/text()',    
          TAX_AMOUNT        NUMBER        PATH 'TAX_AMOUNT/text()',    
          BALANCE_AMT       NUMBER        PATH 'BALANCE_AMT/text()') 
      WHERE t.process_name     = 'FUSION_BILLING'
      -- AND INVOICE_NO = '2276'
       AND cpr.key(+)          = CUSTOMER_NUMBER||INVOICE_NO
       AND t.creation_date    = (SELECT MAX(creation_date) 
                                   FROM ws_soap_inbound 
                                  WHERE process_name = 'FUSION_BILLING' 
                                )
       AND (BALANCE_AMT = 0 
       AND (customer_number NOT IN (SELECT DISTINCT group_code 
                                  FROM comms_on_partial_receipt 
                                 WHERE trunc(TRX_DATE) BETWEEN trunc(effective_Start_date) AND trunc(effective_end_date)
                                   AND NVL(interface_to_comms,'Y') = 'Y'
                                   AND NVL(active_yn,'N') = 'Y')
                                  -- AND ((payment_amt <> 0 AND balance_amt <> 0) or credit_memo <> 0)
            )
        AND ROUND(NVL(cpr.total_Receipt_amt,0)) <> ROUND(PAYMENT_AMT)    
       )
  ) LOOP

    
     -- for partials and fully you need to get everything i.e. credits, unapplieds and applieds - need to build logic around that
     -- but then if partial and not on the allowed partial payments do not process through the run. 
     -- for fully applieds if the csb amount = payment amount on Fusion do nothing  

   -- for fully applieds - when should the credit memo come into play? as it will reduce the commission if the credit memo is 
   -- not for the full invoice**********************
     -- get a list of the receipts 
     --1. check that the combination application id, receipt id and receipt number for the combination do not exist on CSB
     --2. if they do, do not reprocess
     --3. also if the total csb paid = total_invoice but the payment amounts do not match there has been a credit memo (clawback) 
     -- for a resigned member get the credit memos for this invoice, group, bu**
     
      -- if the csb amount is different to the paid amount you need to check everything that 
      -- might need to come through -- if it has already been applied i.e. check application id then all ok
 
      commissions_pkg.write_to_file(  g_log_file_name,'About to call receipts for '||c_rec.invoice_no);
      commissions_pkg.write_to_file(  g_log_file_name,'About to call receipts for - csb total is '||ROUND(NVL(c_rec.selfbuild_total,0)));
      commissions_pkg.write_to_file(  g_log_file_name,'About to call receipts for - fusion payment is '||ROUND(NVL(c_rec.payment_amt,0)));

     IF (
         ROUND(NVL(c_rec.selfbuild_total,0)) <> ROUND(NVL(c_rec.payment_amt,0)) 
        ) THEN
        
      --  IF  (ROUND(c_rec.payment_amt) < ROUND(c_rec.selfbuild_total)) THEN
        --? what happens if there was a unapply and a credit - will the credit take care of the difference?
      /*    g_url := g_endpoint||'/PublicReportServiceOther?bu='||REPLACE(c_rec.bu,' ','%20')||'&processName=FUSION_CREDITS&reportDef=%2FCustom%2FFinancials%2FIntegration%2FAR%2FLiberty_Cm_Amounts_report.xdo&groupCode='||c_rec.group_code||'&trxNumbers='||
         c_rec.invoice_no||
         '&appId=%27%27'||
         '&receiptId=%27%27';
         
          call_api;

          COMMIT;*/
      --  END IF;
       
       
         g_url := g_endpoint||'/PublicReportServiceOther?bu='||REPLACE(c_rec.bu,' ','%20')||'&processName=FUSION_RECEIPTS&reportDef=%2FCustom%2FFinancials%2FIntegration%2FAR%2FLiberty_Receipts_information_report.xdo&groupCode='||REPLACE(c_rec.group_code,' ','%20')||'&trxNumbers='||
         c_rec.invoice_no||
         '&appId=%27%27'||
         '&receiptId=%27%27';

         dbms_output.put_line('g_url is '||g_url);
         call_api;

         COMMIT;
       
        FOR c_application in ( 
          SELECT DISTINCT
            RECEIPT_NUMBER,RECEIVABLE_APPLICATION_ID, cash_receipt_id, group_code, invoice_no , BUSINESS_UNIT
          FROM  ws_soap_inbound t,    
              XMLTABLE('//DATA_DS/G_1' PASSING XMLTYPE(t.payload)    
              COLUMNS     
              RECEIVABLE_APPLICATION_ID VARCHAR2(150) PATH 'RECEIVABLE_APPLICATION_ID/text()',    
              CASH_RECEIPT_ID           VARCHAR2(150) PATH 'CASH_RECEIPT_ID/text()',    
              RECEIPT_NUMBER            VARCHAR2(150) PATH 'RECEIPT_NUMBER/text()',
              GROUP_CODE                VARCHAR2(150) PATH 'GROUP_CODE/text()',
              INVOICE_NO                VARCHAR2(150) PATH 'INVOICE_NUMBER/text()',
              BUSINESS_UNIT             VARCHAR2(150) PATH 'BU/text()')
          WHERE t.process_name          = 'FUSION_RECEIPTS'
            AND group_code              = c_rec.group_code
            AND invoice_no              = c_rec.invoice_no
            AND business_unit           = c_rec.bu
            AND RECEIPT_NUMBER          NOT IN (SELECT TO_CHAR(re_receipt_no) re_receipt_no
                                                  FROM COMM_MEDWARE_RECEIPTS_V)
         ) LOOP

             IF application_exists(
               c_application.receipt_number,
               c_application.receivable_application_id, 
               c_application.group_code, 
               c_application.invoice_no , 
               c_application.business_unit) THEN
                
                  NULL;
               
             
             ELSE   
                  -- logic must be around partial payments -- need to call another receipts report and put all entries in for partials
                  -- all payments, credits and unapplieds must be processed for partial payments as needs to balance all the time
                  g_url := g_endpoint||'/PublicReportServiceOther?bu='||
                           REPLACE(c_rec.bu,' ','%20')||
                           '&processName=FUSION_APPLIED&reportDef=%2FCustom%2FFinancials%2FIntegration%2FAR%2FLiberty_Applied_Amounts_report.xdo&groupCode='||
                           REPLACE(c_rec.group_code,' ','%20')||
                           '&trxNumbers='||c_rec.invoice_no||
                           '&appId='||c_application.receivable_application_id||
                           '&receiptId='||c_application.cash_receipt_id;
                       
                       
                       

                 dbms_output.put_line('g_url is '||g_url);
                 
                 call_api;
                 
                 COMMIT;
                 
               END IF;
        
        END LOOP;  
        
        -- Need to check if the net effective is Negative if it is then the credit memos must not be applied
        FOR c_neg IN ( 
         SELECT   C_GROUP_CODE||C_INVOICE_NUMBER key,
                  C_INVOICE_NUMBER,
                  SUM(C_APPLIED_AMOUNT) + 
                  SUM(nvl(total_Receipt_amt,0)) amount_paid
           FROM (   select FINANCE_INVOICE_NO||group_code key,FINANCE_INVOICE_NO,group_code, SUM(FINANCE_RECEIPT_AMT) total_Receipt_amt       
                  from comms_payments_Received cpr       
                  where 1=1 
                  and group_code <> 'UGIND' 
                  group by FINANCE_INVOICE_NO,group_code 
                  union all 
                   select FINANCE_INVOICE_NO||policy_code key,FINANCE_INVOICE_NO,policy_code, SUM(FINANCE_RECEIPT_AMT) total_Receipt_amt       
                  from comms_payments_Received cpr    
                  where 1=1 
                  and group_code = 'UGIND' 
                  group by FINANCE_INVOICE_NO,policy_code) cpr, 
                ws_soap_inbound t,    
                XMLTABLE('//DATA_DS/G_1'      
                PASSING XMLTYPE(t.payload)    
                COLUMNS     
                C_APPLIED_AMOUNT    NUMBER path  'C_APPLIED_AMOUNT/text()',
                C_INVOICE_NUMBER    VARCHAR2(100) path 'C_INVOICE_NUMBER/text()',
                C_GROUP_CODE        VARCHAR2(200) path 'C_GROUP_CODE/text()'
                )  
              WHERE process_name in( 'FUSION_APPLIED','FUSION_CREDITS') -- Include all possible applications for an invoice
            --    AND C_INVOICE_NUMBER = '923'
                AND cpr.key(+)  = C_GROUP_CODE||C_INVOICE_NUMBER
            GROUP BY C_GROUP_CODE||C_INVOICE_NUMBER,C_INVOICE_NUMBER
            HAVING SUM(C_APPLIED_AMOUNT) + 
                  SUM(nvl(total_Receipt_amt,0)) < 0
            ) LOOP
            
             DELETE 
              FROM ws_soap_inbound ws
             WHERE key_value          = c_neg.c_invoice_number
               AND process_name        = 'FUSION_CREDITS'
               AND EXISTS (SELECT C_GROUP_CODE||C_INVOICE_NUMBER key
                             FROM ws_soap_inbound t,    
                                  XMLTABLE('//DATA_DS/G_1'      
                                  PASSING XMLTYPE(t.payload)    
                                  COLUMNS     
                                  C_INVOICE_NUMBER    VARCHAR2(100) path 'C_INVOICE_NUMBER/text()',
                                  C_GROUP_CODE        VARCHAR2(200) path 'C_GROUP_CODE/text()'
                                )  
                            WHERE process_name = 'FUSION_CREDITS' 
                              AND  C_GROUP_CODE||C_INVOICE_NUMBER  = c_neg.key
                        );
           
            
          END LOOP;  
          
          COMMIT;

      END IF;  


   END LOOP;


    -- 2. check the values against those in commissions 
    -- keep history of all processed entries for audit and recon purposes
        -- a) if they already exist and the totals match do nothing
        -- b) if the totals do not match then pass the trx numbers to the applied Receipt report with the BU and Group
        --    as it is specific for the combination
        -- c) when the values are returned ensure that the application id does not exist on self-build in conjunction with
        --    the invoice number, group and business unit
  COMMIT; -- ensure that all entries are committed to the ws_soap_inbound table for processing in the premiums section

  process_fusion_premiums;
  commissions_pkg.write_to_file(  g_log_file_name,'Processed: process_fusion_premiums Successfully  '||SQLERRM);    

  END IF;
EXCEPTION
  WHEN OTHERS THEN
     commissions_pkg.write_to_file(  g_log_file_name,'error in invoke rest services is  '||SQLERRM);  
     COMMIT; -- need to commit as calling WSO2 process does not handle this
END invoke_rest_service;

PROCEDURE process_fusion_premiums  IS


    time_period       varchar2(20);
    medware_rcpt      varchar2(20);


    n                pls_integer := 0;
    substring_length pls_integer := 2000;

    l_amount_paid    NUMBER;
    idx              NUMBER DEFAULT 0;
    l_payment_type   VARCHAR2(200);
    
    l_application_id  NUMBER;

    /*CURSOR c_premiums IS
    SELECT *
      from comms_payments_received;*/


  --    create table comms_fusion_applied_receipts AS
  CURSOR comms_fusion_app_receipts IS
  SELECT   C_GROUP_CODE||C_INVOICE_NUMBER key,
           CUSTOMER_CLASS_CODE  customer_class_code,
           C_CASH_RECEIPT_ID    receipt_id,
           C_CUST_TRX_ID   customer_trx_id,
           C_TRX_LINE_ID   customer_line_id,
           C_APPLICATION_ID application_id,
           C_RECEIPT_NUMBER receipt_no,
           to_date(substr(C_APPLY_DATE,1,10),'YYYY-MM-DD') receipt_date, 
           C_APPLIED_AMOUNT amount_paid,
           C_CUST_ACCOUNT_ID customer_acct_id,
           C_CURRENCY_CODE currency_code,
           C_EXCHANGE_RATE  exchange_rate,
           C_INVOICE_NUMBER  inv_no,
           to_date(substr(C_INVOICE_DATE,1,10),'YYYY-MM-DD')  invoice_date,
           C_OPTION_CODE   enrollment_product,
           C_POLICY_NUMBER policy_code,
          -- C_MEMBER_NUMBER member_no,
           decode(instr(C_OHI_LINE_ID,'#'),0,decode(instr(C_OHI_LINE_ID,'_'),0,C_MEMBER_NUMBER,
                       substr(C_OHI_LINE_ID,1,instr(C_OHI_LINE_ID,'_')-1)),
                       substr(C_OHI_LINE_ID,3,instr(C_OHI_LINE_ID,'_')-3)) member_no,
           C_DEPENDANT_NUMBER  dependant_no,
           to_date(substr(c_contribution_date,1,10),'YYYY-MM-DD')  subs_date,
           C_MEMBER_NAME  member_name,
           C_SOB          sob,
           C_STATUS       status,
           C_BUSINESS_UNIT bu,
           C_GROUP_CODE  group_account,
           C_COUNTRY     country_code,
           C_TYPE    type,
           to_date(substr(GL_DATE,1,10),'YYYY-MM-DD')    gl_date,
           INVOICE_TYPE invoice_type,
           SOURCE_NAME invoice_source,
          SUBSTR(C_OHI_LINE_ID,INSTR(C_OHI_LINE_ID,'_',1,2)+1
                      ,INSTR(C_OHI_LINE_ID,'_',1,3) - INSTR(C_OHI_LINE_ID,'_',1,2)
                       - 1) as payment_type
          ,decode(instr(C_OHI_LINE_ID,'#'),0,decode(instr(C_OHI_LINE_ID,'_'),0,C_MEMBER_NUMBER,
                       substr(C_OHI_LINE_ID,1,instr(C_OHI_LINE_ID,'_')-1)),
                       substr(C_OHI_LINE_ID,3,instr(C_OHI_LINE_ID,'_')-3)) as bulking_criteria,
           tax_recoverable
   FROM ws_soap_inbound t,    
        XMLTABLE('//DATA_DS/G_1'      
        PASSING XMLTYPE(t.payload)    
        COLUMNS     
        CUSTOMER_CLASS_CODE VARCHAR2(150) PATH 'CUSTOMER_CLASS_CODE/text()',
        C_CASH_RECEIPT_ID   NUMBER PATH  'C_CASH_RECEIPT_ID/text()',
        C_CUST_TRX_ID       NUMBER PATH  'C_CUST_TRX_ID/text()',
        C_TRX_LINE_ID       NUMBER PATH  'C_TRX_LINE_ID/text()',
        C_APPLICATION_ID    NUMBER PATH  'C_APPLICATION_ID/text()',
        C_RECEIPT_NUMBER    VARCHAR2(250) PATH 'C_RECEIPT_NUMBER/text()',
        C_APPLY_DATE        VARCHAR2(10)  path 'C_APPLY_DATE/text()',
        C_APPLIED_AMOUNT    NUMBER path  'C_APPLIED_AMOUNT/text()',
        C_CUST_ACCOUNT_ID   NUMBER path  'C_CUST_ACCOUNT_ID/text()',
        C_CURRENCY_CODE     VARCHAR2(100) path 'C_CURRENCY_CODE/text()',
        C_EXCHANGE_RATE     VARCHAR2(100) path 'C_EXCHANGE_RATE/text()',
        C_INVOICE_NUMBER    VARCHAR2(100) path 'C_INVOICE_NUMBER/text()',
        C_INVOICE_DATE      VARCHAR2(10)  path 'C_INVOICE_DATE/text()',
        C_OHI_LINE_ID       VARCHAR2(500) path 'C_OHI_LINE_ID/text()',
        C_OPTION_CODE       VARCHAR2(50)  path 'C_OPTION_CODE/text()',
        C_POLICY_NUMBER     VARCHAR2(250) path 'C_POLICY_NUMBER/text()',
        C_MEMBER_NUMBER     VARCHAR2(150) path 'C_MEMBER_NUMBER/text()',
        C_DEPENDANT_NUMBER  VARCHAR2(150) path 'C_DEPENDANT_NUMBER/text()',
        C_CONTRIBUTION_DATE VARCHAR2(10)  path 'C_CONTRIBUTION_DATE/text()',
        C_MEMBER_NAME       VARCHAR2(300) path 'C_MEMBER_NAME/text()',
        C_SOB               VARCHAR2(100) path 'C_SOB/text()',
        C_STATUS            VARCHAR2(100) path 'C_STATUS/text()',
        C_BUSINESS_UNIT     VARCHAR2(400) path 'C_BUSINESS_UNIT/text()',
        C_GROUP_CODE        VARCHAR2(200) path 'C_GROUP_CODE/text()',
        C_COUNTRY           VARCHAR2(200) path 'C_COUNTRY/text()',
        C_TYPE              VARCHAR2(100) path 'C_TYPE/text()',
        GL_DATE             VARCHAR2(10)  path 'GL_DATE/text()',
        INVOICE_TYPE        VARCHAR2(100) path 'INVOICE_TYPE/text()',
        SOURCE_NAME         VARCHAR2(100) path 'SOURCE_NAME/text()',
        TAX_RECOVERABLE     VARCHAR2(100) path 'TAX_RECOVERABLE/text()'
        )  
      WHERE process_name in( 'FUSION_APPLIED')--,'FUSION_CREDITS') -- Include all possible applications for an invoice
      --  AND C_STATUS <> 'UNAPP'
        AND not exists (SELECT 'X' 
                          FROM comms_payments_received 
                         WHERE application_id     = C_APPLICATION_ID 
                           AND finance_receipt_no = C_RECEIPT_NUMBER
                           AND finance_invoice_no = C_INVOICE_NUMBER
                           AND group_code         = C_GROUP_CODE
                           AND policy_code        = C_POLICY_NUMBER
                           AND person_code        = C_MEMBER_NUMBER
                           );


 --create table comms_levy_information as
 CURSOR comms_levy_information_ohi IS 
 with applied as (
 SELECT distinct 
       applied.key,
       applied.policy_code, 
       applied.subs_date, 
       levy.adjustment, 
       levy.product,
       levy.time_period,
       applied.enrollment_product,
       levy.type,
       levy.sequence,
       levy.percentage,
       levy.start_date,
       levy.end_date
  FROM      
      ( SELECT DISTINCT 
               key,
               enrollment_product,
               policy_code,
               subs_date,
               group_account,
               country_code,
               payment_type
          FROM comms_fusion_app_receipts_gt
          WHERE application_id = l_application_id
           ) applied,
         (
               SELECT DISTINCT PEPB.code product, 
                            null sequence,
                            PSD.code adjustment, 
                            PSD.type, 
                            ptpd.display_name time_period, 
                            ptpd.start_date, ptpd.end_date,
                            NULL percentage
              FROM OHI_POLICIES_VIEWS_OWNER.POL_SCHEDULE_DEFINITIONS_V@POLICIES.LIBERTY.CO.ZA  PSD,
                   OHI_POLICIES_OWNER.POL_ENROLLMENT_PRODUCTS_B@POLICIES.LIBERTY.CO.ZA PEPB
                   JOIN OHI_POLICIES_OWNER.POL_ENROLL_PRODUCT_DETAILS@POLICIES.LIBERTY.CO.ZA PEPD
                   ON PEPD.ENPR_ID = PEPB.ID
                   JOIN OHI_POLICIES_VIEWS_OWNER.POL_TIME_PERIODS_V@POLICIES.LIBERTY.CO.ZA ptpd
                   ON ptpd.enpr_id = pepd.enpr_id   
              WHERE 1=1
                AND PSD.TYPE IN  ('P','G') -- NEED TO CHECK THAT IS CORRECT
                UNION
                select enpr.code
                      ,adjs.sequence
                      ,scde.code adjustment
                      ,scde.type
                      ,tipe.display_name time_period
                      ,tipe.start_date
                      ,tipe.end_date
                      ,NVL(percentage,0) percentage
                  from OHI_POLICIES_VIEWS_OWNER.pol_enrollment_products_v@policies.liberty.co.za enpr
                  join OHI_POLICIES_VIEWS_OWNER.pol_time_periods_v@policies.liberty.co.za tipe
                    on enpr.id = tipe.enpr_id
                  join OHI_POLICIES_VIEWS_OWNER.pol_assigned_adjustments_v@policies.liberty.co.za adjs
                    on     enpr.id = adjs.enpr_id
                       and tipe.start_date = adjs.start_date
                       and tipe.end_date = adjs.end_date
                  join OHI_POLICIES_VIEWS_OWNER. pol_schedule_definitions_v@policies.liberty.co.za scde
                    on adjs.scde_id = scde.id
                  join OHI_POLICIES_VIEWS_OWNER.pol_adjustment_rules_v@policies.liberty.co.za adjr
                    on adjs.scde_id = adjr.scde_id
                  join OHI_POLICIES_VIEWS_OWNER.pol_time_periods_v@policies.liberty.co.za tipe1
                    on     adjr.tipe_id_dtip = tipe1.id
                       and tipe.display_name = tipe1.display_name
                       and tipe.start_date = tipe1.start_date
                       and tipe.end_date = tipe1.end_date
                  join OHI_POLICIES_VIEWS_OWNER.pol_adjustment_values_v@policies.liberty.co.za adjv
                    on adjr.id = adjv.adjr_id 
                 where 
                           scde.type = 'A'
                )levy 
       WHERE 1=1             
         AND applied.enrollment_product = levy.product
         --AND (applied.payment_type = levy.adjustmenT OR levy.percentage is not null)
         AND ((applied.payment_type = levy.adjustmenT) 
          OR (levy.percentage is not null)
          or (applied.payment_type = 'CORE')
          )
        -- AND to_date(substr(applied.subs_date,1,10),'YYYY-MM-DD') between levy.start_date and levy.end_date
        ),
        policies AS ( 
       select  tprd.referencedate, ptpv.start_date, ptpv.END_DATE, ppcp.START_DATE CONTRACT_sTART , PPCP.END_DATE CONTRACT_END,
                              ppcp.reference_date,
                              poli.subs_date subs_date, 
                               flex.key_value,poli.policy_code, 
                     og.group_code,product.product_code,
                     pogr.effective_start_date, pogr.effective_end_date
                         from /*(             select  max(poli.poli_id) poli_id , poli.policy_code, applied.subs_date
                             from OHI_POLICIES_VIEWS_OWNER.POL_POLICY_CONTR_PERIODS_V@POLICIES.LIBERTY.CO.ZA ppcp,
                                  ohi_policies poli,
                                  (SELECT distinct
                                    policy_code,
                                    subs_date  subs_date,
                                    group_account group_code
                               FROM comms_fusion_app_receipts_gt
                              WHERE application_id = l_application_id 
                                    ) applied
                 WHERE  1=1
               --   AND poli.policy_code = '5924014'
                  AND poli.poli_id = ppcp.poli_id -- first check below
                  AND to_date(applied.subs_date,'DD-MON-YYYY') between to_date( ppcp.start_date,'DD-MON-YYYY') AND to_date( ppcp.end_date,'DD-MON-YYYY') 
                  AND poli.policy_code = applied.policy_code
                  group by poli.policy_code, applied.subs_date
                  ) poli*/
                  (select DISTINCT max(poli.poli_id) OVER(PARTITION BY poli.policy_code, applied.subs_date) poli_id , poli.policy_code, applied.subs_date, 
                                           min(applied.subs_date) OVER (PARTITION BY poli.poli_id) contract_start
                             from OHI_POLICIES_VIEWS_OWNER.POL_POLICY_CONTR_PERIODS_V@POLICIES.LIBERTY.CO.ZA ppcp,
                                  ohi_policies poli,
                                  (SELECT distinct
                                    policy_code,
                                    subs_date  subs_date,
                                    group_account group_code
                               FROM comms_fusion_app_receipts_gt
                              WHERE application_id = l_application_id 
                                    ) applied
                 WHERE  1=1
               --   AND poli.policy_code = '5924014'
                  AND poli.poli_id = ppcp.poli_id -- first check below
                  AND to_date(applied.subs_date,'DD-MON-YYYY') between to_date( ppcp.start_date,'DD-MON-YYYY') AND to_date( ppcp.end_date,'DD-MON-YYYY') 
                  AND poli.policy_code = applied.policy_code) poli
                       JOIN OHI_POLICIES_VIEWS_OWNER.POL_POLICY_CONTR_PERIODS_V@POLICIES.LIBERTY.CO.ZA ppcp
                          ON ppcp.poli_id = poli.poli_id
                        JOIN ( SELECT DISTINCT op.product_code, pol.poli_id
                     FROM ohi_policy_enrollments pol 
                        JOIN ohi_enrollment_products poep
                         ON poep.poen_id  = pol.poen_id
                        JOIN ohi_products op
                         ON op.enpr_id = poep.enpr_id) product
                         ON product.poli_id  = poli.poli_id
                        JOIN ohi_policy_groups       pogr
                          ON pogr.poli_id = poli.poli_id 
                        JOIN ohi_groups              og
                          ON og.grac_id = pogr.grac_id
                        LEFT OUTER JOIN OHI_POLICIES_VIEWS_OWNER.POL_TIME_PERIODS_V@POLICIES.LIBERTY.CO.ZA ptpv
                          ON ptpv.grac_id = pogr.grac_id
                        JOIN OHI_POLICIES_VIEWS_OWNER.GRAC_TIMEPERIOD@POLICIES.LIBERTY.CO.ZA tprd 
                         ON tprd.grac_id = pogr.grac_id
                         AND trunc(tprd.referencedate) = trunc(ptpv.start_date)
                        JOIN ohi_policies_views_owner.cod_flex_codes_v@POLICIES.LIBERTY.CO.ZA flex 
                          ON tprd.timeperiod = flex.id
                       -- AND to_date(poli.subs_date,'DD-MON-YYYY') between to_date( ptpv.start_date,'DD-MON-YYYY') AND to_date( ptpv.end_date,'DD-MON-YYYY')
                          AND to_date(poli.contract_start,'DD-MON-YYYY') between to_date( ptpv.start_date,'DD-MON-YYYY') AND to_date( ptpv.end_date,'DD-MON-YYYY')
                          and (
                               to_date(ppcp.end_date,'DD-MON-YYYY') BETWEEN to_date( ptpv.start_date,'DD-MON-YYYY') AND to_date( ptpv.end_date,'DD-MON-YYYY') OR
                               to_date(ppcp.start_date,'DD-MON-YYYY') BETWEEN to_date( ptpv.start_date,'DD-MON-YYYY') AND to_date( ptpv.end_date,'DD-MON-YYYY') 
                               )
                    )
SELECT DISTINCT 
       APPLIED.KEY,
       applied.subs_date, 
       policies.referencedate, 
       policies.key_value time_period,
       policies.policy_code policy_code,
       policies.group_code,
       policies.product_code product,
       applied.adjustment, 
       applied.type,
       applied.sequence,
       applied.percentage
  FROM applied, policies 
 WHERE 1=1
   AND policies.policy_code       = applied.policy_code 
   AND policies.product_code      = applied.enrollment_product
   AND trunc(policies.subs_date)  = trunc(applied.subs_date)
   AND applied.time_period        = policies.key_value;

   /*CURSOR c_premiums IS
   SELECT APPLICATION_ID
         ,RECEIPT_NO
         ,GROUP_ACCOUNT
         ,COUNTRY_CODE
         ,ENROLLMENT_PRODUCT
         ,POLICY_CODE
         ,MEMBER_NO
         ,SUBS_DATE
         ,RECEIPT_DATE
         ,INV_NO
         ,INVOICE_DATE
         --,NVL(tax_Recoverable,0) tax_recoverable
         ,(CASE WHEN tax_Recoverable <> 0 THEN
            ROUND((NVL(amount_paid,0)-NVL(tax_recoverable,0)),2)
           ELSE 
            NVL(tax.tax_Amt,0)
           END
          ) FINANCE_RECEIPT_AMT
         ,CURRENCY_CODE
         ,EXCHANGE_RATE
         ,NULL COMMS_CALC_SNAPSHOT_NO
         ,'N' PROCESSED_IND
         ,NULL PROCESSED_DESC
         ,SYSDATE  LAST_UPDATE_DATETIME
         ,NULL USERNAME
         ,PAYMENT_TYPE 
         ,NULL COMMISSIONABLE
         --,sequence
         --,TIME_PERIOD
    FROM comms_payments_received_GT cpr,
         (SELECT SUM(tax_recoverable) tax_Amt, policy_code||member_no||subs_date||time_period key
            FROM comms_payments_received_GT
           WHERE 1=1
           GROUP BY policy_code||member_no||subs_date||time_period) TAX
   WHERE 1=1
     AND tax.key    = cpr.policy_code||cpr.member_no||cpr.subs_date||cpr.time_period
     AND NOT EXISTS (SELECT 'X' FROM comms_payments_received where application_id = cpr.application_id);*/


    CURSOR c_update_values IS
    select policy_code, member_no, enrollment_product, subs_date,receipt_id, payment_type, 
          sum(amount_paid-tax_recoverable) amount_paid
    from comms_payments_received_gt
    where 1=1
    and amount_paid <> 0
    group by policy_code, member_no, enrollment_product, subs_date,receipt_id,  payment_type
    union
    select cpr.policy_code, cpr.member_no, cpr.enrollment_product, cpr.subs_date,cpr.receipt_id, cpr.payment_type, 
           (total_core.total*percentage)/100 
    from comms_payments_received_gt cpr,
         (SELECT policy_code, member_no, enrollment_product, subs_date,receipt_id, payment_type, SUM(amount_paid-tax_recoverable) total
            FROM comms_payments_received_gt
           WHERE payment_type = 'CORE'
           group by policy_code, member_no, enrollment_product, subs_date,receipt_id,  payment_type ) total_core
    where 1=1
    and amount_paid = 0
    and cpr.policy_code = total_core.policy_code
    and cpr.member_no    = total_core.member_no
    and cpr.enrollment_product = total_core.enrollment_product
    and cpr.subs_date = total_core.subs_date
    and cpr.receipt_id = total_core.receipt_id;

    --still to do - hyphenate CORE-SUPL and CORE-TRAL -- where not from fusion but calculated
    CURSOR c_premiums IS
    SELECT   APPLICATION_ID
            ,GROUP_ACCOUNT
            ,COUNTRY_CODE
            ,ENROLLMENT_PRODUCT
            ,POLICY_CODE
            ,MEMBER_NO
            ,SUBS_DATE
            ,RECEIPT_NO
            ,RECEIPT_DATE
            ,INV_NO
            ,INVOICE_DATE
            ,AMOUNT_PAID
            ,CURRENCY_CODE
            ,EXCHANGE_RATE
            ,NULL comms_calc_snapshot_no
            ,'N' processed_ind
            ,NULL processed_desc
            ,SYSDATE last_update_datetime
            ,'FUSION'
            ,PAYMENT_TYPE
            ,NULL COMMISSIONABLE
            ,BU
            ,'N' PARTIAL_YN
      FROM comms_payments_received_gt cpr
      WHERE 1=1;
       -- AND NOT EXISTS (SELECT 'X' FROM comms_payments_received where application_id = cpr.application_id);

          CURSOR c_levies_final IS
       SELECT  -- get the core levy removed distinct check as performance issue
                       applied.customer_class_code,
                       applied.receipt_id,
                       applied.customer_trx_id,
                       applied.customer_line_id,
                       applied.application_id,
                       applied.receipt_no,
                       (CASE WHEN applied.receipt_no = '82328B' THEN
                           'MEDWARE' 
                        WHEN applied.receipt_no =  medreceipt.re_receipt_no then
                           'MEDWARE' ELSE
                           'FUSION'
                        END) receipt_source,
                       applied.receipt_date,
                       applied.customer_acct_id,
                       applied.currency_code,
                       applied.exchange_rate,
                       applied.inv_no,
                       applied.invoice_date,
                       applied.enrollment_product,
                       applied.policy_code,
                       applied.member_no,
                       applied.dependant_no,
                       applied.subs_date,
                       applied.member_name,
                       applied.sob,
                       applied.status,
                       applied.bu,
                       applied.group_account,
                       applied.country_code,
                       applied.type,
                       applied.gl_date,
                       applied.invoice_type,
                       applied.invoice_source,
                  --     levy.adjustment,
                       applied.payment_type,
                       applied.bulking_criteria,
                       levy.time_period,
                       (case when levy.sequence IS NULL THEN
                          10 ELSE
                          levy.sequence
                        end) sequence,
                       nvl(levy.percentage,100) percentage,
                      /* (CASE WHEN nvl(levy.percentage,100) = 100 THEN
                          total_perc.less_perc ELSE
                          0
                        END) less_perc,*/
                        0 less_perc,
                        round(applied.amount_paid,2) amount_paid,
                      --  ROUND(applied.amount_paid,2) amount_paid,
                        tax_recoverable
                  FROM  comms_fusion_app_receipts_gt applied,
                        COMMS_LEVY_INFORMATION_gt levy,
                        (SELECT TO_CHAR(re_receipt_no) re_receipt_no
                           FROM COMM_MEDWARE_RECEIPTS_V)  medreceipt
                        /*(  SELECT clig.key, clig.subs_date, clig.policy_code policy_code, clig.time_period, sum(clig.percentage) less_perc 
                           FROM COMMS_LEVY_INFORMATION_gt clig,
                                (select count(adjustment) cnt, POLICY_CODE, subs_date
                            from COMMS_LEVY_INFORMATION_gt
                            GROUP BY POLICY_CODE,subs_date) cligcnt
                          WHERE ((percentage <> 100 and cligcnt.cnt > 1 and TYPE <> 'P') OR
                              (cligcnt.cnt = 1) 
                              )
                          --   AND clig.policy_code = '5486920' 
                            and cligcnt.policy_code = clig.policy_code
                            and cligcnt.subs_date = clig.subs_date
                            GROUP BY clig.key, clig.policy_code, clig.time_period, clig.subs_date) total_perc  */
                  WHERE 1=1 -- NEED TO CODE FOR LS ADJUSTMENT TYPES WITH 0 PERC BUT HAVE NOT CORE PREMIUM CODE** I.E LSTR POLICY 5253942
                     AND nvl(levy.percentage,100) = 100
                     AND (levy.policy_code          = applied.group_account or levy.group_code = applied.group_account)
                     AND levy.product               = applied.enrollment_product
                     AND levy.key                   = applied.key
                     AND applied.subs_date          = levy.subs_date
                     and applied.policy_code        = levy.policy_code
                     AND ((applied.payment_type       = levy.adjustment)
                       OR (levy.type = 'P' and applied.payment_type = 'CORE')
                       ) -- CORE populated in Fusion and not the actual P name i.e. ACQ or ACQN to need to handle
                     and medreceipt.re_receipt_no(+) = applied.receipt_no
                UNION  -- ACCOMODATE FOR LS MIGRATED INVOICES WITHOUT PAYMENT TYPE OF CORE
                   SELECT   applied.customer_class_code,
                       applied.receipt_id,
                       applied.customer_trx_id,
                       applied.customer_line_id,
                       applied.application_id,
                       applied.receipt_no,
                       (CASE WHEN applied.receipt_no = '82328B' THEN
                           'MEDWARE' 
                        WHEN applied.receipt_no =  medreceipt.re_receipt_no then
                           'MEDWARE' ELSE
                           'FUSION'
                        END) receipt_source,
                       applied.receipt_date,
                       applied.customer_acct_id,
                       applied.currency_code,
                       applied.exchange_rate,
                       applied.inv_no,
                       applied.invoice_date,
                       applied.enrollment_product,
                       applied.policy_code,
                       applied.member_no,
                       applied.dependant_no,
                       applied.subs_date,
                       applied.member_name,
                       applied.sob,
                       applied.status,
                       applied.bu,
                       applied.group_account,
                       applied.country_code,
                       applied.type,
                       applied.gl_date,
                       applied.invoice_type,
                       applied.invoice_source,
                  --     levy.adjustment,
                       nvl(applied.payment_type,'CORE') payment_type,
                       applied.bulking_criteria,
                       levy.time_period,
                       (case when levy.sequence IS NULL THEN
                          10 ELSE
                          levy.sequence
                        end) sequence,
                       nvl(levy.percentage,100) percentage,
                      /* (CASE WHEN nvl(levy.percentage,100) = 100 THEN
                          total_perc.less_perc ELSE
                          0
                        END) less_perc,*/
                        0 less_perc,
                         SUM(round(applied.amount_paid,2)) OVER (PARTITION BY applied.inv_no, applied.group_account, applied.receipt_no, applied.application_id, applied.policy_code,applied.member_no, nvl(applied.payment_type,'CORE')) amount_paid,
                      --  ROUND(applied.amount_paid,2) amount_paid,
                        tax_recoverable
                  FROM  comms_fusion_app_receipts_gt applied,
                        COMMS_LEVY_INFORMATION_gt levy,
                        (SELECT TO_CHAR(re_receipt_no) re_receipt_no
                           FROM COMM_MEDWARE_RECEIPTS_V)  medreceipt
                        /*(  SELECT clig.key, clig.subs_date, clig.policy_code policy_code, clig.time_period, sum(clig.percentage) less_perc 
                           FROM COMMS_LEVY_INFORMATION_gt clig,
                                (select count(adjustment) cnt, POLICY_CODE, subs_date
                            from COMMS_LEVY_INFORMATION_gt
                            GROUP BY POLICY_CODE,subs_date) cligcnt
                          WHERE ((percentage <> 100 and cligcnt.cnt > 1 and TYPE <> 'P') OR
                              (cligcnt.cnt = 1) 
                              )
                          --   AND clig.policy_code = '5486920' 
                            and cligcnt.policy_code = clig.policy_code
                            and cligcnt.subs_date = clig.subs_date
                            GROUP BY clig.key, clig.policy_code, clig.time_period, clig.subs_date) total_perc  */
                  WHERE 1=1 -- NEED TO CODE FOR LS ADJUSTMENT TYPES WITH 0 PERC BUT HAVE NOT CORE PREMIUM CODE** I.E LSTR POLICY 5253942
                     AND nvl(levy.percentage,100) = 0
                     AND country_code = 'LS'
                     AND (levy.policy_code          = applied.group_account or levy.group_code = applied.group_account)
                     AND levy.product               = applied.enrollment_product
                     AND levy.key                   = applied.key
                     AND applied.subs_date          = levy.subs_date
                     and applied.policy_code        = levy.policy_code
                  --   AND ((applied.payment_type       = levy.adjustment)
                   AND (levy.type = 'A' and applied.payment_type IS NULL)
                   --    ) -- CORE populated in Fusion and not the actual P name i.e. ACQ or ACQN to need to handle
                     and medreceipt.re_receipt_no(+) = applied.receipt_no
                UNION -- if the levy has already been calculated on Fusion 
                  SELECT /*+index (applied comms_fusion_receipt_idx1) */ 
                       applied.customer_class_code,
                       applied.receipt_id,
                       applied.customer_trx_id,
                       applied.customer_line_id,
                       applied.application_id,
                       applied.receipt_no,
                       (CASE WHEN applied.receipt_no = '82328B' THEN
                           'MEDWARE' 
                        WHEN applied.receipt_no =  medreceipt.re_receipt_no then
                           'MEDWARE' ELSE
                           'FUSION'
                       END) receipt_source,
                       applied.receipt_date,
                       applied.customer_acct_id,
                       applied.currency_code,
                       applied.exchange_rate,
                       applied.inv_no,
                       applied.invoice_date,
                       applied.enrollment_product,
                       applied.policy_code,
                       applied.member_no,
                       applied.dependant_no,
                       applied.subs_date,
                       applied.member_name,
                       applied.sob,
                       applied.status,
                       applied.bu,
                       applied.group_account,
                       applied.country_code,
                       applied.type,
                       applied.gl_date,
                       applied.invoice_type,
                       applied.invoice_source,
                       levy.adjustment payment_type,
                     --  applied.payment_type,
                       applied.bulking_criteria,
                       levy.time_period,
                       (case when levy.sequence IS NULL THEN
                          10 ELSE
                          levy.sequence
                        end) sequence,
                       nvl(levy.percentage,100) percentage,
                       0,
                       (CASE WHEN levy.adjustment = 'TRAL' THEN
                          tax_recoverable
                        WHEN levy.adjustment = 'SUPL' THEN
                           amount_paid
                        ELSE
                          (amount_paid*levy.percentage)
                          END)  amount_paid,
                   --    0 amount_paid,
                        tax_recoverable
                       /*(CASE WHEN nvl(levy.percentage,100) = 100 THEN
                          total_perc.less_perc ELSE
                          0
                        END) less_perc,
                       0 amount_paid*/
                  FROM  comms_fusion_app_receipts_gt applied,
                        (SELECT  levy.adjustment, 
                        levy.key,levy.product,
                        levy.group_code,
                                levy.time_period,
                                levy.sequence,
                                levy.policy_code,
                                levy.subs_date,
                        nvl(levy.percentage,100) percentage
                          FROM COMMS_LEVY_INFORMATION_gt levy,
                                ( SELECT DISTINCT
                                                            PSD.code adjustment
                                                      FROM OHI_POLICIES_VIEWS_OWNER.POL_SCHEDULE_DEFINITIONS_V@POLICIES.LIBERTY.CO.ZA  PSD,
                                                           OHI_POLICIES_OWNER.POL_ENROLLMENT_PRODUCTS_B@POLICIES.LIBERTY.CO.ZA PEPB
                                                           JOIN OHI_POLICIES_OWNER.POL_ENROLL_PRODUCT_DETAILS@POLICIES.LIBERTY.CO.ZA PEPD
                                                           ON PEPD.ENPR_ID = PEPB.ID
                                                           JOIN OHI_POLICIES_VIEWS_OWNER.POL_TIME_PERIODS_V@POLICIES.LIBERTY.CO.ZA ptpd
                                                           ON ptpd.enpr_id = pepd.enpr_id   
                                                      WHERE 1=1
                                                        AND PSD.TYPE = 'A') adjust
                        where 1=1 
                         AND levy.adjustment             = adjust.adjustment) levy,
                        (SELECT TO_CHAR(re_receipt_no) re_receipt_no
                           FROM COMM_MEDWARE_RECEIPTS_V)  medreceipt
                  WHERE 1=1
                    -- AND nvl(levy.percentage,100)= 100
                     AND levy.adjustment             = applied.payment_type
                  --   AND applied.policy_code = '5319382'
                  --   AND applied.bulking_criteria = '5319382-00'
                     AND (levy.policy_code           = applied.group_account or levy.group_code = applied.group_account)
                     AND levy.product                = applied.enrollment_product
                     AND levy.key                    = applied.key
                     AND levy.subs_date              = applied.subs_date
                     and levy.policy_code            =  applied.policy_code 
                     and medreceipt.re_receipt_no(+) = applied.receipt_no
                UNION -- levy information not calculated on fusion which needs to be calculated
                SELECT /*+index (applied comms_fusion_receipt_idx1) */ 
                       applied.customer_class_code,
                       applied.receipt_id,
                       applied.customer_trx_id,
                       applied.customer_line_id,
                       applied.application_id,
                       applied.receipt_no,
                       (CASE WHEN applied.receipt_no = '82328B' THEN
                           'MEDWARE' 
                        WHEN applied.receipt_no =  medreceipt.re_receipt_no then
                           'MEDWARE' ELSE
                           'FUSION'
                       END) receipt_source,
                       applied.receipt_date,
                       applied.customer_acct_id,
                       applied.currency_code,
                       applied.exchange_rate,
                       applied.inv_no,
                       applied.invoice_date,
                       applied.enrollment_product,
                       applied.policy_code,
                       applied.member_no,
                       applied.dependant_no,
                       applied.subs_date,
                       applied.member_name,
                       applied.sob,
                       applied.status,
                       applied.bu,
                       applied.group_account,
                       applied.country_code,
                       applied.type,
                       applied.gl_date,
                       applied.invoice_type,
                       applied.invoice_source,
                       'CORE-'||levy.adjustment payment_type,
                     --  applied.payment_type,
                       applied.bulking_criteria,
                       levy.time_period,
                       (case when levy.sequence IS NULL THEN
                          10 ELSE
                          levy.sequence
                        end) sequence,
                       nvl(levy.percentage,100) percentage,
                       0,
                        (CASE WHEN levy.adjustment = 'TRAL' THEN
                          total.amt
                        WHEN levy.adjustment = 'SUPL' THEN
                          (amount_paid*levy.percentage)
                          END)  amount_paid,
                   --    0 amount_paid,
                       0 tax_recoverable
                       /*(CASE WHEN nvl(levy.percentage,100) = 100 THEN
                          total_perc.less_perc ELSE
                          0
                        END) less_perc,
                       0 amount_paid*/
                  FROM  comms_fusion_app_receipts_gt applied,
                        (SELECT  levy.adjustment, 
                        levy.key,levy.product,
                        levy.group_code,
                                levy.time_period,
                                levy.sequence,
                                levy.policy_code,
                                levy.subs_date,
                        nvl(levy.percentage,100) percentage
                          FROM COMMS_LEVY_INFORMATION_gt levy,
                                ( SELECT DISTINCT
                                                            PSD.code adjustment
                                                      FROM OHI_POLICIES_VIEWS_OWNER.POL_SCHEDULE_DEFINITIONS_V@POLICIES.LIBERTY.CO.ZA  PSD,
                                                           OHI_POLICIES_OWNER.POL_ENROLLMENT_PRODUCTS_B@POLICIES.LIBERTY.CO.ZA PEPB
                                                           JOIN OHI_POLICIES_OWNER.POL_ENROLL_PRODUCT_DETAILS@POLICIES.LIBERTY.CO.ZA PEPD
                                                           ON PEPD.ENPR_ID = PEPB.ID
                                                           JOIN OHI_POLICIES_VIEWS_OWNER.POL_TIME_PERIODS_V@POLICIES.LIBERTY.CO.ZA ptpd
                                                           ON ptpd.enpr_id = pepd.enpr_id   
                                                      WHERE 1=1
                                                        AND PSD.TYPE = 'A') adjust
                        where 1=1 
                         AND levy.adjustment             = adjust.adjustment
                         and levy.percentage <> 0) levy,
                        (SELECT TO_CHAR(re_receipt_no) re_receipt_no
                           FROM COMM_MEDWARE_RECEIPTS_V)  medreceipt,
                           (  select SUM(tax_recoverable) amt, applied.application_id, applied.subs_date, applied.policy_code, applied.receipt_no,  applied.bulking_criteria, applied.invoice_type,applied.key                     
                     from comms_fusion_app_receipts_gt applied
                     group by applied.subs_date, applied.policy_code, applied.application_id, applied.receipt_no,  applied.bulking_criteria, applied.invoice_type,applied.key) total
                  WHERE 1=1
                    -- AND nvl(levy.percentage,100)= 100
                     AND NOT EXISTS (SELECT 'X' 
                                       FROM comms_fusion_app_receipts_gt 
                                      WHERE payment_type = levy.adjustment 
                                       AND policy_code   = applied.policy_code
                                    )
                 --    AND applied.policy_code         = '5104823'
                 --    AND applied.bulking_criteria    = '5104823-00'
                     AND (levy.policy_code           = applied.group_account or levy.group_code = applied.group_account)
                     AND levy.product                = applied.enrollment_product
                     AND levy.key                    = applied.key
                     AND applied.payment_type        = 'CORE' -- additional levy calculated on core
                     AND levy.subs_date              = applied.subs_date
                     and levy.policy_code            = applied.policy_code 
                     and medreceipt.re_receipt_no(+) = applied.receipt_no
                     and applied.subs_date           = total.subs_date 
                     and applied.application_id      = total.application_id
                     and applied.policy_code         = total.policy_code    
                     and applied.receipt_no          = total.receipt_no
                     and applied.bulking_criteria    = total.bulking_criteria
                     and applied.invoice_type        = total.invoice_type
                     and applied.key                 = total.key;   

     TYPE premiums_t                IS TABLE OF c_premiums%ROWTYPE INDEX BY PLS_INTEGER;
     premiums_local                 premiums_t; 

     TYPE comms_levy_information_t  IS TABLE OF comms_levy_information_ohi%ROWTYPE INDEX BY PLS_INTEGER;
     comms_levy_local               comms_levy_information_t;

     TYPE comms_fusion_app_receipts_t IS TABLE OF comms_fusion_app_receipts%ROWTYPE INDEX BY PLS_INTEGER;
     comms_fusion_local             comms_fusion_app_receipts_t;

     TYPE comms_update_values_t IS TABLE OF c_update_values%ROWTYPE INDEX BY PLS_INTEGER;
     update_values_local             comms_update_values_t;

     TYPE comms_levies_all_t          IS TABLE OF c_levies_final%ROWTYPE INDEX BY PLS_INTEGER;
     comms_levies_all_local             comms_levies_all_t;

    

BEGIN

 --- due to naming of db links created a procedure to handle this for the medware receipts view
  create_medware_view;

  IF g_log_file_name IS NOT NULL THEN
      commissions_pkg.write_to_file(  g_log_file_name,'Importing any unprocessed premium applications - at :'||systimestamp);
  END IF;    
  
   --2. All levy information from OHI -- to reduce hardcoding for levy calculationsr
   OPEN comms_fusion_app_receipts;
   LOOP
       FETCH comms_fusion_app_receipts BULK COLLECT INTO comms_fusion_local;
       FORALL idx IN 1 .. comms_fusion_local.COUNT SAVE EXCEPTIONS 

             INSERT INTO comms_fusion_app_receipts_gt values comms_fusion_local(idx);
        EXIT WHEN comms_fusion_app_receipts%NOTFOUND;
   END LOOP;
   
   CLOSE comms_fusion_app_receipts;
    IF g_log_file_name IS NOT NULL THEN
     commissions_pkg.write_to_file(  g_log_file_name,'All Information inserted into the comms_fusion_app_receipts_gt global temp table - at :'||systimestamp);
     commissions_pkg.write_to_file(  g_log_file_name,'Total count in comms_fusion_app_receipts_gt table is '||comms_fusion_local.COUNT);
    END IF;
    
  
 -- COMMIT; 
   --1. decide on what group - invoice numbers need to be processed as part of this run
   -- populate global temporary tables with information for
   --1. Applied receipts to be processed
  FOR c_rec IN (SELECT distinct max(application_id) application_id, customer_trx_id
                  FROM comms_fusion_app_receipts_gt
                  group by customer_trx_id
                   ) LOOP --query takes long break it up into smaller pieces as application is applied across entire invoice only need to bring in the max if unapplied and applied exists
          
          l_application_id := c_rec.application_id;
          
          BEGIN
           OPEN comms_levy_information_ohi;
           LOOP
               FETCH comms_levy_information_ohi BULK COLLECT INTO comms_levy_local;
               FORALL idx IN 1 .. comms_levy_local.COUNT SAVE EXCEPTIONS -- here to manage the DUP_VAL_ON_INDEX
        
                     INSERT INTO comms_levy_information_gt values comms_levy_local(idx);
                EXIT WHEN comms_levy_information_ohi%NOTFOUND;
           END LOOP;
           CLOSE comms_levy_information_ohi;
          EXCEPTION
        
              when OTHERS then
        
                        FOR i IN 1 .. SQL%bulk_exceptions.COUNT
                        LOOP
        
                          IF g_log_file_name IS NOT NULL THEN 
                           commissions_pkg.write_to_file(  g_log_file_name,sql%bulk_exceptions(i).error_code);
                           commissions_pkg.write_to_file(  g_log_file_name,sqlerrm(-sql%bulk_exceptions(i).error_code));
                           commissions_pkg.write_to_file(  g_log_file_name,sql%bulk_exceptions(i).error_index);
                          END IF; 
                       END LOOP;    
          -- rollback;             
           raise e_Exception;
          END;   
   END LOOP;
          
   IF g_log_file_name IS NOT NULL THEN 
    commissions_pkg.write_to_file(  g_log_file_name,'All Information inserted into the comms_levy_information_gt global temp table - at :'||systimestamp);
    commissions_pkg.write_to_file(  g_log_file_name,'Total count in levy table is '||comms_levy_local.COUNT);
   END IF;
   
 -- COMMIT; 
   -- work in progress on the query need to remove SUPL if already calculated but has to be as generic as possible


   BEGIN 
       OPEN c_levies_final;
       LOOP
           FETCH c_levies_final BULK COLLECT INTO comms_levies_all_local;
           FORALL idx IN 1 .. comms_levies_all_local.COUNT SAVE EXCEPTIONS 

                 INSERT INTO comms_payments_received_gt values comms_levies_all_local(idx);
            EXIT WHEN c_levies_final%NOTFOUND;
       END LOOP;
       CLOSE c_levies_final;
    EXCEPTION

      when OTHERS then

                FOR i IN 1 .. SQL%bulk_exceptions.COUNT
                LOOP

                  IF g_log_file_name IS NOT NULL THEN 
                   commissions_pkg.write_to_file(  g_log_file_name,sql%bulk_exceptions(i).error_code);
                   commissions_pkg.write_to_file(  g_log_file_name,sqlerrm(-sql%bulk_exceptions(i).error_code));
                   commissions_pkg.write_to_file(  g_log_file_name,sql%bulk_exceptions(i).error_index);
                  END IF; 
               END LOOP;    
  -- rollback;             
   raise e_Exception;
  END;     
  IF g_log_file_name IS NOT NULL THEN              
       commissions_pkg.write_to_file(  g_log_file_name,'All Information inserted into the comms_payments_received_gt global temp table - at :'||systimestamp);
       commissions_pkg.write_to_file(  g_log_file_name,'Total count in comms_payments_received_gt table is '||comms_levies_all_local.COUNT);
  END IF;   
  
 

 BEGIN 

 --  commissions_pkg.write_to_file(  g_log_file_name,'pre insert into the comms_payments_Received table*** final step');
 
  OPEN c_premiums;
  FETCH c_premiums BULK COLLECT INTO premiums_local;
  FORALL idx IN 1 .. premiums_local.COUNT SAVE EXCEPTIONS -- here to manage the DUP_VAL_ON_INDEX

     INSERT INTO comms_payments_received values premiums_local(idx);

  CLOSE c_premiums;
 EXCEPTION

   when DML_ERRORS then

                FOR i IN 1 .. SQL%bulk_exceptions.COUNT
                LOOP

                  IF g_log_file_name IS NOT NULL THEN 
                   commissions_pkg.write_to_file(  g_log_file_name,sql%bulk_exceptions(i).error_code);
                   commissions_pkg.write_to_file(  g_log_file_name,sqlerrm(-sql%bulk_exceptions(i).error_code));
                   commissions_pkg.write_to_file(  g_log_file_name,sql%bulk_exceptions(i).error_index);
                  END IF; 
               END LOOP;    
  -- rollback;             
   raise e_Exception;
  END;   
  IF g_log_file_name IS NOT NULL THEN 
   commissions_pkg.write_to_file(  g_log_file_name,'Total count in comms_payments_received table is '||premiums_local.COUNT);
  END IF;

  COMMIT;

  -- once the table is populated set the flag for the partial applied receipts so that the % is only
  -- retrieved for those entries as for fully applied the normal %'s apply.
   FOR c_rec IN (
   SELECT DISTINCT
           organization_name bu
          ,customer_number   group_code
          ,invoice_no
      FROM  (
           SELECT group_code||finance_invoice_no key, 
                  SUM(finance_receipt_amt)       fusion_amt
             FROM comms_payments_received
           GROUP BY group_code||finance_invoice_no) total_csb,
          ws_soap_inbound t,    
          XMLTABLE('//DATA_DS/G_1' PASSING XMLTYPE(t.payload)    
          COLUMNS     
          ORGANIZATION_NAME VARCHAR2(150) PATH 'ORGANIZATION_NAME/text()',    
          CUSTOMER_NAME     VARCHAR2(150) PATH 'CUSTOMER_NAME/text()',    
          CUSTOMER_NUMBER   VARCHAR2(150) PATH 'CUSTOMER_NUMBER/text()',    
          INVOICE_TYPE      VARCHAR2(150) PATH 'INVOICE_TYPE/text()',    
          INVOICE_NO        VARCHAR2(150) PATH 'INVOICE_NO/text()',    
          DUE_DATE          DATE          PATH 'DUE_DATE/text()',    
          TRX_DATE          DATE          PATH 'TRX_DATE/text()',    
          GL_DATE           DATE          PATH 'GL_DATE/text()',    
          GL_DATE_CLOSED    DATE          PATH 'GL_DATE_CLOSED/text()',    
          CURRENCY_CODE     VARCHAR2(20)  PATH 'CURRENCY_CODE/text()',    
          CITY              VARCHAR2(200) PATH 'CITY/text()',    
          PAYMENT_SCHEDULE_CLASS         VARCHAR2(100) PATH 'PAYMENT_SCHEDULE_CLASS/text()',    
          INVOICE_AMT       NUMBER        PATH 'INVOICE_AMT/text()',    
          PAYMENT_AMT       NUMBER        PATH 'PAYMENT_AMT/text()',    
          ADJUSTMENTS       NUMBER        PATH  'ADJUSTMENTS/text()',    
          CREDIT_MEMO       NUMBER        PATH 'CREDIT_MEMO/text()',    
          TAX_AMOUNT        NUMBER        PATH 'TAX_AMOUNT/text()',    
          BALANCE_AMT       NUMBER        PATH 'BALANCE_AMT/text()') 
      WHERE t.process_name                = 'FUSION_BILLING'
       AND total_csb.key(+)               = CUSTOMER_NUMBER||INVOICE_NO
       AND t.creation_date                = (SELECT MAX(creation_date) 
                                               FROM ws_soap_inbound 
                                              WHERE process_name = 'FUSION_BILLING' 
                                             )
       AND (
            -- comment this section is for brokers with commission payments allowed on partial receipts
            (customer_number IN (SELECT DISTINCT group_code 
                                  FROM comms_on_partial_receipt 
                                 WHERE trunc(TRX_DATE) BETWEEN trunc(effective_Start_date) AND trunc(effective_end_date)
                                   AND NVL(interface_to_comms,'Y') = 'Y' -- only if interfacing allowed
                                   AND NVL(active_yn,'N') = 'Y') --only if the record is currently active i.e. approved
                                   AND (
                                         (payment_amt <> 0 AND balance_amt <> 0) 
                                    OR    credit_memo <> 0
                                        )
            )
           )) LOOP

         UPDATE comms_payments_received
            SET partial_yn                 = 'Y'
         WHERE processed_ind               = 'N'
           AND TRUNC(last_update_datetime) = trunc(sysdate)
           AND finance_invoice_no          = c_rec.invoice_no
           AND group_code                  = c_rec.group_code
           AND bu                          = c_rec.bu;

         -- COMMIT; 

   END LOOP;    
   
   
   IF g_log_file_name IS NOT NULL THEN 
    commissions_pkg.write_to_file(  g_log_file_name,'All partial entries updated - for reference purposes - at :'||systimestamp);
   END IF;
   
   
   COMMIT; 
   
   
   -- update the group_code value for individual members as the reconciliation is showing two entries
   -- one for the numeric group code and one for the converted UGIND value
   
   FOR c_group IN (
                     SELECT MAX(grac.group_code) group_code, poli.policy_code --INTO lv_group_code
                       FROM ohi_policy_groups       pogr
                       JOIN ohi_policies            poli
                         ON pogr.poli_id = poli.poli_id
                       JOIN ohi_groups              grac
                         ON pogr.grac_id = grac.grac_id
                       JOIN (SELECT DISTINCT
                                    group_code, 
                                    policy_code, 
                                    contribution_date
                             FROM comms_payments_received
                             where processed_ind = 'N'
                             and check_if_number(group_code) is not null) individuals 
                         ON poli.policy_code = individuals.policy_code    
                        AND individuals.contribution_date between pogr.effective_start_date and pogr.effective_end_date      
                      WHERE 1=1
                        AND poli.poli_id = (SELECT max(poli_id) FROM ohi_policies WHERE policy_code = poli.policy_code)
                      GROUP BY poli.policy_code
                  ) LOOP
            
            UPDATE comms_payments_received
               SET group_code    = c_group.group_code
             WHERE policy_code   = c_group.policy_code
               AND processed_ind = 'N';
            
            
   END LOOP;       

   
   
   IF g_log_file_name IS NOT NULL THEN 
    commissions_pkg.write_to_file(  g_log_file_name,'All group information for UGIND members have been updated :'||systimestamp);
   END IF;
   
   
   COMMIT; 
   

   -- update the driving tables ws_soap_inbound to processed Y to allow another process to run if called
   mark_processed_entries;

 /* UPDATE SYSTEM_PARAMETER
    SET PARAMETER_VALUE = TO_CHAR(TRUNC(SYSDATE),'MM-DD-YYYY')
   WHERE SYSTEM_NAME = 'LB_HEALTH_COMMS'
     AND PARAMETER_SECTION = 'FUSION'
     AND PARAMETER_KEY = 'LAST_FUSION_PREMIUM_CHECK';*/

 write_csv(g_output_file_name,'SELECT * FROM lhhcom.comms_payments_received WHERE last_update_datetime BETWEEN '||g_job_start_date||' AND SYSDATE');



EXCEPTION 
 WHEN E_EXCEPTION THEN
  mark_processed_entries;
  IF g_log_file_name IS NOT NULL THEN
   commissions_pkg.write_to_file(  g_log_file_name,'Information Rolled back - Error occured in process_fusion_premium '||SQLERRM); 
  END IF; 
  rollback;

 WHEN OTHERS THEN
   mark_processed_entries;
  IF g_log_file_name IS NOT NULL THEN 
   commissions_pkg.write_to_file(  g_log_file_name,'Error occured in process_fusion_premium '||SQLERRM); -- NEED TO ADD EXCEPTION HANDLING
  END IF; 
   rollback;

END process_fusion_premiums;
-- end 1.2

END COMMISSIONS_PKG;
/
set define off;
