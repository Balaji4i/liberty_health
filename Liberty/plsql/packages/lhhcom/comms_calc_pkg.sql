set define off;

/

create or replace PACKAGE          "COMMS_CALC_PKG" 
AS
/**
* <pre>
* ----------------------------------------------------------------------
* Project:     : Commission Self Build
*
*                Description  : Procedures and Functions used for the Commission Calculations
*                File Name    : Liberty\plsql\packages\lhhcom\comms_calc_pkg.sql
*                Author       : Jaco Bosman
*                Requirements : Access to account SCHEMA
*                Call Syntax  : Anonymous Block Example at the bottom of package header
*
*                Amendments   :
*                Date        User     Change Description
*                ========    ======== =================================================
*                2017/09/14  Sarel    Change the Comm Perc pick-up
*                2017/11/30  Helen    Recalculation of changes
*                2018/01/19  Sarel    Resolve Conflicting Code
*                2018/02/16  Sarel    Recalc needs the latest POEP_ID to do the Calculation on.
*                2018/03/14  Sarel    Implement Payment Currency into Recalc procedure also.
*                2018/05/24  Sarel    Compile Recalc changes in Dev, Uat, Test and PreProd
*                2018/06/12  Adriaan  LS-1061. Added comms_calc_snapshot_no to comms_calc_snapshot and comms_payments received.
*                2018/06/12  Adriaan  LS-1061. Added table comms_calc_trace to create link 
*                                     between processed, adjustment and reversal rows on comms_calc_snapshot
*                2018/06/15  Helen    LS-1301 allow payment to resigned brokers. Change is in GET_INVOICE_HOLD_REASON fn.
*                2018/06/15  Helen    LS-1361 Interfaces with Fusion. checking company accreditation for invoiceing 
*                2018/07/25  AdriaanB LS-1061B. Use the correct comms_calc_snapshot_no value in comms_payments_received and comms_calc_trace  
*                2018/09/19  Sarel    LS-XXXX. Exclude certain transaction type from commission calc
*                2018/12/12  Sarel    LS-2207. Use Commisionable Flag from OHI Policies when calculating commissions
*                2019/03/11  T.Percy  Remove any Test Runs no longer applicable  - Ticket OP-104
*                2020/10/05  Sarel    ARP-432. Apply date to select correct Policy Broker
*                2020/10/05  Sarel    OU-176. Cater for Orbit pgrade changes in 19.1, 19.2, 19.3, 20.1 and 20.2 (pol_assigned_broker_agents_v)
* </pre>         */

PROCEDURE commissions_calc_run (pn_company_id_no IN  NUMBER   DEFAULT NULL
                               ,pv_country_code  IN  VARCHAR2 DEFAULT NULL
                               ,pv_group_code    IN  VARCHAR2 DEFAULT NULL
                               ,pv_product_code  IN  VARCHAR2 DEFAULT NULL
	                        	   ,pv_username      IN  VARCHAR2 DEFAULT USER);
                             --  ,pv_return_msg    OUT VARCHAR2);

PROCEDURE recalc_changes_run   (pv_username IN VARCHAR2,
                                pv_return_msg    OUT VARCHAR2);

PROCEDURE approve_comms_run    (pn_company_id_no IN  NUMBER
                               ,pv_country_code  IN  VARCHAR2
						              	   ,pv_comms_consultant IN VARCHAR2
                               ,pv_group_code    IN  VARCHAR2
                               ,pv_product_code  IN  VARCHAR2
							                 ,pv_username      IN  VARCHAR2 DEFAULT USER);
                              -- ,pv_return_msg    OUT VARCHAR2);

PROCEDURE execute_payment_run  (pn_invoice_no    IN  NUMBER
                               ,pn_company_id_no IN  NUMBER
                               ,pv_country_code  IN  VARCHAR2
                               ,pv_username      IN  VARCHAR2);
                          --     ,pv_return_msg    OUT VARCHAR2);

PROCEDURE proof_of_payment_update_run   (pv_username IN  VARCHAR2 DEFAULT USER,
                                         pv_return_msg  OUT VARCHAR2);

-- * Example of Procedures executed in an anonymous block (auto-commit data)
-- * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
/*

SET SERVEROUTPUT ON;
DECLARE
  l_return_msg VARCHAR2(100);
BEGIN
-- To Run for a Group
--  comms_calc_pkg.commissions_calc_run(NULL, NULL, 'CENTUMGANDA', NULL, 'SARELTWO', l_return_msg);
--  dbms_output.put_line('Block - ' || l_return_msg);
-- To Run for all records
--  comms_calc_pkg.commissions_calc_run(NULL, NULL, NULL, NULL, l_return_msg);
--  dbms_output.put_line('Block - ' || l_return_msg);
-- To Run for re-calculation (all records)
  comms_calc_pkg.recalc_changes_run(USER, l_return_msg);
  dbms_output.put_line('Block - ' || l_return_msg);
END;

-- */

END COMMS_CALC_PKG;

/

create or replace PACKAGE BODY                        COMMS_CALC_PKG
    
      AS
    /**
    * <pre>
    * ----------------------------------------------------------------------
    * Project:     : Commission Self Build
    *
    *                Description  : Package to run Data the commission calculations
    *                File Name    : Liberty\plsql\packages\lhhcom\comms_calc_pkg.sql
    *
    *                Amendments   :
    *                Date        User     Change Version      Change Description
    *                ========    ======== ==============      =================================================
    *                2018/11/21  T.Percy   1.0      Redesign execute payment run - fundamental flaws in logic for total of all invoices
    *                                               if the payment is submitted on the broker level
    *                2018-11-22  T.Percy   1.1       Changed jobs to be submitted via the scheduler with improved logging and output for the business
    *                                               all entries for commissions_pkg.write_to_file(  g_log_file_name and g_output_file_name part of this change
    *                                               Added Facility to run for a brokerage for comms calc run
    *                2018-12-04  T.Percy   1.2      For individual members override group code (policycode) with the group code so that on approval the
    *                                               processed ind is set to "Y" and does not remain as "TY".
    *                2019/03/11  T.Percy   1.3      Remove any Test Runs no longer applicable  - Ticket OP-104
    *                2018/12/12  S.Eybers  1.4      LS-2207. Use Commisionable Flag from OHI Policies when calculating commissions
    *                2019/04/15  T.Percy   1.5      OP-121, OP-352, NIG-469. Changes to the Integration process. 
    *                2020/07/30  T.Percy   1.6      Do not reject resigned members
    *                2020/10/05  Sarel     1.7      ARP-432. Apply date to select correct Policy Broker
    *                2020/10/05  Sarel     1.8      OU-176. Cater for Orbit pgrade changes in 19.1, 19.2, 19.3, 20.1 and 20.2 (pol_assigned_broker_agents_v)
    *
    * </pre>         */

      g_directory        VARCHAR2(100) DEFAULT 'LOGDATA';
      g_log_file_name    VARCHAR2(400);
      g_output_file_name VARCHAR2(400);
      g_logger_identifier NUMBER;
      
      dml_errors          EXCEPTION;
      E_EXCEPTION         EXCEPTION;
      PRAGMA exception_init(dml_errors, -24381);
    -- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    
    -- start  1.6 
   FUNCTION check_resigned_member(
                                                                     p_policy_code            IN VARCHAR2,
                                                                     p_contribution_date IN DATE
                                                                    ) RETURN BOOLEAN IS
                                                                    
                l_Status VARCHAR2(100);
                                                                    
    BEGIN                     
           commissions_pkg.write_to_file(  g_log_file_name,'checking resigned member status :'||
                                                        p_policy_code||' - '||p_contribution_date);  
    
             SELECT fcodmemsts.description
              INTO l_status
            FROM pol_policies_v@POLICIES.LIBERTY.CO.ZA                 policy
               JOIN pol_policyholders_v@POLICIES.LIBERTY.CO.ZA            policyholder 
                  ON policy.id = policyholder.poli_id
               JOIN ohi_insurable_persons_v@POLICIES.LIBERTY.CO.ZA        insureperson 
                  ON policyholder.rela_id_pers = insureperson.rela_id_pers
               JOIN ohi_insurable_entities_v@POLICIES.LIBERTY.CO.ZA       insure_entity 
                  ON insureperson.id = insure_entity.id
               JOIN pol_policy_enrollments_v@POLICIES.LIBERTY.CO.ZA       enrollment 
                 ON insure_entity.id = enrollment.inse_id
                AND policy.id = enrollment.poli_id
               JOIN pol_policy_group_accounts_v@POLICIES.LIBERTY.CO.ZA    pol_group_account ON policy.id = pol_group_account.poli_id
               JOIN pol_group_accounts_v@POLICIES.LIBERTY.CO.ZA           group_account ON pol_group_account.grac_id = group_account.id
                -- optional
               LEFT OUTER JOIN poen_memstsrec@POLICIES.LIBERTY.CO.ZA                 poen_memsts ON enrollment.id = poen_memsts.poen_id
                                                                                         AND ( ( poen_memsts.poen_id IS NOT NULL
                                                                                                 AND poen_memsts.start_date <= p_contribution_date
                                                                                                 AND ( poen_memsts.end_date IS NULL
                                                                                                       OR poen_memsts.end_date >= p_contribution_date ) )
                                                                                               OR poen_memsts.poen_id IS NULL )
                LEFT OUTER JOIN fcod_dependantcode@POLICIES.LIBERTY.CO.ZA             dependant ON enrollment.dependant_id = dependant.id
                LEFT OUTER JOIN fcod_memsts@POLICIES.LIBERTY.CO.ZA                    fcodmemsts ON poen_memsts.memsts = fcodmemsts.id
                LEFT OUTER JOIN pas_brands_v@POLICIES.LIBERTY.CO.ZA                   brand ON policy.bran_id = brand.id
                LEFT OUTER JOIN pol_policy_enroll_products_v@POLICIES.LIBERTY.CO.ZA   enrollprod ON poen_memsts.poen_id = enrollprod.poen_id
                                                                                                      AND ( ( enrollprod.poen_id IS NOT NULL
                                                                                                              AND enrollprod.start_date <= p_contribution_date
                                                                                                              AND ( enrollprod.end_date IS NULL
                                                                                                                    OR enrollprod.end_date >=
                                                                                                                    p_contribution_date ) )
                                                                                                            OR enrollprod.poen_id IS NULL )
                LEFT OUTER JOIN pol_enrollment_products_v@POLICIES.LIBERTY.CO.ZA      poenproduct ON enrollprod.enpr_id = poenproduct.id
                LEFT OUTER JOIN pol_group_account_products_v@POLICIES.LIBERTY.CO.ZA   groupaccprod ON enrollprod.gapr_id = groupaccprod.id
                LEFT OUTER JOIN pol_enrollment_products_v@POLICIES.LIBERTY.CO.ZA      grpaccproduct ON enrollprod.enpr_id = grpaccproduct.id
                -- 1.8 OU-176. Cater for Orbit pgrade changes in 19.1, 19.2, 19.3, 20.1 and 20.2 (pol_assigned_broker_agents_v)
                LEFT OUTER JOIN pol_assigned_broker_agents_v@POLICIES.LIBERTY.CO.ZA   brokeragent ON policy.id = brokeragent.poli_id
                                                                                                     AND ( ( brokeragent.poli_id IS NOT NULL
                                                                                                             AND brokeragent.start_date <= p_contribution_date
                                                                                                             AND ( brokeragent.end_date IS NULL
                                                                                                                   OR brokeragent.end_date >=
                                                                                                                   p_contribution_date ) )
                                                                                                           OR brokeragent.poli_id IS NULL )
                LEFT OUTER JOIN pol_brokers_v@POLICIES.LIBERTY.CO.ZA                  broker ON brokeragent.brkr_id = broker.id
                LEFT OUTER JOIN pol_agents_v@POLICIES.LIBERTY.CO.ZA                   agent ON brokeragent.agnt_id = agent.id
            WHERE
                policy.code = p_policy_code
                AND policy.tec_ind_last_version = 'Y'  --latest version of the policy
                ;
                
                IF l_status = 'Resigned' THEN
                    RETURN TRUE;
                ELSE
                   RETURN FALSE;
                END IF;
                
    EXCEPTION
       WHEN OTHERS THEN
          commissions_pkg.write_to_file(  g_log_file_name,' error checking resigned member status :'||
                                                        SQLERRM);  
           RETURN FALSE;
    END check_resigned_member;
    
    --end  1.6 
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



    PROCEDURE commissions_calc_run (pn_company_id_no IN  NUMBER
                                   ,pv_country_code  IN  VARCHAR2
                                   ,pv_group_code    IN  VARCHAR2
                                   ,pv_product_code  IN  VARCHAR2
     							                 ,pv_username      IN  VARCHAR2 DEFAULT USER
                                 --  ,pv_return_msg    OUT VARCHAR2
                                   )

    IS

      gc_scope_prefix       CONSTANT VARCHAR2(31)           
                                     := lower($$PLSQL_UNIT) || '.';
      l_scope                        logger_logs.scope%TYPE 
                                     := 'CommissionsSelfBuild: ' || gc_scope_prefix;
      l_params                       logger.tab_param;

      ccs                            comms_calc_snapshot%rowtype;
      cct                            comms_calc_trace%rowtype;             --LS-1061
      lv_poli_id                     ohi_policies.poli_id%TYPE;
      lv_inse_id                     ohi_insured_entities.inse_id%TYPE;
      lv_enpr_id                     ohi_products.enpr_id%TYPE;
      lv_grac_id                     ohi_groups.grac_id%TYPE;
      lv_group_code                  ohi_groups.group_code%TYPE;
      lv_poep_id                     ohi_enrollment_products.poep_id%TYPE;
      lv_poep_id1                  ohi_enrollment_products.poep_id%TYPE;
      lv_pogr_id                     ohi_policy_groups.pogr_id%TYPE;
      lv_broker_id                   ohi_policy_brokers.broker_id_no%TYPE;
      ld_calculation_date            DATE;
      lv_company_id                  ohi_policy_brokers.company_id_no%TYPE;
      lv_country_code                company_country.country_code%TYPE;
      lv_result                      VARCHAR2(100);
      lv_commissionable              VARCHAR2(10);
      ln_count                       BINARY_INTEGER;
      l_array                        dbms_utility.lname_array;
      lv_comm_perc                   ohi_comm_perc.comm_perc%TYPE;
      lv_processed_desc              comms_payments_received.processed_desc%TYPE;
      lv_processed_cnt               NUMBER; -- caused precision error in LIVE removed precision -1.5
      lv_processed_success           NUMBER; -- caused precision error in LIVE removed precision 5 to 11 -1.5 
      lv_pref_curr_required          VARCHAR2(1);
      lv_currency_code               comms_calc_snapshot.exchange_rate_currency_code%TYPE;
      ln_exch_rate                   comms_calc_snapshot.exchange_rate%TYPE;
      lv_exch_currency_code          comms_calc_snapshot.exchange_rate_currency_code%TYPE;
      ln_pref_curr_id                VARCHAR2(50);
      l_percentage                   ohi_comm_perc.comm_perc%type;
      l_description                  ohi_comm_perc.comm_desc%type;
      l_return_msg                   VARCHAR2(500);
      l_insert_cct                   BOOLEAN; --LS1061B  
      E_NO_PREF_CUR                  EXCEPTION;
      
      lv_resigned_member     BOOLEAN DEFAULT FALSE;

      pv_return_msg                  VARCHAR2(4000);

      CURSOR c_get_payments_to_calc IS
        SELECT ROWID,
               application_id,
               group_code,
               country_code,
               product_code,
               policy_code,
               person_code,
               payment_type,
               contribution_date,
               finance_receipt_no,
               finance_receipt_date,
               finance_receipt_amt,
               currency_code,
               NVL(partial_yn,'N') partial_yn, --1.5
               bu -- 1.5
          FROM comms_payments_received
         WHERE     processed_ind IN ('N', 'TY', 'TF')
               AND commissionable = 'Y'
               AND country_code = NVL(upper(pv_country_code), country_code)
               AND product_code = NVL(pv_product_code, product_code)
               AND group_code = NVL(pv_group_code, group_code)
               AND ( -- start 1.1
                    (    pn_company_id_no IS NOT NULL 
                     AND get_company_for_run(contribution_date 
                                            ,group_code        
                                            ,product_code      
                                            ,policy_code       
                                            ,person_code
                                            ,g_log_file_name) = pn_company_id_no)
                 OR pn_company_id_no  is null) -- end 1.1
         ORDER BY contribution_date;

    	CURSOR c_check_currency_code IS	
                select company_table_type_desc, preferred_currency_code        
          from company c,            
                (select distinct bf.company_id_no, btt.company_table_type_desc, bf.effective_start_date,       
                 rank() over (partition by bf.company_id_no order by bf.effective_start_date desc) rank_no        
                   from company_function bf, company_table bt, company_table_type btt              
                  where bf.company_table_id_no = bt.company_table_id_no              
                    and bf.company_table_id_no = 6            
                    and bf.company_table_id_no = btt.company_table_id_no              
                    and bf.company_table_type_id_no = btt.company_table_type_id_no              
                    and sysdate between bf.effective_start_date and bf.effective_end_date ) b_multi_net   
          where  c.company_id_no = b_multi_net.company_id_no(+)       
              and nvl(b_multi_net.rank_no,1) = 1
    		      and c.company_id_no = lv_company_id;

      CURSOR c_cpr_payment_types IS
        SELECT DISTINCT
               TRIM(country_code) country_code
              ,contribution_date  contribution_date
              ,TRIM(payment_type) payment_type
          FROM comms_payments_received
         WHERE processed_ind <> 'Y';

       l_session_id VARCHAR2(200);
       l_slave_id   NUMBER;
       l_job_start_date DATE;


    BEGIN
      -- changes made to handle this job in the scheduler - require get the scheduler id for logging purposes -- 1.0
      select sys_context('userenv','sid') INTO l_session_id from dual;
      select userenv('PID') into l_slave_id FROM DUAL;
      select sysdate into l_job_start_date from dual;


      g_logger_identifier := get_scheduler_job_id(l_session_id,l_slave_id);

      g_log_file_name    := g_logger_identifier||'.html';
      g_output_file_name := g_logger_identifier||'.csv';


      --open up a log and output file to store the run and output information for reference
      commissions_pkg.create_file(  
                          p_file_name     => g_log_file_name,
                          p_process       => 'Commissions Calculation Run'
                        );

      commissions_pkg.create_file(  
                          p_file_name     => g_output_file_name,
                          p_process       => 'Commissions Calculation Run'
                        ); 

      commissions_pkg.write_to_file(  g_log_file_name,'Brokerage Code : '||pn_company_id_no);
      commissions_pkg.write_to_file(  g_log_file_name,'Country Code   : '||pv_country_code);
      commissions_pkg.write_to_file(  g_log_file_name,'Group Code     : '||pv_group_code);
      commissions_pkg.write_to_file(  g_log_file_name,'Product Code   : '||pv_product_code);
      commissions_pkg.write_to_file(  g_log_file_name,'User Name      : '||pv_username);   
      --end 1.0

      lv_processed_cnt             := 0;
      lv_processed_success         := 0;
      SELECT SYSDATE INTO ld_calculation_date FROM DUAL;

      -- Refresh Commissionable Indicators from OHI Policies and update CPR
      -- 1.4 start
      lhhcom.refresh_pay_comms; 
      FOR x IN c_cpr_payment_types LOOP
        BEGIN
          lv_result := NULL;
          IF TRIM(x.payment_type) IS NULL THEN
            lv_result         := '-Yes';
          ELSE
            dbms_utility.comma_to_table (list   => regexp_replace(replace(regexp_replace(x.payment_type, '-', ','), ' ', NULL), '(^|,)', '\1x')
                                        ,tablen => ln_count
                                        ,tab    => l_array);
            FOR i IN 1 .. ln_count LOOP
              lv_result := lv_result || '-' || lhhcom.iscommissionable_prem_code(substr(l_array(i),2), x.contribution_date, x.country_code);
            END LOOP;
          END IF;
        END;
        BEGIN
          IF lv_result like '%No%' THEN
            UPDATE comms_payments_received cpr
              SET cpr.commissionable       = 'N',
                  cpr.processed_ind        = 'TY',
                  cpr.processed_desc       = 'Success: No Commission Payable for ' || 
                                             'Country ' || substr(x.country_code || '  ', 1, 2) ||
                                             ', Date ' || substr(x.contribution_date || '          ', 1, 10) ||
                                             'and PmtType ' || substr('"' || x.payment_type || '"               ', 1, 12) ||
                                             '- ' || trim(substr(lv_result, 2, 100)),
                  cpr.last_update_datetime = ld_calculation_date,
                  cpr.username             = pv_username
            WHERE     cpr.processed_ind     <> 'Y'
                  AND cpr.country_code      =  x.country_code
                  AND cpr.contribution_date =  x.contribution_date
                  AND (    TRIM(cpr.payment_type) =  TRIM(x.payment_type)
                        OR (    TRIM(cpr.payment_type) IS NULL
                            AND TRIM(x.payment_type) IS NULL));
          ELSIF lv_result like '%Missing%' THEN
            UPDATE comms_payments_received cpr
              SET cpr.commissionable       = 'M',
                  cpr.processed_ind        = 'TF',
                  cpr.processed_desc       = 'Failed: Missing Commissionable flag for ' || 
                                             'Country ' || substr(x.country_code || '  ', 1, 2) ||
                                             ', Date ' || substr(x.contribution_date || '          ', 1, 10) ||
                                             'and PmtType ' || substr('"' || x.payment_type || '"               ', 1, 12) ||
                                             '- ' || trim(substr(lv_result, 2, 100)),
                  cpr.last_update_datetime = ld_calculation_date,
                  cpr.username             = pv_username
            WHERE     cpr.processed_ind     <> 'Y'
                  AND cpr.country_code      =  x.country_code
                  AND cpr.contribution_date =  x.contribution_date
                  AND (    TRIM(cpr.payment_type) =  TRIM(x.payment_type)
                        OR (    TRIM(cpr.payment_type) IS NULL
                            AND TRIM(x.payment_type) IS NULL));
          ELSIF lv_result like '%Yes%' THEN
            UPDATE comms_payments_received cpr
              SET cpr.commissionable       = 'Y'
            WHERE     cpr.processed_ind     <> 'Y'
                  AND cpr.country_code      =  x.country_code
                  AND cpr.contribution_date =  x.contribution_date
                  AND (    TRIM(cpr.payment_type) =  TRIM(x.payment_type)
                        OR (    TRIM(cpr.payment_type) IS NULL
                            AND TRIM(x.payment_type) IS NULL));
          ELSE
            UPDATE comms_payments_received cpr
              SET cpr.commissionable       = 'E',
                  cpr.processed_ind        = 'TF',
                  cpr.processed_desc       = 'Failed: Commissionable flag Error for ' || 
                                             'Country ' || substr(x.country_code || '  ', 1, 2) ||
                                             ', Date ' || substr(x.contribution_date || '          ', 1, 10) ||
                                             'and PmtType ' || substr('"' || x.payment_type || '"               ', 1, 12) ||
                                             '- ' || trim(substr(lv_result, 2, 100)),
                  cpr.last_update_datetime = ld_calculation_date,
                  cpr.username             = pv_username
            WHERE     cpr.processed_ind     <> 'Y'
                  AND cpr.country_code      =  x.country_code
                  AND cpr.contribution_date =  x.contribution_date
                  AND (    TRIM(cpr.payment_type) =  TRIM(x.payment_type)
                        OR (    TRIM(cpr.payment_type) IS NULL
                            AND TRIM(x.payment_type) IS NULL));
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            l_return_msg := 'Failed: Update of comms_payments_received failed: ' || sqlerrm;
            commissions_pkg.write_to_file(  g_log_file_name,'Failed: Update of comms_payments_received failed: ' || sqlerrm);
            RAISE;
        END;
        dbms_output.put_line('Country ('|| x.country_code || 
                          '), Date (' || x.contribution_date || 
                       ') and Payment Type (' || x.payment_type || 
                           ') resulted in: ' || lv_commissionable || '(' || substr(lv_result, 2) || ')');
      END LOOP;
      -- 1.4 end
      -- Getting Payment to calculate commissions on
      FOR x IN c_get_payments_to_calc LOOP
        BEGIN
          -- Setting the logger values in case of errors
          logger.append_param(l_params, 'Action:', 'Application Id: '|| x.application_id);
          dbms_output.put_line('processing Appl Id ('|| x.application_id || '), PERSON_CODE (' 
                                                     || x.person_code || ') and CONTRIBUTION DATE (' 
                                                     || x.contribution_date || ')...');

          commissions_pkg.write_to_file(  g_log_file_name,'Processing Information For :'||
                                                        x.application_id || '), PERSON_CODE (' 
                                                     || x.person_code || ') and CONTRIBUTION DATE (' 
                                                     || x.contribution_date);
          -- Initialize changing ccs record     
          ccs.country_code         := NULL;
          ccs.product_code         := NULL;
      	  ccs.finance_receipt_no   := x.finance_receipt_no;
          ccs.poep_id              := NULL;
          ccs.person_code          := NULL;
          ccs.policy_code          := NULL;
          ccs.group_code           := NULL;
          ccs.broker_id_no         := NULL;
          ccs.company_id_no        := NULL;
          ccs.comms_perc           := NULL;
          ccs.contribution_date    := NULL;
          ccs.payment_receive_date := NULL;
          ccs.payment_receive_amt  := null;
          ccs.bu                   := null; -- 1.5

          lv_processed_cnt         := lv_processed_cnt + 1;

          BEGIN -- Not Zero Amount Check
            IF x.finance_receipt_amt = 0 THEN
              commissions_pkg.write_to_file(  g_log_file_name,'Not Calculating Commission for Zero Amounts.');
              raise_application_error(-20003,'Not Calculating Commission for Zero Amounts.');
            ELSE
              ccs.payment_receive_amt := x.finance_receipt_amt;
            END IF;
          END;  -- Not Zero Amount Check

          BEGIN -- Not NULL Finance Receipt No Check
            IF x.finance_receipt_no IS NULL THEN
              commissions_pkg.write_to_file(  g_log_file_name,'Not Calculating Commission for transactions without a Finance Receipt No.');
              raise_application_error(-20005,'Not Calculating Commission for transactions without a Finance Receipt No.');
            ELSE
              ccs.finance_receipt_no := x.finance_receipt_no;
            END IF;
          END;  -- Not Zero Amount Check

          BEGIN -- Contribution Date Check
            ccs.contribution_date    := to_date(x.contribution_date);
            EXCEPTION
              WHEN OTHERS THEN
                 UPDATE comms_payments_received 
                   SET
                       processed_ind          = 'TF',
                       processed_desc         = 'Failed: Contribution Date - ' || x.contribution_date || ' is not a valid date.',
                       last_update_datetime   = ld_calculation_date,
                       username               = pv_username
                 WHERE ROWID = x.rowid;
                dbms_output.put_line('Appl Id: '|| x.application_id || ' - CONTRIBUTION DATE ' || x.contribution_date || ' is not a valid date.');
                commissions_pkg.write_to_file(  g_log_file_name,'Failed: Contribution Date - ' || x.contribution_date || ' is not a valid date.');

                RAISE;
          END;  -- Contribution Date Check

          BEGIN -- Payment Received Date Check
            ccs.payment_receive_date := to_date(x.finance_receipt_date);
            EXCEPTION
              WHEN OTHERS THEN
                UPDATE comms_payments_received 
                   SET
                       processed_ind          = 'TF',
                       processed_desc         = 'Failed: Payment Received Date ' || x.finance_receipt_date || ' is not a valid date.',
                       last_update_datetime   = ld_calculation_date,
                       username               = pv_username
                 WHERE ROWID = x.rowid;
                dbms_output.put_line('Appl Id: '|| x.application_id || ' - PAYMENT RECEIVED DATE ' || x.finance_receipt_date || ' is not a valid date.');
                commissions_pkg.write_to_file(  g_log_file_name,'Appl Id: '|| x.application_id || ' - PAYMENT RECEIVED DATE ' || x.finance_receipt_date || ' is not a valid date.');
                RAISE;
          END;  -- Payment Received Date Check

          BEGIN -- Policy Code Check
            lv_poli_id := NULL;
            SELECT MAX(poli_id) INTO lv_poli_id
              FROM ohi_policies
             WHERE policy_code = x.policy_code
             GROUP BY policy_code;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                UPDATE comms_payments_received 
                   SET
                       processed_ind          = 'TF',
                       processed_desc         = 'Failed: Policy Code '|| x.policy_code || ' does not exist',
                       last_update_datetime   = ld_calculation_date,
                       username               = pv_username
                 WHERE ROWID = x.rowid;
                dbms_output.put_line('Appl Id: '|| x.application_id || ' - POLICY_CODE '|| x.policy_code || ' does not exist.');
                commissions_pkg.write_to_file(  g_log_file_name,'Appl Id: '|| x.application_id || ' - POLICY_CODE '|| x.policy_code || ' does not exist.');
                RAISE;
          END;  -- Policy Code Check
          IF lv_poli_id > 0 THEN
            ccs.policy_code          := x.policy_code;
          END IF;

          BEGIN -- Person Code Check
            lv_inse_id := NULL;
            SELECT MAX(inse_id) INTO lv_inse_id
              FROM ohi_insured_entities
             WHERE inse_code = x.person_code
             GROUP BY inse_code;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                UPDATE comms_payments_received 
                   SET
                       processed_ind          = 'TF',
                       processed_desc         = 'Failed: Person Code '|| x.person_code || ' does not exist',
                       last_update_datetime   = ld_calculation_date,
                       username               = pv_username
                 WHERE ROWID = x.rowid;
                dbms_output.put_line('Appl Id: '|| x.application_id || ' - PERSON_CODE '|| x.person_code || ' does not exist.');
                commissions_pkg.write_to_file(  g_log_file_name,'Appl Id: '|| x.application_id || ' - PERSON_CODE '|| x.person_code || ' does not exist.');
                RAISE;
          END;  -- Person Code Check
          IF lv_inse_id > 0 THEN
            ccs.person_code          := x.person_code;
          END IF;

          BEGIN -- Product Code Check
            lv_enpr_id := NULL;
            SELECT MAX(enpr_id) INTO lv_enpr_id
              FROM ohi_products
             WHERE product_code = x.product_code
             GROUP BY product_code;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                UPDATE comms_payments_received 
                   SET
                       processed_ind          = 'TF',
                       processed_desc         = 'Failed: Product Code '|| x.product_code || ' does not exist',
                       last_update_datetime   = ld_calculation_date,
                       username               = pv_username
                 WHERE ROWID = x.rowid;
                dbms_output.put_line('Appl Id: '|| x.application_id || ' - PRODUCT_CODE '|| x.product_code || ' does not exist.');
                commissions_pkg.write_to_file(  g_log_file_name,'Appl Id: '|| x.application_id || ' - PRODUCT_CODE '|| x.product_code || ' does not exist.');
                RAISE;
          END;  -- Person Code Check
          IF lv_enpr_id > 0 THEN
            ccs.product_code         := x.product_code;
          END IF;

          BEGIN -- Group Code Check
            lv_grac_id    := NULL;
            lv_group_code := NULL;
            IF trim(x.group_code) <> trim(x.policy_code) THEN
              lv_group_code := x.group_code;
            ELSE
              BEGIN
                SELECT MAX(grac.group_code) INTO lv_group_code
                  FROM ohi_policy_groups       pogr
                  JOIN ohi_policies            poli
                    ON pogr.poli_id = poli.poli_id
                  JOIN ohi_groups              grac
                    ON pogr.grac_id = grac.grac_id
                 WHERE poli.policy_code             = x.policy_code
                   AND x.contribution_date between pogr.effective_start_date and pogr.effective_end_date
                   AND poli.poli_id = (SELECT max(poli_id) FROM ohi_policies WHERE policy_code = poli.policy_code);
                     -- start 1.2
                  UPDATE comms_payments_received 
                    SET group_code             = lv_group_code,
                        last_update_datetime   = ld_calculation_date,
                        username               = pv_username
                  WHERE ROWID = x.rowid;
                  -- end 1.2

              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  UPDATE comms_payments_received 
                     SET
                         processed_ind          = 'TF',
                         processed_desc         = 'Failed: No Policy - Group link exists for Policy '|| x.policy_code || 
                                                  ' and Date ' || x.contribution_date,
                         last_update_datetime   = ld_calculation_date,
                         username               = pv_username
                   WHERE ROWID = x.rowid;
                  dbms_output.put_line('Appl Id: '|| x.application_id || ' - No POGR record found for Policy '|| x.policy_code || 
                                       ' and Date ' || x.contribution_date || '.');
                  commissions_pkg.write_to_file(  g_log_file_name,'Appl Id: '|| x.application_id || ' - No POGR record found for Policy '|| x.policy_code || 
                                       ' and Date ' || x.contribution_date || '.');
                  RAISE;
              END;
            END IF;
            SELECT MAX(grac_id) INTO lv_grac_id
              FROM ohi_groups
             WHERE group_code = lv_group_code
             GROUP BY group_code;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                UPDATE comms_payments_received 
                   SET
                       processed_ind          = 'TF',
                       processed_desc         = 'Failed: Group Code '|| lv_group_code || ' does not exist',
                       last_update_datetime   = ld_calculation_date,
                       username               = pv_username
                 WHERE ROWID = x.rowid;
                dbms_output.put_line('Appl Id: '|| x.application_id || ' - GROUP_CODE '|| lv_group_code || ' does not exist.');
                commissions_pkg.write_to_file(  g_log_file_name,'Appl Id: '|| x.application_id || ' - GROUP_CODE '|| lv_group_code || ' does not exist.');
                RAISE;
          END;  -- Group Code Check
          IF lv_grac_id > 0 THEN
            ccs.group_code           := lv_group_code;
          END IF;

          BEGIN -- POEP Id Check (Could be linked even further)
            lv_poep_id := NULL;
            SELECT MAX(poep_id) INTO lv_poep_id
              FROM ohi_enrollment_products poep
              JOIN ohi_policy_enrollments  poen
                ON poen.poen_id = poep.poen_id
             WHERE poep.enpr_id = lv_enpr_id
               AND poen.inse_id = lv_inse_id
               AND x.contribution_date between poep.effective_start_date and poep.effective_end_date
             GROUP BY poen.inse_id, poep.enpr_id;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                UPDATE comms_payments_received 
                   SET
                       processed_ind          = 'TF',
                       processed_desc         = 'Failed: Policy Enrollment Product record for ENPR '|| lv_enpr_id || ', INSE ' || lv_inse_id 
                                                || ' and Contr Dt ' || x.contribution_date || ' does not exist',
                       last_update_datetime   = ld_calculation_date,
                       username               = pv_username
                 WHERE ROWID = x.rowid;
                dbms_output.put_line('Appl Id: '|| x.application_id || ' - POEP record for ENPR '|| lv_enpr_id || ', INSE ' || lv_inse_id 
                                                || ' and Contr Dt ' || x.contribution_date || ' does not exist.');
                commissions_pkg.write_to_file(  g_log_file_name,'Appl Id: '|| x.application_id || ' - POEP record for ENPR '|| lv_enpr_id || ', INSE ' || lv_inse_id 
                                                || ' and Contr Dt ' || x.contribution_date || ' does not exist.');
                RAISE;
          END;  -- POEP Id Check
          IF lv_poep_id > 0 THEN
            ccs.poep_id            := lv_poep_id;
          END IF;

          BEGIN -- Policy Groups Check
            lv_pogr_id := NULL;
            SELECT MAX(pogr_id) INTO lv_pogr_id
              FROM ohi_policy_groups       pogr
              JOIN ohi_policies            poli
                ON pogr.poli_id = poli.poli_id
              JOIN ohi_groups              grac
                ON pogr.grac_id = grac.grac_id
             WHERE poli.policy_code             = x.policy_code
               AND grac.group_code              = ccs.group_code
               AND x.contribution_date between pogr.effective_start_date and pogr.effective_end_date
             GROUP BY poli.policy_code, grac.group_code;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                UPDATE comms_payments_received 
                   SET
                       processed_ind          = 'TF',
                       processed_desc         = 'Failed: Policy - Group link does not exist for Policy '|| x.policy_code 
                                                || ', Group ' || ccs.group_code || ' and Date ' || x.contribution_date,
                       last_update_datetime   = ld_calculation_date,
                       username               = pv_username
                 WHERE ROWID = x.rowid;
                commissions_pkg.write_to_file(  g_log_file_name,'Appl Id: '|| x.application_id || ' - POGR record for Policy '|| x.policy_code || ', Group ' || ccs.group_code || 
                                     ' and Date ' || x.contribution_date || ' does not exist.');
                dbms_output.put_line('Appl Id: '|| x.application_id || ' - POGR record for Policy '|| x.policy_code || ', Group ' || ccs.group_code || 
                                     ' and Date ' || x.contribution_date || ' does not exist.');
                RAISE;
          END;  -- Policy Groups Check


            lv_broker_id := NULL;
            lv_company_id := NULL;
            -- 1.6 Start Resigned member checks
            -- need to allow resigned members through do not fail as created financial discrepencies between fusion and self-build
            -- credit memo's from fusion will handle resigned member reversals for the broker commission portion

        /*    BEGIN 
              SELECT MAX(company_id_no), MAX(broker_id_no) 
                  INTO lv_company_id, lv_broker_id
                  FROM ohi_policy_brokers      pobr
                  JOIN ohi_policies            poli
                    ON pobr.poli_id = poli.poli_id
                  JOIN ohi_policy_enrollments  poen
                    ON pobr.poli_id = poen.poli_id
                  JOIN ohi_insured_entities    inse
                    ON poen.inse_id = inse.inse_id
                  JOIN ohi_enrollment_products poep
                    ON poen.poen_id = poep.poen_id
                  JOIN ohi_policy_groups       pogr
                    ON poli.poli_id = pogr.poli_id
                  JOIN ohi_groups              grac
                    ON pogr.grac_id = grac.grac_id
                  JOIN ohi_products            enpr
                    ON poep.enpr_id                 = enpr.enpr_id  
                  JOIN comms_payments_received cpr
                  ON cpr.policy_code = poli.policy_code
                  AND cpr.person_code = inse.inse_code
              WHERE poli.policy_code             = x.policy_code
                AND inse.inse_code               = x.person_code
                 AND grac.group_code             = ccs.group_code
              --  AND enpr.product_code            = x.product_code -- cannot check product as they may have changed products but are still active
             GROUP BY grac.group_code,ENPR.PRODUCT_CODE,POLI.POLICY_CODE, INSE.INSE_CODE,cpr.contribution_date
             HAVING  MAX(poep.effective_end_Date)  < TRUNC(cpr.contribution_Date);
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                 NULL;
            END;  */

        --   IF (lv_company_id IS NULL AND lv_broker_id IS NULL) THEN -- 1.5 
        
        -- check the actual status of the member if resigned first run resigned check otherwise continue with normal check
        lv_resigned_member := FALSE;
        
         IF check_resigned_member(
                                                                     p_policy_code           => x.policy_code,
                                                                     p_contribution_date => x.contribution_date
                                                                    ) THEN
              BEGIN
                  lv_resigned_member := TRUE;
                  commissions_pkg.write_to_file(  g_log_file_name,'Appl Id: ' || x.application_id || ' - Policy Code ' || x.policy_code || ' is a resigned member.');
             
               -- get resigned members latest values
                  SELECT MAX(company_id_no), MAX(broker_id_no), max(poep.poep_id) INTO lv_company_id, lv_broker_id, lv_poep_id1
                    FROM ohi_policy_brokers      pobr
                    JOIN ohi_policies            poli
                      ON     pobr.poli_id = poli.poli_id
                    JOIN ohi_policy_enrollments  poen
                      ON     pobr.poli_id = poen.poli_id
                    JOIN ohi_insured_entities    inse
                      ON     poen.inse_id = inse.inse_id
                    JOIN ohi_enrollment_products poep
                      ON     poen.poen_id = poep.poen_id
                    JOIN ohi_policy_groups       pogr
                      ON     poli.poli_id = pogr.poli_id
                    JOIN ohi_groups              grac
                      ON     pogr.grac_id = grac.grac_id
                    JOIN ohi_products            enpr
                      ON     poep.enpr_id                 = enpr.enpr_id
                   WHERE     poli.policy_code             = x.policy_code
                         AND inse.inse_code               = x.person_code
                         --  1.7 Limit to the correct Policy Broker
                         AND x.contribution_date between pobr.effective_start_date and pobr.effective_end_date 
                         AND grac.group_code              = ccs.group_code
                         AND enpr.product_code            = x.product_code
                   GROUP BY poli.policy_code, inse.inse_code, grac.group_code, enpr.product_code;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                  
                              UPDATE comms_payments_received 
                                 SET
                                     processed_ind          = 'TF',
                                     processed_desc         = 'Failed: Policy - Broker/Company link does not exist for Policy '|| x.policy_code 
                                                              || ', Person ' || x.person_code || ', Group ' || ccs.group_code || ', Product ' || x.product_code 
                                                              || ' and Date ' || x.contribution_date,
                                     last_update_datetime   = ld_calculation_date,
                                     username               = pv_username
                               WHERE ROWID = x.rowid;
                              dbms_output.put_line('Appl Id: '|| x.application_id || ' - POBR record for Policy '|| x.policy_code || ', Person ' || x.person_code 
                                                              || ', Group ' || ccs.group_code || ', Product ' || x.product_code || ' and Date ' || x.contribution_date || ' does not exist.');
                              RAISE;
                              WHEN OTHERS THEN
                                  UPDATE comms_payments_received 
                                 SET
                                     processed_ind          = 'TF',
                                     processed_desc         = 'Unexpected error occured -  for Policy '|| x.policy_code 
                                                              || ', Person ' || x.person_code || ', Group ' || ccs.group_code || ', Product ' || x.product_code 
                                                              || ' and Date ' || x.contribution_date,
                                     last_update_datetime   = ld_calculation_date,
                                     username               = pv_username
                               WHERE ROWID = x.rowid;
               END;  -- 1.5 END OF resigned member check   
               
            ELSE   
               BEGIN -- Broker Id Check  

                  SELECT MAX(company_id_no), MAX(broker_id_no) INTO lv_company_id, lv_broker_id
                    FROM ohi_policy_brokers      pobr
                    JOIN ohi_policies            poli
                      ON     pobr.poli_id = poli.poli_id
                    JOIN ohi_policy_enrollments  poen
                      ON     pobr.poli_id = poen.poli_id
                    JOIN ohi_insured_entities    inse
                      ON     poen.inse_id = inse.inse_id
                    JOIN ohi_enrollment_products poep
                      ON     poen.poen_id = poep.poen_id
                         AND x.contribution_date between poep.effective_start_date and poep.effective_end_date
                    JOIN ohi_policy_groups       pogr
                      ON     poli.poli_id = pogr.poli_id
                         AND x.contribution_date between pogr.effective_start_date and pogr.effective_end_date
                    JOIN ohi_groups              grac
                      ON     pogr.grac_id = grac.grac_id
                    JOIN ohi_products            enpr
                      ON     poep.enpr_id        = enpr.enpr_id
                   WHERE     poli.policy_code    = x.policy_code
                         AND inse.inse_code      = x.person_code
                         AND poep.poep_id        = get_poep_id(x.contribution_date, x.product_code, x.policy_code, x.person_code)
                         --  1.7 Limit to the correct Policy Broker
                         AND x.contribution_date between pobr.effective_start_date and pobr.effective_end_date 
                         AND grac.group_code     = ccs.group_code
                         AND enpr.product_code   = x.product_code
                   GROUP BY poli.policy_code, inse.inse_code, grac.group_code, enpr.product_code;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                  
                              UPDATE comms_payments_received 
                                 SET
                                     processed_ind          = 'TF',
                                     processed_desc         = 'Failed: Policy - Broker/Company link does not exist for Policy '|| x.policy_code 
                                                              || ', Person ' || x.person_code || ', Group ' || ccs.group_code || ', Product ' || x.product_code 
                                                              || ' and Date ' || x.contribution_date,
                                     last_update_datetime   = ld_calculation_date,
                                     username               = pv_username
                               WHERE ROWID = x.rowid;
                              dbms_output.put_line('Appl Id: '|| x.application_id || ' - POBR record for Policy '|| x.policy_code || ', Person ' || x.person_code 
                                                              || ', Group ' || ccs.group_code || ', Product ' || x.product_code || ' and Date ' || x.contribution_date || ' does not exist.');
                              RAISE;
                              WHEN OTHERS THEN
                                  UPDATE comms_payments_received 
                                 SET
                                     processed_ind          = 'TF',
                                     processed_desc         = 'Unexpected error occured -  for Policy '|| x.policy_code 
                                                              || ', Person ' || x.person_code || ', Group ' || ccs.group_code || ', Product ' || x.product_code 
                                                              || ' and Date ' || x.contribution_date,
                                     last_update_datetime   = ld_calculation_date,
                                     username               = pv_username
                               WHERE ROWID = x.rowid;
                      END;  -- Broker Id Check    
          END IF; -- 1.5

          IF lv_broker_id > 0 THEN
            BEGIN -- Company Id Check
              ccs.broker_id_no       := lv_broker_id;
              IF 0 < length(lv_company_id) THEN
                NULL;
              ELSE
                BEGIN
                  SELECT MAX(company_id_no) INTO lv_company_id
                    FROM broker
                   WHERE broker_id_no             = lv_broker_id
                   GROUP BY broker_id_no;
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      UPDATE comms_payments_received 
                         SET
                             processed_ind          = 'TF',
                             processed_desc         = 'Failed: Broker ' || lv_broker_id || ' does not link to a valid Company',
                             last_update_datetime   = ld_calculation_date,
                             username               = pv_username
                       WHERE ROWID = x.rowid;
                      dbms_output.put_line('Appl Id: ' || x.application_id || ' - Broker ' || lv_broker_id || ' does not link to a valid Company.');
                      commissions_pkg.write_to_file(  g_log_file_name,'Appl Id: ' || x.application_id || ' - Broker ' || lv_broker_id || ' does not link to a valid Company.');
                      RAISE;
                END;
              END IF;
            END; -- Company Id Check
          END IF;

            ccs.company_id_no         := lv_company_id;
            IF 0 < length(lv_broker_id) THEN
              NULL;
            ELSE
              BEGIN
                lv_broker_id              := get_broker_from_comp(lv_company_id);
                ccs.broker_id_no          := lv_broker_id;
              END;
            END IF;


          BEGIN -- Company Country Check
            lv_country_code := NULL;
            SELECT MAX(country_code) INTO lv_country_code
              FROM company_country
             WHERE company_id_no = lv_company_id
               AND country_code = x.country_code
               AND x.contribution_date between effective_start_date and effective_end_date
             GROUP BY company_id_no, country_code;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                UPDATE comms_payments_received 
                   SET
                       processed_ind          = 'TF',
                       processed_desc         = 'Failed: Company ' || lv_company_id || ' does not trade in Country ' || x.country_code||' for date '|| x.contribution_date,
                       last_update_datetime   = ld_calculation_date,
                       username               = pv_username
                 WHERE ROWID = x.rowid;
                dbms_output.put_line('Appl Id: '|| x.application_id || ' - COMPANY_COUNTRY record for Company '|| lv_company_id || ' and Country ' || x.country_code 
                                                || ' does not exist.');
                commissions_pkg.write_to_file(  g_log_file_name,'Appl Id: '|| x.application_id || ' - COMPANY_COUNTRY record for Company '|| lv_company_id || ' and Country ' || x.country_code 
                                                || ' does not exist.');
                RAISE;
          END;  -- Company Country Check
          IF lv_country_code IS NOT NULL THEN
            ccs.country_code            := lv_country_code;
          END IF;

          BEGIN -- Exchange Rate Check
            lv_currency_code      := NULL;
        		lv_exch_currency_code := NULL;
        		ln_pref_curr_id       := trim(x.currency_code);
    		    ln_exch_rate          := null;
    		    lv_pref_curr_required := null;

        		OPEN c_check_currency_code;
    		    FETCH c_check_currency_code into lv_pref_curr_required,lv_currency_code;
    		    CLOSE c_check_currency_code;

        		IF lv_pref_curr_required = 'Y' AND lv_currency_code IS NULL THEN
    		      raise_application_error(-20007,'No preferred currency set for brokerage.');
        		ELSIF lv_pref_curr_required = 'Y' AND lv_currency_code IS NOT NULL THEN	
      		    IF ln_pref_curr_id IS NULL THEN
                BEGIN
          		    SELECT c.code INTO ln_pref_curr_id
                    FROM POL_POLICIES_V@POLICIES.LIBERTY.CO.ZA a,
                         FCOD_PREFCUR@POLICIES.LIBERTY.CO.ZA c
                   WHERE tec_ind_last_version = 'Y'
                     AND a.code = ccs.policy_code
                     AND A.prefcur_id = c.ID;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN NULL;
                END;  
    	        END IF;
      		    IF ln_pref_curr_id IS NULL THEN
                BEGIN
          		  	SELECT c.code INTO ln_pref_curr_id
                    FROM POL_GROUP_ACCOUNTS_V@POLICIES.LIBERTY.CO.ZA a,
                         FCOD_PREFCUR@POLICIES.LIBERTY.CO.ZA c
                   WHERE object_version_number = (SELECT MAX(object_version_number)
                                                    FROM POL_GROUP_ACCOUNTS_V@POLICIES.LIBERTY.CO.ZA
                                                   WHERE a.code = code)
                     AND a.code = ccs.group_code
                     AND A.prefcur_id = c.ID;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN NULL;
                END;  
    	        END IF;
              IF ln_pref_curr_id IS NOT NULL THEN
                IF ln_pref_curr_id = lv_currency_code THEN
                  ln_exch_rate := 1;
                  lv_exch_currency_code := lv_currency_code;
                ELSE  
                  SELECT e.rate,  c_to.code to_currency_code  INTO ln_exch_rate, lv_exch_currency_code
                    FROM OHI_CLAIMS_VIEWS_OWNER.OHI_CURRENCIES_V@CLAIMS.LIBERTY.CO.ZA c_from,    
                         OHI_CLAIMS_VIEWS_OWNER.OHI_EXCHANGE_RATES_V@CLAIMS.LIBERTY.CO.ZA e,    
                         OHI_CLAIMS_VIEWS_OWNER.OHI_CURRENCIES_V@CLAIMS.LIBERTY.CO.ZA c_to    
                   WHERE e.curr_id_from = c_from.ID    
                     AND e.curr_id_to = c_to.id
                     AND e.rate_context IS NULL
                     AND c_from.code = ln_pref_curr_id
                     AND c_to.code = lv_currency_code
                     AND ccs.payment_receive_date BETWEEN e.start_date AND NVL(e.end_Date,TRUNC(ld_calculation_date));
                END IF;     
        				IF ln_exch_rate IS NULL THEN
                  RAISE NO_DATA_FOUND;
                END IF;				   
    		      ELSE
    		        RAISE E_NO_PREF_CUR;
    		      END IF;				
        			ccs.exchange_rate := ln_exch_rate;
    		    	ccs.exchange_rate_currency_code := lv_exch_currency_code;
    	    		ccs.payment_currency := ln_pref_curr_id;
    		    ELSE 
      		   	ccs.exchange_rate := 1;
    	    		ccs.exchange_rate_currency_code := ln_pref_curr_id;
    	    		ccs.payment_currency := ln_pref_curr_id;
        		END IF;
          EXCEPTION
      		  WHEN E_NO_PREF_CUR THEN
              UPDATE comms_payments_received 
                 SET processed_ind          = 'TF',
                     processed_desc         = 'Failed: No preferred currency found on OHI for Policy' || ccs.policy_code || ' or Group ' || ccs.group_code,
                     last_update_datetime   = ld_calculation_date,
                     username               = pv_username
               WHERE ROWID = x.ROWID;
              dbms_output.put_line('Appl Id: '|| x.application_id || ' - No preferred currency found on OHI for Policy' || ccs.policy_code || ' or Group ' || ccs.group_code);		  
              commissions_pkg.write_to_file(  g_log_file_name,'Appl Id: '|| x.application_id || ' - No preferred currency found on OHI for Policy' || ccs.policy_code || ' or Group ' || ccs.group_code);		
              RAISE;
            WHEN NO_DATA_FOUND THEN
              UPDATE comms_payments_received 
                 SET processed_ind          = 'TF',
                     processed_desc         = 'Failed: Current exchange rate for Brokerage ' || lv_company_id || ' and currency code ' || ln_pref_curr_id || '-->' || lv_currency_code || ' does not exist on OHI',
                     last_update_datetime   = ld_calculation_date,
                     username               = pv_username
               WHERE ROWID = x.ROWID;
              dbms_output.put_line('Appl Id: '|| x.application_id ||' Current exchange rate for Brokerage ' || lv_company_id || ' and currency code ' || ln_pref_curr_id || '-->' || lv_currency_code || ' does not exist on OHI');
              commissions_pkg.write_to_file(  g_log_file_name,'Appl Id: '|| x.application_id ||' Current exchange rate for Brokerage ' || lv_company_id || ' and currency code ' || ln_pref_curr_id || '-->' || lv_currency_code || ' does not exist on OHI');
              RAISE;
          END;  -- Exchange Rate Check

          IF lv_country_code IS NOT NULL THEN
            ccs.country_code            := lv_country_code;
          END IF;
          -- Deciding on the Commission Percentage - LS-2207
          BEGIN

            lv_comm_perc            := NULL;
            l_percentage            := NULL; -- 1.5

            BEGIN
             -- 1.5 get the % for partial payments if it is applicable
             SELECT DISTINCT comms_percentage 
               INTO l_percentage
               FROM comms_on_partial_receipt 
              WHERE x.contribution_date BETWEEN effective_Start_date AND effective_end_date -- issue as based on trx date
               AND NVL(x.partial_yn,'N')     = 'Y'
               AND group_code           = ccs.group_code;
            
            EXCEPTION
            
             WHEN no_data_found then
                null;
             WHEN OTHERS THEN
                NULL;
            
            END;
            
            --1.5 get the group % if this is a resigned member
            IF lv_resigned_member THEN
                commissions_pkg.get_percentage(
                                               p_group            => ccs.group_code
                                              ,p_product        => ccs.product_code
                                              ,p_percentage => l_percentage
                                              ,p_description => l_description
                                              ,p_return_msg => l_return_msg);
               commissions_pkg.write_to_file(  g_log_file_name,'getting the group % for a resigned member: ' || l_percentage);
            END IF;
             --1.5 get the group % if this is a resigned member

            IF l_percentage IS NOT NULL THEN -- 1.5
               NULL;
            ELSE   
                commissions_pkg.get_percentage(p_date => to_date(x.contribution_date)
                                              ,p_poep => lv_poep_id
                                              ,p_percentage => l_percentage
                                              ,p_description => l_description
                                              ,p_return_msg => l_return_msg);
            END IF;
            
            commissions_pkg.write_to_file(  g_log_file_name,'% information is '|| to_date(x.contribution_date) || ' - ' ||  lv_poep_id || ' - ' ||  l_percentage || ' - ' || l_description || ' - ' || l_return_msg);
            IF l_percentage IS NOT NULL THEN
              ccs.comms_perc         := nvl(check_resigned_status(ccs.broker_id_no, ccs.company_id_no, ccs.contribution_date), ROUND(l_percentage, 2)); --if broker/brokerage is resigned, percentage should be 0
              lv_processed_desc      := l_return_msg;
                commissions_pkg.write_to_file(  g_log_file_name,'getting resigned status:  -' || l_return_msg);
            ELSE
              dbms_output.put_line('Appl Id: '|| x.application_id || ' - No Commission Percentage found for Any Combination. ' || lv_processed_desc);
              commissions_pkg.write_to_file(  g_log_file_name,'Appl Id: '|| x.application_id || ' - No Commission Percentage found for Any Combination. ' || lv_processed_desc);
              raise_application_error(-20004,'No Commission Percentage found for Any Combination.');
            END IF;
             commissions_pkg.write_to_file(  g_log_file_name,'setting comms calc snapshot values  ');
             
            -- Setting the rest of the Values
            ccs.comms_calculated_amt      := ROUND(ccs.payment_receive_amt * ccs.comms_perc / 100, 4);
            ccs.comms_calculated_exch_amt := ROUND(ccs.comms_calculated_amt * ccs.exchange_rate, 4);
            ccs.calculation_datetime      := ld_calculation_date; 
            ccs.comms_calc_type_code      := 'T';
            ccs.invoice_no                := NULL;
            ccs.last_update_datetime      := ld_calculation_date;
            ccs.username                  := pv_username;
            ccs.bu                        := x.bu; -- 1.5
             commissions_pkg.write_to_file(  g_log_file_name,'Appl Id: '|| x.application_id || ' - Record: ' || 'coun' || ccs.country_code || ' prod' ||  ccs.product_code 
                                            || ' poep' ||  ccs.poep_id || ' inse' ||  ccs.person_code || ' poli' ||  ccs.policy_code || ' grac' 
                                            ||  ccs.group_code || ' brok' ||  ccs.broker_id_no || ' comp' ||  ccs.company_id_no || ' perc' 
                                            ||  ccs.comms_perc || ' cdte' ||  ccs.contribution_date || ' pmnt' ||  ccs.payment_receive_amt 
                                            || ' camt' ||  ccs.comms_calculated_amt|| ' cant-exch' ||  ccs.comms_calculated_exch_amt
                                            || ' exch' ||  ccs.exchange_rate || ' paym-curr' ||  ccs.payment_currency
                                            || ' exch-curr' ||  ccs.exchange_rate_currency_code);
            ccs.comms_calc_snapshot_no := comms_calc_snapshot_seq.nextval();
            cct.comms_calc_snapshot_no := ccs.comms_calc_snapshot_no;
            -- Writing the Values to Comms Payments Received
            l_insert_cct                    := TRUE;    -- LS-1061B      
          
             INSERT INTO comms_calc_snapshot VALUES ccs;
           
            --LS-1061B only do insert into cct and update of cpr if no dup_val_on_index exception on insert of ccs  
            BEGIN
              IF l_insert_cct THEN
                BEGIN
                  INSERT INTO comms_calc_trace VALUES cct;                      -- LS-1061
                  -- Update Comms Payments Received on Success
                  UPDATE comms_payments_received 
                    SET processed_ind          = 'TY',
                        processed_desc         = lv_processed_desc,
                        last_update_datetime   = ld_calculation_date,
                        username               = pv_username,
                        comms_calc_snapshot_no = ccs.comms_calc_snapshot_no     -- LS-1061
                  WHERE ROWID = x.ROWID;   
                  lv_processed_success         := lv_processed_success + 1;
                EXCEPTION  
                  WHEN OTHERS THEN
                    commissions_pkg.write_to_file(  g_log_file_name,'Failed: Write to trace file or update of comms_payments_received: ' || sqlerrm  
                                    || ' ' || ccs.comms_calc_snapshot_no);
                    l_return_msg := 'Failed: Write to trace file or update of comms_payments_received: ' || sqlerrm  
                                    || ' ' || ccs.comms_calc_snapshot_no;
                    RAISE;
                END;                    
              END IF; 
            EXCEPTION  
              WHEN OTHERS THEN
                l_return_msg := 'Failed: Evaluation of cct insert flag new ccs: ' || sqlerrm;
                commissions_pkg.write_to_file(  g_log_file_name,'Failed: Evaluation of cct insert flag new ccs: ' || sqlerrm);
                RAISE;        
            END; -- End of LS-1061B
          END;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
            -- dbms_output.put_line('Appl Id: '|| x.application_id || ' - No OHI Data Found.');
          WHEN DUP_VAL_ON_INDEX THEN
          l_insert_cct                       := FALSE;    -- LS-1061B     
    	     UPDATE comms_calc_snapshot 
               SET payment_receive_amt       = payment_receive_amt+ccs.payment_receive_amt,
                   comms_calculated_amt      = comms_calculated_amt+ccs.comms_calculated_amt,
                   comms_calculated_exch_amt = comms_calculated_exch_amt+ccs.comms_calculated_exch_amt,
    	             last_update_datetime      = ld_calculation_date,
                   username                  = pv_username
             WHERE country_code                = ccs.country_code
               AND product_code                = ccs.product_code
               AND poep_id                     = ccs.poep_id
               AND person_code                 = ccs.person_code
               AND policy_code                 = ccs.policy_code
               AND group_code                  = ccs.group_code
               AND broker_id_no                = ccs.broker_id_no
               AND company_id_no               = ccs.company_id_no
               AND contribution_date           = ccs.contribution_date
               AND payment_receive_date        = ccs.payment_receive_date
               AND finance_receipt_no          = ccs.finance_receipt_no
               AND calculation_datetime        = ccs.calculation_datetime
               AND comms_calc_type_code        = ccs.comms_calc_type_code
               AND payment_currency            = ccs.payment_currency
               AND exchange_rate_currency_code = ccs.exchange_rate_currency_code;   
  
  
               commissions_pkg.write_to_file(  g_log_file_name,'About to update the comms_payments_received: ' || ccs.policy_code);
            -- Update Comms Payments Received on Success
            UPDATE comms_payments_received 
               SET
                   processed_ind          = 'TY',
                   processed_desc         = lv_processed_desc,
                   LAST_UPDATE_DATETIME   = ld_calculation_date,
                   username               = pv_username,
                   -- Start of LS-1061B
                   comms_calc_snapshot_no = 
                     (SELECT comms_calc_snapshot_no FROM comms_calc_snapshot 
                        WHERE country_code                = ccs.country_code
                          AND product_code                = ccs.product_code
                          AND poep_id                     = ccs.poep_id
                          AND person_code                 = ccs.person_code
                          AND policy_code                 = ccs.policy_code
                          AND group_code                  = ccs.group_code
                          AND broker_id_no                = ccs.broker_id_no
                          AND company_id_no               = ccs.company_id_no
                          AND contribution_date           = ccs.contribution_date
                          AND payment_receive_date        = ccs.payment_receive_date
                          AND finance_receipt_no          = ccs.finance_receipt_no
                          AND calculation_datetime        = ccs.calculation_datetime
                          AND comms_calc_type_code        = ccs.comms_calc_type_code
                          AND PAYMENT_CURRENCY            = CCS.PAYMENT_CURRENCY
                          AND exchange_rate_currency_code = ccs.exchange_rate_currency_code)                   
                   -- End of LS-1061B 
             WHERE ROWID = x.rowid;   
            lv_processed_success         := lv_processed_success + 1;
          WHEN OTHERS THEN
            IF SQLCODE = -20003 THEN
              dbms_output.put_line('Appl Id: '|| x.application_id || ' - Zero Amounts are not Processed.');
              UPDATE comms_payments_received 
                 SET
                     processed_ind          = 'TY',
                     processed_desc         = 'Success: Zero amounts are not processed',
                     last_update_datetime   = ld_calculation_date,
                     username               = pv_username
               WHERE ROWID = x.rowid;
            ELSIF SQLCODE = -20004 THEN
              -- dbms_output.put_line('Appl Id: '|| x.application_id || ' - No Commission Percentage found for Any Combination.');
              UPDATE comms_payments_received 
                 SET
                     processed_ind          = 'TF',
                     processed_desc         = 'Failed: ' || l_return_msg,
                     last_update_datetime   = ld_calculation_date,
                     username               = pv_username
               WHERE ROWID = x.rowid;
            ELSIF SQLCODE = -20005 THEN
              dbms_output.put_line('Appl Id: '|| x.application_id || ' - Not Calculating Commission for transactions without a Finance Receipt No.');
              UPDATE comms_payments_received 
                 SET
                     processed_ind          = 'TF',
                     processed_desc         = 'Failed: Not Calculating Commission for transactions without a Finance Receipt No.',
                     last_update_datetime   = ld_calculation_date,
                     username               = pv_username
               WHERE ROWID = x.rowid;
            ELSIF SQLCODE = -20006 THEN
              lv_processed_cnt     := lv_processed_cnt - 1;
              dbms_output.put_line('Appl Id: '|| x.application_id || ' - Calculating Commission for a different Company.');
            ELSIF SQLCODE = -20007 THEN
              dbms_output.put_line('Appl Id: '|| x.application_id || ' - No preferred currency set for brokerage.');
              UPDATE comms_payments_received 
                 SET
                     processed_ind          = 'TF',
                     processed_desc         = 'Failed: Multinational Broker does not have a preferred currency set.',
                     last_update_datetime   = ld_calculation_date,
                     username               = pv_username
               WHERE ROWID = x.rowid;
            ELSE
              dbms_output.put_line('Appl Id: '|| x.application_id || ' - Other Error: ' || sqlerrm);
    		  lv_processed_desc := sqlerrm;
              UPDATE comms_payments_received 
                 SET
                     processed_ind          = 'TF',
                     processed_desc         = 'Failed: Unhandled exception: '||lv_processed_desc,
                     last_update_datetime   = ld_calculation_date,
                     username               = pv_username
               WHERE ROWID = x.rowid;
            END IF;
        END;
      END LOOP;

      COMMIT;

      --write the csv file out for the output of the run
      write_csv(g_output_file_name,'SELECT * FROM lhhcom.comms_payments_received WHERE last_update_datetime BETWEEN '||l_job_start_date||' AND SYSDATE');

      write_csv(g_output_file_name,'SELECT * FROM lhhcom.comms_calc_snapshot WHERE last_update_datetime BETWEEN '||l_job_start_date||' AND SYSDATE');

      comms_calc_pkg.recalc_changes_run(pv_username, pv_return_msg); 

      IF lv_processed_cnt = 0 AND pv_return_msg IS NULL THEN
        pv_return_msg := 'Nothing to process for Parameter set submitted';
      ELSIF lv_processed_cnt = 0 AND pv_return_msg IS NOT NULL THEN
        pv_return_msg := 'Back Dated Changes failed with: '||pv_return_msg;
      ELSIF lv_processed_success = 0 AND pv_return_msg IS NULL THEN
        pv_return_msg := 'None of the ' || lv_processed_cnt || ' records processed successfully';
      ELSIF lv_processed_success = 0 AND pv_return_msg IS NOT NULL THEN
        pv_return_msg := 'None of the ' || lv_processed_cnt || ' records processed successfully and Back Dated Changes failed with '||pv_return_msg;
      ELSIF lv_processed_success < lv_processed_cnt AND pv_return_msg IS NULL THEN
        dbms_output.put_line(lv_processed_success || ' out of ' || lv_processed_cnt || ' records processed successfully');
        -- pv_return_msg := lv_processed_success || ' out of ' || lv_processed_cnt || ' records processed successfully';
      ELSIF lv_processed_success < lv_processed_cnt AND pv_return_msg IS NOT NULL THEN
          pv_return_msg := 'Back Dated Changes failed with: '||pv_return_msg;
      ELSE
        dbms_output.put_line('All ' || lv_processed_cnt || ' records processed successfully');
        -- pv_return_msg := 'All ' || lv_processed_cnt || ' records processed successfully';
      END IF;
      dbms_output.put_line(pv_return_msg);

      ---1.3 Delete Test Runs no longer applicable start
      DELETE
        FROM comms_calc_snapshot 
       WHERE     1=1 
             AND comms_calc_type_code = 'T'
             AND comms_calc_snapshot_no IN 
                (SELECT comms_calc_snapshot_no FROM comms_calc_snapshot ccs
                  WHERE     1=1
                        AND NOT EXISTS (SELECT 'X' FROM comms_payments_received cpr 
                                         WHERE cpr.comms_calc_snapshot_no = ccs.comms_calc_snapshot_no
                                       )
                );
      COMMIT;  

      send_email(p_subject => 'Commissions Calc Run completed '||sysdate, 
                 p_message => '<html><body>The commissions Run has completed for the following combination <br><br>'||
                               'Brokerage Code '|| pn_company_id_no ||'<br><br>'||
                               'Country Code   '|| pv_country_code ||'<br><br>'||
                               'Group Code     '|| pv_group_code ||'<br><br>'||
                               'Product Code   '|| pv_product_code ||'<br><br>'||
                               'User Name     '|| pv_username ||'<br><br>'||
                               'Regards, <br><br><br> The Commissions System')
                               ;

      -- 1.3 end

    EXCEPTION
      WHEN OTHERS THEN
        logger.log_error('Unhandled Exception', l_scope, null, l_params);
        dbms_output.put_line(' - Unhandled Exception Error: ' || sqlerrm);
        ROLLBACK;
        pv_return_msg := 'System failed with error: ' || sqlerrm;
        RAISE_APPLICATION_ERROR('-000001','Approve Commissions Calculation Run Failed please see log');
    END commissions_calc_run;

    /**********************************************************************************************************************/

    PROCEDURE recalc_changes_run  (pv_username      IN  VARCHAR2,
                                   pv_return_msg    OUT VARCHAR2) 

    IS

      gc_scope_prefix       CONSTANT VARCHAR2(31)           
                                     := lower($$PLSQL_UNIT) || '.';
      l_scope                        logger_logs.scope%TYPE 
                                     := 'CommissionsSelfBuild: ' || gc_scope_prefix;
      l_params                       logger.tab_param;
      ccs                            comms_calc_snapshot%ROWTYPE;
      cct                            comms_calc_trace%ROWTYPE;            -- LS-1061   
      ld_current_date                DATE := SYSDATE;
      ln_broker_id_no                broker.broker_id_no%TYPE;
      lv_poep_id                     ohi_enrollment_products.poep_id%TYPE;
      lv_new_poep                    ohi_enrollment_products.poep_id%TYPE;
      lv_processed_desc              comms_payments_received.processed_desc%TYPE;
      l_percentage                   ohi_comm_perc.comm_perc%type;   
      l_description                  ohi_comm_perc.comm_desc%type;
      l_return_msg                   VARCHAR2(500);
      l_insert_cct                   BOOLEAN; --LS1061B
      NO_BROKER_EXCEPTION            EXCEPTION;
      lv_company_id                  ohi_policy_brokers.company_id_no%TYPE;
      E_NO_PREF_CUR                  EXCEPTION;
      lv_pref_curr_required          VARCHAR2(1);
      lv_currency_code               comms_calc_snapshot.exchange_rate_currency_code%TYPE;
      ln_exch_rate                   comms_calc_snapshot.exchange_rate%TYPE;
      lv_exch_currency_code          comms_calc_snapshot.exchange_rate_currency_code%TYPE;

      CURSOR c_get_poep_id           IS
        SELECT DISTINCT(trecalc.poep_id) AS poep_id
          FROM COMMS_RECALC              trecalc
         WHERE processed_date = ld_current_date;

      CURSOR c_get_poepid_to_change  IS
        SELECT 
               oldccs.rowid                       AS old_record_id,
               poli.poli_id, 
               oldccs.poep_id                     AS oldccs_poep_id,
               oldccs.group_code                  AS oldccs_group_code,
               oldccs.country_code                AS oldccs_country_code,
               oldccs.product_code                AS oldccs_product_code,
               oldccs.policy_code                 AS oldccs_policy_code,                        
               oldccs.person_code                 AS oldccs_person_code,                               
               oldccs.broker_id_no                AS oldccs_broker_id_no,
               oldccs.company_id_no               AS oldccs_company_id_no,
               oldccs.payment_currency            AS oldccs_payment_currency,
               oldccs.comms_perc                  AS oldccs_comms_perc,
               oldccs.finance_receipt_no          AS oldccs_finance_receipt_no,
               oldccs.payment_receive_amt         AS oldccs_payment_receive_amt,
               oldccs.payment_receive_date        AS oldccs_payment_receive_date,
               oldccs.contribution_date           AS oldccs_contribution_date,
               oldccs.exchange_rate_currency_code AS oldccs_exch_rate_curr_code,
               oldccs.calculation_datetime        AS oldccs_calculation_datetime,
               pobr.company_id_no                 AS pobr_company_id_no,
               poli.policy_code                   AS poli_policy_code,
               grps.group_code                    AS grps_group_code,
               prod.product_code                  AS prod_product_code,
               poli.poli_id                       AS poli_poli_id,
               pobr.poli_id                       AS pobr_poli_id,
               oldccs.comms_calculated_amt        AS oldccs_comms_calculated_amt,
               oldccs.comms_calculated_exch_amt   AS oldccs_comms_calc_exch_amt,
               oldccs.exchange_rate               AS oldccs_exchange_rate,
               oldccs.comms_calc_snapshot_no      AS oldccs_comms_calc_snapshot_no,  --LS-1061
               oldcct.trace_original_snapshot_no  AS old_trace_original_snapshot_no  --LS-1061       
          FROM comms_calc_snapshot                 oldccs
          LEFT OUTER 
          JOIN ohi_enrollment_products  poep
            ON poep.poep_id = get_poep_id(p_date    => to_date(oldccs.contribution_date), p_person  => oldccs.person_code, p_product => oldccs.product_code)
          LEFT OUTER 
          JOIN ohi_policy_enrollments   poen
            ON (poep.poen_id = poen.poen_id)
          LEFT OUTER 
          JOIN ohi_policies             poli
            ON (poen.poli_id = poli.poli_id )
          LEFT OUTER 
          JOIN ohi_policy_brokers       pobr
            ON (poli.poli_id = pobr.poli_id) 
           AND (oldccs.contribution_date BETWEEN pobr.effective_start_date and pobr.effective_end_date)
          LEFT OUTER 
          JOIN ohi_policy_groups        grac
            ON (poli.poli_id = grac.poli_id)
          LEFT OUTER 
          JOIN ohi_groups               grps
            ON (grac.grac_id = grps.grac_id)
          LEFT OUTER 
          JOIN ohi_insured_entities     inse
            ON (poen.inse_id = inse.inse_id)
          LEFT OUTER 
          JOIN ohi_products             prod
            ON (poep.enpr_id = prod.enpr_id)  
          LEFT OUTER 
          JOIN comms_calc_trace         oldcct                           --LS-1061
            ON (oldccs.comms_calc_snapshot_no = oldcct.comms_calc_snapshot_no)  --LS-1061                    
         WHERE oldccs.comms_calc_type_code in ( 'P', 'A') 
           AND oldccs.poep_id = lv_poep_id
      	   AND oldccs.invoice_no IS NOT NULL
         ORDER BY oldccs_contribution_date;

    	CURSOR c_check_currency_code IS	
                select company_table_type_desc, preferred_currency_code        
          from company c,            
                (select distinct bf.company_id_no, btt.company_table_type_desc, bf.effective_start_date,       
                 rank() over (partition by bf.company_id_no order by bf.effective_start_date desc) rank_no        
                   from company_function bf, company_table bt, company_table_type btt              
                  where bf.company_table_id_no = bt.company_table_id_no              
                    and bf.company_table_id_no = 6            
                    and bf.company_table_id_no = btt.company_table_id_no              
                    and bf.company_table_type_id_no = btt.company_table_type_id_no              
                    and sysdate between bf.effective_start_date and bf.effective_end_date ) b_multi_net   
          where  c.company_id_no = b_multi_net.company_id_no(+)       
              and nvl(b_multi_net.rank_no,1) = 1
    		      and c.company_id_no = lv_company_id;

    BEGIN
    	UPDATE comms_recalc
    	   SET processed_date       = ld_current_date,
    	       last_update_datetime = SYSDATE,
    	  	   username             = pv_username
    	 WHERE processed_date       = to_date(get_system_parameter('LB_HEALTH_COMMS','SYSTEM','SYSTEM_START_DATE'));

      FOR y IN c_get_poep_id LOOP
        lv_poep_id  := y.poep_id;    
        l_return_msg    := null;
        FOR x IN c_get_poepid_to_change LOOP
          l_percentage    := null;
          l_description   := null;
          ln_broker_id_no := null;
          lv_new_poep     := get_poep_id(p_date    => to_date(x.oldccs_contribution_date)
                                       , p_person  => x.oldccs_person_code
                                       , p_product => x.oldccs_product_code);
          IF lv_new_poep IS NOT NULL THEN
            commissions_pkg.get_percentage(p_date => to_date(x.oldccs_contribution_date)
                                          ,p_poep => lv_new_poep
                                          ,p_percentage => l_percentage
                                          ,p_description => l_description
                                          ,p_return_msg => l_return_msg);
          END IF;
          dbms_output.put_line('recalc POEP Id ('|| x.oldccs_poep_id || '/' || lv_new_poep || '), PERSON_CODE (' 
                                                 || x.oldccs_person_code || ') and CONTRIBUTION DATE (' 
                                                 || x.oldccs_contribution_date || ') = ' || l_percentage || '%');
          IF l_percentage IS NULL THEN
            IF x.pobr_company_id_no IS NULL THEN
              l_return_msg := 'Could not find a new Brokerage for Date ' || 
                              x.oldccs_contribution_date || ', Person ' || 
                              x.oldccs_person_code || ', Group ' || 
                              x.oldccs_group_code || ' and Product ' ||
                              x.oldccs_product_code;
            ELSE 
              NULL;
              -- Problem occurs here (duplicate record found)
              -- l_percentage := 0;
            END IF;
          ELSE 
            l_return_msg := null;
          END IF;
          BEGIN -- Exchange Rate Check
            lv_currency_code      := NULL;
        		lv_exch_currency_code := NULL;
    		    ln_exch_rate          := NULL;
    		    lv_pref_curr_required := NULL;

        		OPEN c_check_currency_code;
    		    FETCH c_check_currency_code INTO lv_pref_curr_required, lv_currency_code;
    		    CLOSE c_check_currency_code;

        		IF lv_pref_curr_required = 'Y' AND lv_currency_code IS NULL THEN
    		      raise_application_error(-20007,'No preferred currency set for brokerage.');
        		ELSIF lv_pref_curr_required = 'Y' AND lv_currency_code IS NOT NULL THEN	
              IF x.oldccs_payment_currency IS NOT NULL THEN
                IF x.oldccs_payment_currency = lv_currency_code THEN
                  ln_exch_rate := 1;
                  lv_exch_currency_code := lv_currency_code;
                ELSE  
                  SELECT e.rate,  c_to.code to_currency_code  INTO ln_exch_rate, lv_exch_currency_code
                    FROM OHI_CLAIMS_VIEWS_OWNER.OHI_CURRENCIES_V@CLAIMS.LIBERTY.CO.ZA c_from,    
                         OHI_CLAIMS_VIEWS_OWNER.OHI_EXCHANGE_RATES_V@CLAIMS.LIBERTY.CO.ZA e,    
                         OHI_CLAIMS_VIEWS_OWNER.OHI_CURRENCIES_V@CLAIMS.LIBERTY.CO.ZA c_to    
                   WHERE e.curr_id_from = c_from.ID    
                     AND e.curr_id_to = c_to.id
                     AND e.rate_context IS NULL
                     AND c_from.code = x.oldccs_payment_currency
                     AND c_to.code = lv_currency_code
                     AND x.oldccs_payment_receive_date BETWEEN e.start_date AND NVL(e.end_Date,TRUNC(SYSDATE));
                END IF;     
        				IF ln_exch_rate IS NULL THEN
                  RAISE NO_DATA_FOUND;
                END IF;				   
    		      ELSE
    		        RAISE E_NO_PREF_CUR;
    		      END IF;				
        			ccs.exchange_rate := ln_exch_rate;
    		    	ccs.exchange_rate_currency_code := lv_exch_currency_code;
    	    		ccs.payment_currency := x.oldccs_payment_currency;
    		    ELSE 
      		   	ccs.exchange_rate := 1;
    	    		ccs.exchange_rate_currency_code := x.oldccs_payment_currency;
    	    		ccs.payment_currency := x.oldccs_payment_currency;
        		END IF;
          EXCEPTION
      		  WHEN E_NO_PREF_CUR THEN
              dbms_output.put_line('Error on Old CCS Snapshot: '|| x.oldccs_comms_calc_snapshot_no || ' - No preferred currency found on OHI for Policy ' || x.oldccs_policy_code || ' or Group ' || x.oldccs_group_code);		  
          		RAISE;
            WHEN NO_DATA_FOUND THEN
              dbms_output.put_line('Error on Old CCS Snapshot: '|| x.oldccs_comms_calc_snapshot_no || ' - Current exchange rate for Brokerage ' || lv_company_id || ' and currency code ' || x.oldccs_payment_currency || '-->' || lv_currency_code || ' does not exist on OHI');
              RAISE;
          END;  -- Exchange Rate Check
          IF     l_percentage             IS NOT NULL
             AND x.pobr_company_id_no     IS NOT NULL
             AND    (l_percentage         <> x.oldccs_comms_perc
                  OR x.pobr_company_id_no <> x.oldccs_company_id_no 
                  OR x.grps_group_code    <> x.oldccs_group_code
                  OR x.prod_product_code  <> x.oldccs_product_code) THEN
            BEGIN
              ln_broker_id_no := get_broker_from_comp(x.pobr_company_id_no);
              IF ln_broker_id_no IS NULL THEN
                RAISE NO_BROKER_EXCEPTION;
              END IF;
              BEGIN -- Write the negative CCS record
                ccs.country_code                := x.oldccs_country_code;
                ccs.product_code                := x.oldccs_product_code;
                ccs.poep_id                     := lv_poep_id;
                ccs.person_code                 := x.oldccs_person_code;
                ccs.policy_code                 := x.oldccs_policy_code;
                ccs.group_code                  := x.oldccs_group_code;
                ccs.broker_id_no                := x.oldccs_broker_id_no;
                ccs.company_id_no               := x.oldccs_company_id_no;
                ccs.comms_perc                  := x.oldccs_comms_perc;
                ccs.contribution_date           := x.oldccs_contribution_date;
                ccs.payment_receive_date        := x.oldccs_payment_receive_date;
                ccs.finance_receipt_no          := x.oldccs_finance_receipt_no;
                ccs.calculation_datetime        := ld_current_date;
                ccs.comms_calc_type_code        := 'R';
                ccs.payment_receive_amt         := x.oldccs_payment_receive_amt*-1;
                ccs.comms_calculated_amt        := x.oldccs_comms_calculated_amt*-1;
                ccs.exchange_rate               := x.oldccs_exchange_rate;
                ccs.payment_currency            := x.oldccs_payment_currency;
                ccs.exchange_rate_currency_code := x.oldccs_exch_rate_curr_code;
                ccs.comms_calculated_exch_amt   := x.oldccs_comms_calc_exch_amt*-1;
                ccs.invoice_no                  := null;
                ccs.last_update_datetime        := sysdate;
                ccs.username                    := pv_username;
                ccs.comms_calc_snapshot_no      := comms_calc_snapshot_seq.NEXTVAL();  --LS-1061
                l_insert_cct                    := TRUE;    -- LS-1061B
                insert into comms_calc_snapshot values ccs;              
              EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                  l_insert_cct                  := FALSE;    --LS-1061B
                  dbms_output.put_line('Duplicate Reversal Record for POEP_ID ' || lv_poep_id);
                  UPDATE comms_calc_snapshot
                     SET comms_calculated_amt        = comms_calculated_amt+x.oldccs_comms_calculated_amt*-1,
                         comms_calculated_exch_amt   = comms_calculated_exch_amt+x.oldccs_comms_calc_exch_amt*-1,
                         payment_receive_amt         = payment_receive_amt+x.oldccs_payment_receive_amt*-1,
                         last_update_datetime        = SYSDATE,
                         username                    = pv_username
                   WHERE country_code                = x.oldccs_country_code
                     AND product_code                = x.oldccs_product_code
                     AND poep_id                     = lv_poep_id
                     AND person_code                 = x.oldccs_person_code
                     AND policy_code                 = x.oldccs_policy_code
                     AND group_code                  = x.oldccs_group_code
                     AND broker_id_no                = x.oldccs_broker_id_no
                     AND company_id_no               = x.oldccs_company_id_no
                     AND contribution_date           = x.oldccs_contribution_date
                     AND payment_receive_date        = x.oldccs_payment_receive_date
                     AND finance_receipt_no          = x.oldccs_finance_receipt_no
                     AND calculation_datetime        = ld_current_date
                     AND comms_calc_type_code        = 'R'
                     AND payment_currency            = x.oldccs_payment_currency
                     AND exchange_rate_currency_code = x.oldccs_exch_rate_curr_code;
                WHEN OTHERS THEN
                  l_return_msg := 'Reversal Record failed: ' || sqlerrm;
                  RAISE;
              END;

              --Start of LS-1061B if l_insert_cct 
              BEGIN
                IF l_insert_cct
                  THEN
                  --Start of LS-1061            
                    BEGIN
                      cct.comms_calc_snapshot_no      := ccs.comms_calc_snapshot_no;  
                      cct.trace_base_snapshot_no      := x.oldccs_comms_calc_snapshot_no;
                      IF x.old_trace_original_snapshot_no IS NOT NULL
                        THEN cct.trace_original_snapshot_no := x.old_trace_original_snapshot_no;
                        ELSE cct.trace_original_snapshot_no := x.oldccs_comms_calc_snapshot_no;
                      END IF;  
                      INSERT INTO comms_calc_trace VALUES cct;
                    EXCEPTION  
                      WHEN OTHERS THEN
                        l_return_msg := 'Failed: Write to trace file of reversal record: ' || sqlerrm
                                        || ' ' || ccs.comms_calc_snapshot_no;
                        RAISE;
                    END; 
                    --End of LS1061
                END IF;
                EXCEPTION  
                   WHEN OTHERS THEN
                     l_return_msg := 'Failed: Evaluation of cct insert flag rev: ' || sqlerrm;
                     RAISE;              
              --End of LS-1061B
              END;          

              BEGIN -- Write the Adjustment CSS record
                ccs.country_code                := x.oldccs_country_code;
                ccs.product_code                := x.prod_product_code;
                ccs.poep_id                     := lv_new_poep;
                ccs.person_code                 := x.oldccs_person_code;
                ccs.policy_code                 := x.poli_policy_code;
                ccs.group_code                  := x.grps_group_code;
                ccs.broker_id_no                := ln_broker_id_no; 
                ccs.company_id_no               := x.pobr_company_id_no;
                ccs.comms_perc                  := l_percentage;
                ccs.contribution_date           := x.oldccs_contribution_date;
                ccs.payment_receive_date        := x.oldccs_payment_receive_date;
                ccs.finance_receipt_no          := x.oldccs_finance_receipt_no;
                ccs.calculation_datetime        := ld_current_date;
                ccs.comms_calc_type_code        := 'A';
                ccs.payment_receive_amt         := x.oldccs_payment_receive_amt;
                ccs.comms_calculated_amt        := ROUND(ccs.payment_receive_amt * l_percentage / 100, 4);
                ccs.exchange_rate               := x.oldccs_exchange_rate;
                ccs.payment_currency            := x.oldccs_payment_currency;
                ccs.exchange_rate_currency_code := x.oldccs_exch_rate_curr_code;
                ccs.comms_calculated_exch_amt   := ROUND(ccs.comms_calculated_amt * ccs.exchange_rate, 4);
                ccs.invoice_no                  := null;
                ccs.last_update_datetime        := sysdate;
                ccs.username                    := pv_username;  
                ccs.comms_calc_snapshot_no      := comms_calc_snapshot_seq.nextval();   --LS-1061
                l_insert_cct                    := TRUE;   --LS-1061B
           	    INSERT INTO comms_calc_snapshot VALUES ccs;          
              EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                  l_insert_cct                  := FALSE;  --LS1061B          
                  dbms_output.put_line('Duplicate Adjustment Record for New POEP_ID ' || lv_new_poep);
                  UPDATE comms_calc_snapshot
                     SET comms_calculated_amt        = ROUND(comms_calculated_amt + (ccs.payment_receive_amt * l_percentage) / 100, 4),
                         comms_calculated_exch_amt   = ROUND(comms_calculated_exch_amt + (ccs.comms_calculated_amt * ccs.exchange_rate), 4),
                         payment_receive_amt         = payment_receive_amt + ccs.payment_receive_amt,
                         last_update_datetime        = sysdate,
                         username                    = pv_username
                   WHERE country_code                = x.oldccs_country_code
                     AND product_code                = x.oldccs_product_code
                     AND poep_id                     = lv_new_poep
                     AND person_code                 = x.oldccs_person_code
                     AND policy_code                 = x.poli_policy_code
                     AND group_code                  = x.grps_group_code
                     AND broker_id_no                = ln_broker_id_no
                     AND company_id_no               = x.pobr_company_id_no
                     AND contribution_date           = x.oldccs_contribution_date
                     AND payment_receive_date        = x.oldccs_payment_receive_date
                     AND finance_receipt_no          = x.oldccs_finance_receipt_no
                     AND calculation_datetime        = ld_current_date
                     AND comms_calc_type_code        = 'A'
                     AND payment_currency            = x.oldccs_payment_currency
                     AND exchange_rate_currency_code = x.oldccs_exch_rate_curr_code;
                WHEN OTHERS THEN
                  l_return_msg := 'Adjustment Record failed: New POEP_ID: ' || lv_new_poep || 
                                  ' Error: ' || sqlerrm;
                  RAISE;
              END;

              --Start of LS-1061B if l_insert_cct 
              BEGIN
                IF l_insert_cct
                  THEN          
                  -- Start of LS-1061
                    BEGIN  
                      cct.comms_calc_snapshot_no := ccs.comms_calc_snapshot_no;            
                      INSERT INTO comms_calc_trace values cct;
                      EXCEPTION  
                      WHEN OTHERS THEN
                        l_return_msg := 'Failed: Write to trace file of adjustment record: ' || sqlerrm
                                        || ' ' || ccs.comms_calc_snapshot_no;
                        RAISE;
                    END; 
                -- End of LS-1061
                END IF;
                EXCEPTION  
                   when others then
                     l_return_msg := 'Failed: Evaluation of cct insert flag adj: ' || sqlerrm;
                     RAISE;              
              --End of LS-1061B
              END;                    

        		  BEGIN
    		        UPDATE comms_calc_snapshot
    			        set comms_calc_type_code = 'X',
        				      last_update_datetime = sysdate,
    		    			    username = pv_username
    			       where rowid = x.old_record_id;
        		  END;
            EXCEPTION
              WHEN NO_BROKER_EXCEPTION THEN
                l_return_msg := 'No Broker linked to Brokerage Code ' || x.pobr_company_id_no;       
              WHEN OTHERS THEN
                l_return_msg := 'Unexepected Error: ' ||sqlerrm; 
            END;
          END IF;
        END LOOP;
        IF l_return_msg IS NOT NULL THEN
          UPDATE comms_recalc
             SET processed_date       = to_date(get_system_parameter('LB_HEALTH_COMMS','SYSTEM','SYSTEM_START_DATE')),
                 description          = 'FAILED: ' || l_return_msg,
                 last_update_datetime = sysdate,
                 username             = pv_username
           WHERE poep_id              = lv_poep_id;
          dbms_output.put_line('   - ' || lv_poep_id || ' ' || l_return_msg);
        ELSE
          UPDATE comms_recalc
             SET description          = 'SUCCESS',
                 last_update_datetime = sysdate,
                 username             = pv_username
           WHERE poep_id              = lv_poep_id;
        END IF;
      END LOOP;
      COMMIT;

    EXCEPTION
      WHEN OTHERS THEN
        pv_return_msg := 'Back dated changes failed with an unexpected error: ' || sqlerrm;
       -- RAISE_APPLICATION_ERROR('-000001','Recalc changes Run Failed please see log');
        ROLLBACK;      
    END recalc_changes_run;

    /**********************************************************************************************************************/

    PROCEDURE approve_comms_run    (pn_company_id_no IN  NUMBER
                                   ,pv_country_code  IN  VARCHAR2
                   							   ,pv_comms_consultant IN VARCHAR2
                                   ,pv_group_code    IN  VARCHAR2
                                   ,pv_product_code  IN  VARCHAR2
    							                 ,pv_username      IN  VARCHAR2 DEFAULT USER)
                               --    ,pv_return_msg    OUT VARCHAR2)

    IS

      lv_error_msg                   VARCHAR2(500);
      ld_calculation_date            DATE;
      ln_invoice_no                  invoice.invoice_no%TYPE;
      ln_total_invoice_line_amt      invoice_detail.fee_type_amt%TYPE;
      ln_total_invoice_exch_amt      invoice_detail.fee_type_exch_amt%TYPE;
      lv_hold_desc                   VARCHAR2(250);
      lv_processed_hdr               NUMBER(5);
      lv_processed_dtl               NUMBER(5);


      CURSOR c_approved_comms_header IS
        SELECT company_id_no, country_code, payment_receive_date, exchange_rate, exchange_rate_currency_code, sum(cnt)
          FROM (SELECT b.company_id_no, 
                       cc.country_code, 
                       cc.payment_receive_date, --this should be the date of receipt, not the contribution_date
    		           cc.exchange_rate,
    		           cc.exchange_rate_currency_code,
                       COUNT(*) cnt
                  FROM comms_calc_snapshot         cc, 
                       broker                      b  
                 WHERE cc.broker_id_no = b.broker_id_no
                   AND comms_calc_type_code = 'P'
    	           AND cc.group_code = nvl(pv_group_code, cc.group_code)
    	           AND cc.product_code = nvl(pv_product_code, cc.product_code)
    	           AND cc.country_code = nvl(pv_country_code, cc.country_code)
    	           AND cc.company_id_no = nvl(pn_company_id_no, cc.company_id_no)
                   AND calculation_datetime = ld_calculation_date
                 GROUP BY b.company_id_no, 
                          cc.country_code, 
                          cc.payment_receive_date, --this should be the date of receipt, not the contribution_date
    	         		  cc.exchange_rate,
    	         	      cc.exchange_rate_currency_code
                UNION ALL
                SELECT b.company_id_no, 
                       cc.country_code, 
                       cc.payment_receive_date, --this should be the date of receipt, not the contribution_date
    	         	   cc.exchange_rate,
    	         	   cc.exchange_rate_currency_code,
                       COUNT(*) cnt
                  FROM comms_calc_snapshot         cc, 
                       broker                      b  
                 WHERE cc.broker_id_no = b.broker_id_no
                   AND comms_calc_type_code in ('A','R')
    	           AND cc.group_code = nvl(pv_group_code, cc.group_code)
    	           AND cc.product_code = nvl(pv_product_code, cc.product_code)
    	           AND cc.country_code = nvl(pv_country_code, cc.country_code)
    	           AND cc.company_id_no = nvl(pn_company_id_no, cc.company_id_no)
                   AND invoice_no is null
                 GROUP BY b.company_id_no, 
                          cc.country_code, 
                          cc.payment_receive_date, --this should be the date of receipt, not the contribution_date
    	         		  cc.exchange_rate,
    	         	      cc.exchange_rate_currency_code)
       GROUP BY company_id_no, country_code, payment_receive_date, exchange_rate, exchange_rate_currency_code;

      CURSOR c_approved_comms_detail (pn_company_id_no NUMBER, 
                                      pv_country_code VARCHAR2, 
                                      pd_fin_receipt_date date) IS 
       SELECT *
         FROM (SELECT cc.rowid row_id, 
               comms_calculated_amt,
               comms_calculated_exch_amt
          FROM comms_calc_snapshot         cc, 
               broker                      b  
         WHERE cc.broker_id_no = b.broker_id_no
           AND comms_calc_type_code  = 'P'
    	   AND cc.group_code = nvl(pv_group_code, cc.group_code)
    	   AND cc.product_code = nvl(pv_product_code, cc.product_code)
    	   AND cc.country_code = nvl(pv_country_code, cc.country_code)
    	   AND cc.company_id_no = nvl(pn_company_id_no, cc.company_id_no)
           AND payment_receive_date = pd_fin_receipt_date  --this should be the date of receipt, not the contribution_date
           AND calculation_datetime = ld_calculation_date
         UNION ALL
        SELECT cc.rowid row_id, 
               comms_calculated_amt,
               comms_calculated_exch_amt
          FROM comms_calc_snapshot         cc, 
               broker                      b  
         WHERE cc.broker_id_no = b.broker_id_no
           AND comms_calc_type_code  in ('A','R')
    	   AND cc.group_code = nvl(pv_group_code, cc.group_code)
    	   AND cc.product_code = nvl(pv_product_code, cc.product_code)
    	   AND cc.country_code = nvl(pv_country_code, cc.country_code)
    	   AND cc.company_id_no = nvl(pn_company_id_no, cc.company_id_no)
           AND payment_receive_date = pd_fin_receipt_date  --this should be the date of receipt, not the contribution_date
           AND invoice_no is null);

       l_session_id     VARCHAR2(200);
       l_slave_id       NUMBER;
       l_job_start_date DATE;  
       l_start_inv_no   invoice.invoice_no%TYPE;

    BEGIN

      lv_processed_hdr             := 0;
      lv_processed_dtl             := 0;

      select sys_context('userenv','sid') INTO l_session_id from dual;
      select userenv('PID') into l_slave_id FROM DUAL;
      select sysdate into l_job_start_date from dual;


      g_logger_identifier := get_scheduler_job_id(l_session_id,l_slave_id);

      g_log_file_name    := g_logger_identifier||'.html';
      g_output_file_name := g_logger_identifier||'.csv';


      --open up a log and output file to store the run and output information for reference
      commissions_pkg.create_file(  
                          p_file_name     => g_log_file_name,
                          p_process       => 'Commissions Run Approval'
                        );

      commissions_pkg.create_file(  
                          p_file_name     => g_output_file_name,
                          p_process       => 'Commissions Run Approval'
                        ); 

      commissions_pkg.write_to_file(  g_log_file_name,'Brokerage Code : '||pn_company_id_no);
      commissions_pkg.write_to_file(  g_log_file_name,'Country Code   : '||pv_country_code);
      commissions_pkg.write_to_file(  g_log_file_name,'Consultant Code: '||pv_comms_consultant);
      commissions_pkg.write_to_file(  g_log_file_name,'Group Code     : '||pv_group_code);
      commissions_pkg.write_to_file(  g_log_file_name,'Product Code   : '||pv_product_code);
      commissions_pkg.write_to_file(  g_log_file_name,'User Name      : '||pv_username);         

      -- Update Comms Payments Received on Success
      dbms_output.put_line('Area 1 - Update CPR');
      commissions_pkg.write_to_file(  g_log_file_name,'Updating the Comms Payments Received table to Processed ');
      UPDATE comms_payments_received 
         SET
             processed_ind          = 'Y',
             last_update_datetime   = SYSDATE,
             username               = pv_username
       WHERE processed_ind = 'TY'
       	 AND group_code   = nvl(pv_group_code,   group_code)
    	   AND product_code = nvl(pv_product_code, product_code)
    	   AND country_code = nvl(pv_country_code, country_code);

      select max(calculation_datetime) into ld_calculation_date
        from COMMS_CALC_SNAPSHOT s
       where s.comms_calc_type_code = 'T'
       	 AND s.group_code = nvl(pv_group_code, s.group_code)
    	 AND s.product_code = nvl(pv_product_code, s.product_code)
    	 AND s.country_code = nvl(pv_country_code, s.country_code)
    	 AND s.company_id_no = nvl(pn_company_id_no, s.company_id_no)
    	 AND s.username = pv_comms_consultant;

      dbms_output.put_line('Area 2 - Update CCR');
      commissions_pkg.write_to_file(  g_log_file_name,'Updating the Comms calculation snapshot table to POSTED ');
      update COMMS_CALC_SNAPSHOT s
         set comms_calc_type_code = 'P',
             last_update_datetime = SYSDATE,
             username = pv_username
       where calculation_datetime = ld_calculation_date
         AND s.group_code = nvl(pv_group_code, group_code)
    	 AND s.product_code = nvl(pv_product_code, product_code)
    	 AND s.country_code = nvl(pv_country_code, country_code)
    	 AND s.company_id_no = nvl(pn_company_id_no, company_id_no)
    	 AND s.comms_calc_type_code = 'T'
    	 AND s.username = pv_comms_consultant;

      dbms_output.put_line('Area 3 - Header For Loop');
      commissions_pkg.write_to_file(  g_log_file_name,'Inserting Information into the Invoice Table');
      FOR x IN c_approved_comms_header LOOP
         lv_processed_hdr          := lv_processed_hdr + 1;
         ln_invoice_no             := invoice_no_seq.nextval();

         IF lv_processed_hdr      = 1 THEN -- fetch the invoice number for the output file
            l_start_inv_no        := ln_invoice_no;
         END IF;

         ln_total_invoice_line_amt := 0;
         ln_total_invoice_exch_amt := 0;
      	 lv_hold_desc              := get_invoice_hold_reason(x.company_id_no,x.country_code,x.payment_receive_date,null);

         insert into invoice (invoice_no,
                              invoice_date,
                              payment_receive_date,
                              country_code,
                              company_id_no,
                              invoice_type_id_no,
                              release_date,
                              release_hold_reason,
                              payment_date,
                              payment_amt,
                              payment_exch_rate,
                              currency_code,
                              last_update_datetime,
                              username)
                      values (ln_invoice_no,
                              trunc(SYSDATE),
                              x.payment_receive_date,
                              x.country_code,
                              x.company_id_no,
                      			  1, --comms run
                              null,
                              lv_hold_desc,
                              null,
                              null,
                              x.exchange_rate,
    		                      x.EXCHANGE_RATE_CURRENCY_CODE,
                              SYSDATE,
                              pv_username);

         dbms_output.put_line('Area 4 - Detail For Loop - Header ' || lv_processed_hdr);
         FOR y IN c_approved_comms_detail (x.company_id_no, x.country_code, x.payment_receive_date) LOOP
           lv_processed_dtl          := lv_processed_dtl + 1;
           ln_total_invoice_line_amt := ln_total_invoice_line_amt+trunc(y.comms_calculated_amt,2);
           ln_total_invoice_exch_amt := ln_total_invoice_exch_amt+trunc(y.comms_calculated_exch_amt,2);

           update COMMS_CALC_SNAPSHOT
              set invoice_no = ln_invoice_no,
                  last_update_datetime = SYSDATE,
                  username = pv_username
            where rowid = y.row_id;
           begin
             insert into invoice_detail (invoice_no,
                                         fee_type_id_no,
                                         fee_type_amt,
    					    				               fee_type_exch_amt,
                                         fee_type_desc,
                                         last_update_datetime,
                                         username)
    						                 values (ln_invoice_no,
                                         1,
                                         trunc(y.comms_calculated_amt,2),
    									                   trunc(y.comms_calculated_exch_amt,2),
                                         'Commissions',
                                         SYSDATE,
                                         pv_username);
    		   exception 
    		     when dup_val_on_index then
    		       update invoice_detail
    			        set fee_type_amt = fee_type_amt+trunc(y.comms_calculated_amt,2),
    				          fee_type_exch_amt = fee_type_exch_amt+trunc(y.comms_calculated_exch_amt,2)
    			      where invoice_no = ln_invoice_no
    			        and fee_type_id_no = 1;
    		   end;
         END LOOP;

    /*
        dbms_output.put_line('Area 6 - Update Invoice ' || lv_processed_hdr);
    	  update invoice  
    	     set payment_amt = ln_total_invoice_exch_amt
    	   where invoice_no = ln_invoice_no;	
    */	  
      END LOOP;
      commissions_pkg.write_to_file(  g_log_file_name,'Total Invoices Created '|| lv_processed_hdr);
      commissions_pkg.write_to_file(  g_log_file_name,'Total Lines Created    '|| lv_processed_dtl);
      dbms_output.put_line('Area 7 - Commit. ' || lv_processed_hdr || ' invoices and ' || lv_processed_dtl || ' invoice detail lines.');
      commit;

      --once the comms run has been approved purge all test runs with the same combination of data as was processed
      write_csv(g_output_file_name,'SELECT * FROM INVOICE INV, INVOICE_DETAIL INVD WHERE INVD.INVOICE_NO = INV.INVOICE_NO AND INV.INVOICE_NO >= '||l_start_inv_no|| '
      AND COUNTRY_CODE = '''||pv_country_code||'''');


      --pv_return_msg := null;

    EXCEPTION
      WHEN no_data_found then
        commissions_pkg.write_to_file(  g_log_file_name,'No Records were found for Posting');
       -- pv_return_msg := 'No Records found for posting';
      WHEN others then
         rollback;
         dbms_output.put_line('Error: '||sqlerrm);
         commissions_pkg.write_to_file(  g_log_file_name,'Unexpected Error Occurred - Please contact System Admin '||SQLERRM);
         RAISE_APPLICATION_ERROR('-000001','Approve Comms Run Failed please see log');
       -- pv_return_msg := 'System failed with error: '||sqlerrm;
    	-- pv_return_msg := 'Company ' || pn_company_id_no || ', Group ' || pv_group_code || 'failed with error: '||sqlerrm;
    END approve_comms_run;

    /**********************************************************************************************************************/
    PROCEDURE execute_payment_run  (pn_invoice_no    IN  NUMBER
                                   ,pn_company_id_no IN  NUMBER
                                   ,pv_country_code  IN  VARCHAR2
                                   ,pv_username      IN  VARCHAR2) 
                                 --  ,pv_return_msg    OUT VARCHAR2)

    IS

        lv_hold_reason_desc              VARCHAR2(250);
        ld_release_date                  DATE := SYSDATE;
          -- LS-1361 variables to carry string of accreditation codes.
        lv_tax_codes                     VARCHAR2(50);
        lv_tax_codes1                    VARCHAR2(50);
        lv_accred                        VARCHAR2(1);
        lv_multi                         NUMBER;
        ln_invoice_no                    NUMBER;
        -- LS-1361 
        l_session_id     VARCHAR2(200);
        l_slave_id       NUMBER;
        l_job_start_date DATE;  
        l_start_inv_no   invoice.invoice_no%TYPE;

        pv_return_msg    VARCHAR2(8000);


        CURSOR c_get_invoice is
         SELECT invoice_no, 
                 company_id_no, 
                 country_code, 
                 payment_receive_date
           FROM invoice
          WHERE release_Date   IS NULL
            AND invoice_no     = nvl(pn_invoice_no,invoice_no)
            AND country_code   = nvl(pv_country_code,country_code)
            AND company_id_no  = nvl(pn_company_id_no, company_id_no)
         ORDER BY payment_amt;

         -- LS-1361 Interfaces with Fusion. checking company accreditation for invoiceing

         CURSOR c_company_country_accred (pn_company_id_no NUMBER, 
                                          pv_country_code VARCHAR2)
                                          --ln_invoice_no NUMBER) 
                                          IS 

         SELECT ct.accreditation_type_id_no,
                ct.accred_local,
                ct.accred_multi,
                ct.no_accr_local,
                ct.no_accr_multi
           FROM country_taxes                          ct
           JOIN company_country                        cc
             ON (ct.country_code = cc.country_code) 
          WHERE pv_country_code = ct.country_code 
            AND pn_company_id_no = cc.company_id_no 
            AND trunc(SYSDATE) BETWEEN trunc(ct.effective_start_date) AND trunc(ct.effective_end_date);


       PROCEDURE update_invoice(p_invoice_no IN NUMBER, p_release_date IN DATE, p_hold_Reason IN VARCHAR2, p_tax_codes IN VARCHAR2) IS

       BEGIN
           UPDATE invoice  
    	      SET release_date         = p_release_date,
    		      release_hold_reason  = p_hold_Reason,
                  invoice_tax_codes    = p_tax_codes,  
    		      last_update_datetime = SYSDATE,
                  username             = pv_username
            WHERE invoice_no           = p_invoice_no;

       EXCEPTION 
          WHEN OTHERS THEN
              NULL;
       END update_invoice;

       FUNCTION tax_checks RETURN VARCHAR2 IS



       BEGIN
       
        commissions_pkg.write_to_file(  g_log_file_name,'IN GET tax code '||pn_company_id_no||' - '||pv_country_code);  

        lv_tax_codes  := NULL;
        lv_tax_codes1 := NULL;
        lv_accred     := NULL;
        lv_multi      := NULL;


         FOR z IN c_company_country_accred (pn_company_id_no, pv_country_code) LOOP 
           BEGIN
              BEGIN

                   SELECT 'Y' 
                     INTO lv_accred
                     FROM company_accreditation         ca
                    WHERE TRUNC(SYSDATE) BETWEEN TRUNC(ca.company_accred_start_date) AND nvl(TRUNC(ca.company_accred_end_date),'31-DEC-3100')
                      AND ca.company_id_no              = pn_company_id_no
                      AND ca.country_code               = pv_country_code;

              EXCEPTION 
                 WHEN NO_DATA_FOUND THEN 

                     lv_accred := 'N';

              END;

               commissions_pkg.write_to_file(  g_log_file_name,'Accreditation ind is '||lv_accred); 

              BEGIN           

                   SELECT 1 
                     INTO lv_multi                      
                     FROM company_function              cofn
                     JOIN company_table_type            cott
                       ON cofn.company_table_type_id_no  = cott.company_table_type_id_no
                      AND cofn.company_table_id_no       = cott.company_table_id_no
                     WHERE cofn.company_table_id_no      = 6        -- multinational
                       AND cott.company_table_type_id_no = 1  -- Y
                       AND cofn.company_id_no            = pn_company_id_no;

                      EXCEPTION
                       WHEN NO_DATA_FOUND THEN 
                           lv_multi := 2;                 -- N

              END;   
              
             commissions_pkg.write_to_file(  g_log_file_name,'company_accreditation selection: x.Company ' || pn_company_id_no || ' lv_accred ' || lv_accred  
                                  || ' lv_multi: ' || lv_multi);   

            dbms_output.put_line('company_accreditation selection: x.Company ' || pn_company_id_no || ' lv_accred ' || lv_accred  
                                  || ' lv_multi: ' || lv_multi) ;

            IF lv_accred = 'Y' THEN     

                  IF lv_multi = 1   THEN   -- multinat is Y and accred has a record in the period
                     lv_tax_codes := (lv_tax_codes || ',' || z.accred_multi);
                  ELSE                  -- multinat <> Y and accred has a record in the period
                     lv_tax_codes := (lv_tax_codes || ',' || z.accred_local);
                  END IF;
            ELSE                        -- lv_accred = 'N'

                  IF lv_multi = 1       -- multinat is Y and no accred record
                    THEN lv_tax_codes := (lv_tax_codes || ',' || z.no_accr_multi);
                  ELSE                  -- multinat <> Y and no accred record      
                         lv_tax_codes := (lv_tax_codes || ',' || z.no_accr_local);
                  END IF;

            END IF;  

             lv_tax_codes1 := substr(lv_tax_codes,2,50);    -- takes out leading comma

               commissions_pkg.write_to_file(  g_log_file_name,'tax code is '||lv_tax_codes1); 

             RETURN lv_tax_codes1;

        --    dbms_output.put_line('company_accreditation update: x.Company ' || x.company_id_no || ' lv_accred ' || lv_accred  
        --                          || ' lv_multi: 1=Y 2=N ' || lv_multi || ' lv_tax_codes ' || lv_tax_codes) ;

           END LOOP;
          END LOOP;

           IF lv_tax_codes1 IS NULL THEN
             RETURN NULL;
           END IF;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
              commissions_pkg.write_to_file(  g_log_file_name,'error in no data found section');  
              RETURN NULL;
          WHEN OTHERS THEN
              commissions_pkg.write_to_file(  g_log_file_name,'error in when others '||SQLERRM);  
              RETURN NULL;
        END tax_checks;

    BEGIN

          select sys_context('userenv','sid') INTO l_session_id from dual;
          select userenv('PID') INTO l_slave_id FROM DUAL;
          select sysdate INTO l_job_start_date from dual;


          g_logger_identifier := get_scheduler_job_id(l_session_id,l_slave_id);

          g_log_file_name    := g_logger_identifier||'.html';
          g_output_file_name := g_logger_identifier||'.csv';


          --open up a log and output file to store the run and output information for reference
          commissions_pkg.create_file(  
                              p_file_name     => g_log_file_name,
                              p_process       => 'execute Payment Run'
                            );

          commissions_pkg.create_file(  
                              p_file_name     => g_output_file_name,
                              p_process       => 'execute Payment Run'
                            ); 

          commissions_pkg.write_to_file(  g_log_file_name,'Brokerage Code : '||pn_company_id_no);
          commissions_pkg.write_to_file(  g_log_file_name,'Country Code   : '||pv_country_code);
          commissions_pkg.write_to_file(  g_log_file_name,'Invoice Number : '||pn_invoice_no);
          commissions_pkg.write_to_file(  g_log_file_name,'User Name      : '||pv_username);    


      -- ensure that the companyidno and countrycode are selected
      IF (pn_company_id_no IS NULL AND pv_country_code IS NULL) THEN
         commissions_pkg.write_to_file(  g_log_file_name,'Please select a country and brokerage before submitting the payment Run');

      ELSE

           IF pn_invoice_no IS NULL THEN

               lv_hold_reason_desc := get_invoice_hold_reason(pn_company_id_no,pv_country_code,trunc(sysdate), NULL);

           END IF;

            --If there is no reason to withold payment, update the invoice with todays date and stamp the invoice to be interfaced to fusion
           lv_tax_codes1 := tax_checks; 

           FOR x IN c_get_invoice LOOP

             IF pn_invoice_no IS NULL THEN
                NULL;
             ELSE
               lv_hold_reason_desc := get_invoice_hold_reason(x.company_id_no,x.country_code,trunc(sysdate), x.invoice_no);
             END IF;

             commissions_pkg.write_to_file(  g_log_file_name,'Invoice Number is '||x.invoice_no);
             commissions_pkg.write_to_file(  g_log_file_name,'Tax Code is       '||lv_tax_codes1);
             commissions_pkg.write_to_file(  g_log_file_name,'Hold Reason is    '||lv_hold_reason_desc);
             IF lv_hold_reason_desc IS NULL THEN
                update_invoice(
                               p_invoice_no   => x.invoice_no, 
                               p_release_date => TRUNC(SYSDATE), 
                               p_hold_Reason  => NULL, 
                               p_tax_codes    => lv_tax_codes1
                               );

             ELSE
                 update_invoice(
                               p_invoice_no   => x.invoice_no, 
                               p_release_date => NULL, 
                               p_hold_Reason  => to_char(SYSDATE,'YYYY/MM/DD')||':'||lv_hold_reason_desc, 
                               p_tax_codes    => NULL
                               );

              END IF;
            -- commit;
           END LOOP;

           -- COMMIT OUTSIDE THE LOOP better performance and the current session will see the updated record without performing an explicit commit
           COMMIT;

           sb_fusion_trn.create_fusion_sb_prc(pv_return_msg,g_log_file_name,g_output_file_name);
      END IF;
      
      -- once the submission to Fusion has completed run the payables import process
      commissions_pkg.process_fusion_payables(g_log_file_name);

    EXCEPTION
      WHEN others then
         rollback;
         dbms_output.put_line('Error: '||sqlerrm);
    	 pv_return_msg := 'System failed with error: '||sqlerrm;
    end execute_payment_run;


    /**********************************************************************************************************************/

    PROCEDURE proof_of_payment_update_run   (pv_username    IN  VARCHAR2 DEFAULT USER,
                                             pv_return_msg  OUT VARCHAR2)

    IS

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

    CURSOR c_payments IS
    SELECT SUPPLIER_NUMBER            
          ,PARTY_NAME    
          ,OPERATING_UNIT_NAME     
          ,INVOICE_NUM      
          ,TO_DATe(SUBSTR(INVOICE_DATE,1,10),'YYYY-MM-DD') invoice_date    
          ,TO_NUMBER(INVOICE_LINE_AMOUNT) INVOICE_LINE_AMOUNT
          ,LINE_NUMBER                
          ,LINE_TYPE_LOOKUP_CODE      
          ,INVOICE_LINE_DESCRIPTION   
          ,CHECK_NUMBER 
          ,TO_DATe(SUBSTR(CHECK_DATE,1,10),'YYYY-MM-DD') check_date
          ,SOURCE  
          ,TO_NUMBER(PAYMENT_AMT) payment_amt
          ,PAYMENT_TYPE             
          ,PREPAY_INVOICE_NUMBER     
          ,REVERSAL_FLAG              
          ,INVOICE_CURRENCY_CODE         
          ,PAYMENT_CURRENCY_CODE   
          ,'N' PROCESSED
          ,SYSDATE    DATE_ACTIONED
          ,SYSDATE    LAST_UPDATE_DATETIME
          ,'FUSION'                 USERNAME                   
     FROM ws_soap_inbound t,    
                XMLTABLE('//DATA_DS/G_1' PASSING XMLTYPE(t.payload)    
                COLUMNS     
                SUPPLIER_NUMBER                  VARCHAR2(150) PATH 'SUPPLIER_NUMBER/text()',
                PARTY_NAME                       VARCHAR2(150) PATH 'PARTY_NAME/text()',       
                VENDOR_SITE_CODE                 VARCHAR2(150) PATH 'VENDOR_SITE_CODE/text()',
                INVOICE_NUM                      VARCHAR2(150) PATH 'INVOICE_NUM/text()',
                INVOICE_LINE_AMOUNT              VARCHAR2(150) PATH 'INVOICE_LINE_AMOUNT/text()',
                LINE_NUMBER                      VARCHAR2(150) PATH 'LINE_NUMBER/text()',
                LINE_TYPE_LOOKUP_CODE            VARCHAR2(150) PATH 'LINE_TYPE_LOOKUP_CODE/text()',
                INVOICE_LINE_DESCRIPTION         VARCHAR2(150) PATH 'INVOICE_LINE_DESCRIPTION/text()',       
                REVERSAL_FLAG                    VARCHAR2(150) PATH 'REVERSAL_FLAG/text()',
                INVOICE_CURRENCY_CODE            VARCHAR2(150) PATH 'INVOICE_CURRENCY_CODE/text()',     
                PAYMENT_CURRENCY_CODE            VARCHAR2(150) PATH 'PAYMENT_CURRENCY_CODE/text()',
                CHECK_NUMBER                     VARCHAR2(150) PATH 'CHECK_NUMBER/text()',
                CHECK_DATE                       VARCHAR2(150) PATH 'CHECK_DATE/text()',
                OPERATING_UNIT_NAME              VARCHAR2(150) PATH 'OPERATING_UNIT_NAME/text()',  
                VENDOR_TYPE_LOOKUP_CODE          VARCHAR2(150) PATH 'VENDOR_TYPE_LOOKUP_CODE/text()',      
                SOURCE                        	 VARCHAR2(150) PATH 'SOURCE/text()',     
                INVOICE_DATE                     VARCHAR2(150) PATH 'INVOICE_DATE/text()',    
                PAYMENT_AMT                      VARCHAR2(150) PATH 'PAYMENT_AMT/text()',     
                PAYMENT_TYPE                     VARCHAR2(150) PATH 'PAYMENT_TYPE/text()',
                PREPAY_INVOICE_NUMBER            VARCHAR2(150) PATH 'PREPAY_INVOICE_NUMBER/text()')
      WHERE PROCESS_NAME                     = 'FUSION_PAYMENTS'
        AND LINE_TYPE_LOOKUP_CODE            = 'ITEM';
        
        
       --- need to check if an AWT entry for the invoice already exists if it does do not process ***up to here
       CURSOR c_tax IS
            SELECT --csb.invoice_no
           SUPPLIER_NUMBER            
          ,PARTY_NAME    
          ,OPERATING_UNIT_NAME     
          ,INVOICE_NUM      
          ,TO_DATe(SUBSTR(INVOICE_DATE,1,10),'YYYY-MM-DD') invoice_date    
          ,TO_NUMBER(INVOICE_LINE_AMOUNT) INVOICE_LINE_AMOUNT
          ,LINE_NUMBER                
          ,LINE_TYPE_LOOKUP_CODE      
          ,INVOICE_LINE_DESCRIPTION   
          ,CHECK_NUMBER 
          ,TO_DATe(SUBSTR(CHECK_DATE,1,10),'YYYY-MM-DD') check_date
          ,SOURCE  
          ,TO_NUMBER(PAYMENT_AMT)*-1 payment_amt -- THE TAX AMOUNT MUST BE POSITIVE FOR THE CORRESPONDENCE BROKER STATEMENT
          ,PAYMENT_TYPE             
          ,PREPAY_INVOICE_NUMBER     
          ,REVERSAL_FLAG              
          ,INVOICE_CURRENCY_CODE         
          ,PAYMENT_CURRENCY_CODE   
          ,'N' PROCESSED
          ,SYSDATE    DATE_ACTIONED
          ,SYSDATE    LAST_UPDATE_DATETIME
          ,'FUSION'                 USERNAME      
     FROM ws_soap_inbound t,    
                XMLTABLE('//DATA_DS/G_1' PASSING XMLTYPE(t.payload)    
                COLUMNS     
                SUPPLIER_NUMBER                  VARCHAR2(150) PATH 'SUPPLIER_NUMBER/text()',
                PARTY_NAME                       VARCHAR2(150) PATH 'PARTY_NAME/text()',       
                VENDOR_SITE_CODE                 VARCHAR2(150) PATH 'VENDOR_SITE_CODE/text()',
                INVOICE_NUM                      VARCHAR2(150) PATH 'INVOICE_NUM/text()',
                INVOICE_LINE_AMOUNT              VARCHAR2(150) PATH 'INVOICE_LINE_AMOUNT/text()',
                LINE_NUMBER                      VARCHAR2(150) PATH 'LINE_NUMBER/text()',
                LINE_TYPE_LOOKUP_CODE            VARCHAR2(150) PATH 'LINE_TYPE_LOOKUP_CODE/text()',
                INVOICE_LINE_DESCRIPTION         VARCHAR2(150) PATH 'INVOICE_LINE_DESCRIPTION/text()',       
                REVERSAL_FLAG                    VARCHAR2(150) PATH 'REVERSAL_FLAG/text()',
                INVOICE_CURRENCY_CODE            VARCHAR2(150) PATH 'INVOICE_CURRENCY_CODE/text()',     
                PAYMENT_CURRENCY_CODE            VARCHAR2(150) PATH 'PAYMENT_CURRENCY_CODE/text()',
                CHECK_NUMBER                     VARCHAR2(150) PATH 'CHECK_NUMBER/text()',
                CHECK_DATE                       VARCHAR2(150) PATH 'CHECK_DATE/text()',
                OPERATING_UNIT_NAME              VARCHAR2(150) PATH 'OPERATING_UNIT_NAME/text()',  
                VENDOR_TYPE_LOOKUP_CODE          VARCHAR2(150) PATH 'VENDOR_TYPE_LOOKUP_CODE/text()',      
                SOURCE                        	 VARCHAR2(150) PATH 'SOURCE/text()',     
                INVOICE_DATE                     VARCHAR2(150) PATH 'INVOICE_DATE/text()',    
                PAYMENT_AMT                      VARCHAR2(150) PATH 'PAYMENT_AMT/text()',     
                PAYMENT_TYPE                     VARCHAR2(150) PATH 'PAYMENT_TYPE/text()',
                PREPAY_INVOICE_NUMBER            VARCHAR2(150) PATH 'PREPAY_INVOICE_NUMBER/text()'),
                ( SELECT invoice_no
                    FROM INVOICE_PAYMENTS 
                    WHERE line_type_lookup_code = 'AWT') csb
      WHERE PROCESS_NAME                          = 'FUSION_PAYMENTS'
        AND LINE_TYPE_LOOKUP_CODE                 = 'AWT'
        AND csb.invoice_no(+)                        =  invoice_num
        and csb.invoice_no is null;
            
            

    /*CURSOR c_processed_invoices IS
      SELECT invoice_no
            ,min(date_actioned)       payment_date
            ,sum(invoice_line_amount) payment_amount
        FROM invoice_payments
       WHERE     invoice_no IN (SELECT DISTINCT invoice_no
                                  FROM invoice_payments
                                 WHERE last_update_datetime = lv_updated_datetime)
             AND line_type_lookup_code in ('ITEM','PREPAY')
       GROUP BY invoice_no;*/

     l_session_id VARCHAR2(200);
     l_slave_id   NUMBER; 
     l_payments_received VARCHAR2(1) DEFAULT 'N';
      
     TYPE payments_t                IS TABLE OF c_payments%ROWTYPE INDEX BY PLS_INTEGER;
     payments_local                 payments_t; 
     
     
     TYPE tax_t                     IS TABLE OF c_tax%ROWTYPE INDEX BY PLS_INTEGER;
     tax_local                      tax_t; 

    BEGIN
      -- start 1.0
      select sys_context('userenv','sid') INTO l_session_id from dual;
      select userenv('PID') INTO l_slave_id FROM DUAL;

      g_logger_identifier := get_scheduler_job_id(l_session_id,l_slave_id);

      g_log_file_name    := g_logger_identifier||'.html';
      g_output_file_name := g_logger_identifier||'.csv';

      --open up a log and output file to store the run and output information for reference
      commissions_pkg.create_file(  
                          p_file_name     => g_log_file_name,
                          p_process       => 'Fusion Payments - Proof Of Payment Update Run'
                        );

      commissions_pkg.create_file(  
                          p_file_name     => g_output_file_name,
                          p_process       => 'Fusion Payments - Proof Of Payment Update Run'
                        );
                        
                        
      -- GET THE LATEST INFORMATION TO PROCESS FROM FUSION
      commissions_pkg.fetch_fusion_payments_int(g_log_file_name);
      commissions_pkg.write_to_file(  g_log_file_name,'Finished getting outstanding payment information from Fusion');  
  BEGIN 
     OPEN c_payments;
     LOOP
           FETCH c_payments BULK COLLECT INTO payments_local;
           FORALL idx IN 1 .. payments_local.COUNT SAVE EXCEPTIONS 
    
                 INSERT INTO INVOICE_PAYMENTS values payments_local(idx); 
            EXIT WHEN c_payments%NOTFOUND;
     END LOOP;
   
    CLOSE c_payments;
   EXCEPTION

   when DML_ERRORS then

                FOR i IN 1 .. SQL%bulk_exceptions.COUNT
                LOOP

                  IF g_log_file_name IS NOT NULL THEN 
                    IF sql%bulk_exceptions(i).error_code like '%unique constraint%' THEN
                       NULL;
                    ELSE  
                       commissions_pkg.write_to_file(  g_log_file_name,sql%bulk_exceptions(i).error_code);
                       commissions_pkg.write_to_file(  g_log_file_name,sqlerrm(-sql%bulk_exceptions(i).error_code));
                       commissions_pkg.write_to_file(  g_log_file_name,sql%bulk_exceptions(i).error_index);
                    END IF;
                  END IF; 
               END LOOP;    
  -- rollback;             
  -- raise e_Exception;
  END;      
  BEGIN  
    OPEN c_tax;
    LOOP
           FETCH c_tax BULK COLLECT INTO tax_local;
           FORALL idx IN 1 .. tax_local.COUNT SAVE EXCEPTIONS 
    
                 INSERT INTO INVOICE_PAYMENTS values tax_local(idx); 
            EXIT WHEN c_tax%NOTFOUND;
    END LOOP;
   
    CLOSE c_tax;
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
   --raise e_Exception;
  END;    
    COMMIT;
    
   commissions_pkg.write_to_file(  g_log_file_name,'Updating the payment amount on the invoice table to indicate if paid ');  
    
    FOR c_rec IN 
    (
    
        with inv AS (
                    select SUM(NVL(inv.payment_amt,0)) inv_payment_amt, invoice_no
                      from invoice inv
                      GROUP BY invoice_no
                    ),
             invp as (
                     SELECT SUM(invp.payment_amt) total_payment, invp.invoice_no
                       FROM INVOICE_PAYMENTS invp
                        WHERE 1=1
                       AND invp.line_type_lookup_code = 'ITEM' 
                       GROUP BY invp.invoice_no
                     )       
         SELECT invp.total_payment, 
                inv.inv_payment_amt,
                inv.invoice_no
          FROM invp, 
               inv  -- need to change to invoice_payments after testing
        WHERE 1=1
          AND inv.invoice_no = invp.invoice_no
          AND invp.total_payment <>  inv.inv_payment_amt
     ) LOOP
     
      commissions_pkg.write_to_file(  g_log_file_name,'Updating information for invoice '||c_rec.invoice_no||' to amount '||c_rec.total_payment);
      BEGIN
          UPDATE invoice
             SET payment_amt   =  c_rec.total_payment,
                 payment_date  = trunc(sysdate)
           WHERE invoice_no    = c_rec.invoice_no;      
           
          UPDATE invoice_payments -- need to change to invoice_payments after testing
             SET processed     = 'Y'
            WHERE invoice_no   = c_rec.invoice_no
              AND processed    = 'N';
              
           l_payments_received := 'Y';    
      EXCEPTION
        WHEN OTHERS THEN
          commissions_pkg.write_to_file(  g_log_file_name,'Error updating the invoice_payments table '||SQLERRM);
      END;    
    END LOOP;
    
    COMMIT;

      IF l_payments_received = 'Y' THEN

         send_email(p_subject => 'Fusion Commission Payments Received '||sysdate, 
                     p_message => '<html><body>Fusion Payments have been received for Commissions please review <br><br>'||
                                   'Regards, <br><br><br> The Commissions System')
                                   ;
    END IF;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        logger.log_error('System failed with unhandled exception in comms_calc_pkg.proof_of_payment_update_run. Exception desc: 
          ' || sqlerrm, l_scope, null, l_params);
    	  pv_return_msg := 'System failed with error: 
          ' || sqlerrm;
        dbms_output.put_line(pv_return_msg);
    	/*  UPDATE system_parameter  --this is to catch any date format errors as the users can manually update the date via the application.
           SET parameter_value = TO_CHAR(trunc(lv_updated_datetime)-1,'DD-MON-YYYY'),
               last_update_datetime = lv_updated_datetime,
               username = pv_username
         WHERE parameter_key = 'LAST_REMITTANCE_CHECK_DATE'
           AND parameter_section = 'FUSION'
           AND system_name = 'LB_HEALTH_COMMS';
        COMMIT;*/
          commissions_pkg.write_to_file(  g_log_file_name,'Proof of payment run failed with Unexpected error '||SQLERRM);
         -- RAISE_APPLICATION_ERROR('-000001','Approve Commissions Calculation Run Failed please see log');
    END proof_of_payment_update_run;										 

    /**********************************************************************************************************************/

  END COMMS_CALC_PKG;
  
  /
  
  set define on;