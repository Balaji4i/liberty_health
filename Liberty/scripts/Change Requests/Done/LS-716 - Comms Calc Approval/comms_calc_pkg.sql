CREATE OR REPLACE PACKAGE "LHHCOM"."COMMS_CALC_PKG" 

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
* </pre>         */

PROCEDURE commissions_calc_run (pn_company_id_no IN  NUMBER
                               ,pv_country_code  IN  VARCHAR2
                               ,pv_group_code    IN  VARCHAR2
                               ,pv_product_code  IN  VARCHAR2
							   ,pv_username      IN  VARCHAR2 DEFAULT USER
                               ,pv_return_msg    OUT VARCHAR2);
                               
PROCEDURE recalc_changes_run   (pv_username IN VARCHAR2,
                                pv_return_msg    OUT VARCHAR2);

PROCEDURE approve_comms_run    (pn_company_id_no IN  NUMBER
                               ,pv_country_code  IN  VARCHAR2
							   ,pv_comms_consultant IN VARCHAR2
                               ,pv_group_code    IN  VARCHAR2
                               ,pv_product_code  IN  VARCHAR2
							   ,pv_username      IN  VARCHAR2
                               ,pv_return_msg    OUT VARCHAR2);

PROCEDURE execute_payment_run  (pn_invoice_no    IN  NUMBER
                               ,pn_company_id_no IN  NUMBER
                               ,pv_country_code  IN  VARCHAR2
                               ,pv_username      IN  VARCHAR2
                               ,pv_return_msg    OUT VARCHAR2);

-- * Example of Procedures executed in an anonymous block (auto-commit data)
-- * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
/*

DECLARE
  l_return_msg VARCHAR2(100);
BEGIN
-- To Run for a Company
--  comms_calc_pkg.commissions_calc_run(1000, NULL, NULL, NULL, l_return_msg);
--  dbms_output.put_line('Block - ' || l_return_msg);
-- To Run for a Country
--  comms_calc_pkg.commissions_calc_run(NULL, 'LS', NULL, NULL, l_return_msg);
--  dbms_output.put_line('Block - ' || l_return_msg);
-- To Run for a Group
--  comms_calc_pkg.commissions_calc_run(NULL, NULL, 'FINANINTELLE', NULL, l_return_msg);
--  dbms_output.put_line('Block - ' || l_return_msg);
-- To Run for a Product
--  comms_calc_pkg.commissions_calc_run(NULL, NULL, NULL, 'LSCL', l_return_msg);
--  dbms_output.put_line('Block - ' || l_return_msg);
-- To Run for all records
--  comms_calc_pkg.commissions_calc_run(NULL, NULL, NULL, NULL, l_return_msg);
--  dbms_output.put_line('Block - ' || l_return_msg);
-- To Run for re-calculation (all records)
  comms_calc_pkg.recalc_changes_run(l_return_msg);
  dbms_output.put_line('Block - ' || l_return_msg);
END;

-- */

END COMMS_CALC_PKG;

/

CREATE OR REPLACE PACKAGE BODY COMMS_CALC_PKG

  AS

/**
  * Contains Prcedures that calculate commission
  * @parameters
  *     p_commit        auto commits data to the database at the end of 
  *                     each procedure
  * */
  
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

PROCEDURE commissions_calc_run (pn_company_id_no IN  NUMBER
                               ,pv_country_code  IN  VARCHAR2
                               ,pv_group_code    IN  VARCHAR2
                               ,pv_product_code  IN  VARCHAR2
							   ,pv_username      IN  VARCHAR2 DEFAULT USER
                               ,pv_return_msg    OUT VARCHAR2)

IS

  gc_scope_prefix       CONSTANT VARCHAR2(31)           
                                 := lower($$PLSQL_UNIT) || '.';
  l_scope                        logger_logs.scope%TYPE 
                                 := 'CommissionsSelfBuild: ' || gc_scope_prefix;
  l_params                       logger.tab_param;

  ccs                            comms_calc_snapshot%ROWTYPE;
  lv_poli_id                     ohi_policies.poli_id%TYPE;
  lv_inse_id                     ohi_insured_entities.inse_id%TYPE;
  lv_enpr_id                     ohi_products.enpr_id%TYPE;
  lv_grac_id                     ohi_groups.grac_id%TYPE;
  lv_poep_id                     ohi_enrollment_products.poep_id%TYPE;
  lv_pogr_id                     ohi_policy_groups.pogr_id%TYPE;
  lv_broker_id                   ohi_policy_brokers.broker_id_no%TYPE;
  ld_calculation_date            DATE := SYSDATE;
  lv_company_id                  ohi_policy_brokers.company_id_no%TYPE;
  lv_country_code                company_country.country_code%TYPE;
  lv_comm_perc                   ohi_comm_perc.comm_perc%TYPE;
  lv_processed_desc              comms_payments_received.processed_desc%TYPE;
  lv_processed_cnt               NUMBER(5);
  lv_processed_success           NUMBER(5);
  lv_pref_curr_required          VARCHAR2(1);
  lv_currency_code               comms_calc_snapshot.exchange_rate_currency_code%TYPE;
  ln_exch_rate                   comms_calc_snapshot.exchange_rate%TYPE;
  lv_exch_currency_code          comms_calc_snapshot.exchange_rate_currency_code%TYPE;
  ln_pref_curr_id                VARCHAR2(50);
  l_percentage                   ohi_comm_perc.comm_perc%type;
  l_description                  ohi_comm_perc.comm_desc%type;
  l_return_msg                   VARCHAR2(500);
  E_NO_PREF_CUR                  EXCEPTION;

  CURSOR c_get_payments_to_calc IS
    SELECT ROWID,
           application_id,
           group_code,
           country_code,
           product_code,
           policy_code,
           person_code,
           contribution_date,
           finance_receipt_no,
           finance_receipt_date,
           finance_receipt_amt
      FROM comms_payments_received
     WHERE processed_ind IN ('N', 'TY', 'TF')
       AND country_code = NVL(upper(pv_country_code), country_code)
       AND product_code = NVL(pv_product_code, product_code)
       AND group_code = NVL(pv_group_code, group_code)
     ORDER BY contribution_date;

	CURSOR c_check_currency_code IS	
            select company_table_type_desc, preferred_currency_code        
      from company c,            
            (select distinct bf.company_id_no, btt.company_table_type_desc, bf.effective_start_date,       
             rank() over (partition by bf.company_id_no order by bf.effective_start_date desc) rank_no        
               from company_function bf, company_table bt, company_table_type btt              
              where bf.company_table_id_no = bt.company_table_id_no              
                and bf.company_table_id_no = 6            
                and bf.company_table_type_id_no = btt.company_table_type_id_no              
                and sysdate between bf.effective_start_date and bf.effective_end_date ) b_multi_net   
      where  c.company_id_no = b_multi_net.company_id_no(+)       
          and nvl(b_multi_net.rank_no,1) = 1
		      and c.company_id_no = lv_company_id;

BEGIN
  lv_processed_cnt             := 0;
  lv_processed_success         := 0;
  FOR x IN c_get_payments_to_calc LOOP
    BEGIN
      -- Setting the logger values in case of errors
      logger.append_param(l_params, 'Action:', 'Application Id: '|| x.application_id);

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
      ccs.payment_receive_amt  := NULL;
      lv_processed_cnt         := lv_processed_cnt + 1;

      BEGIN -- Not Zero Amount Check
        IF x.finance_receipt_amt = 0 THEN
          raise_application_error(-20003,'Not Calculating Commission for Zero Amounts.');
        ELSE
          ccs.payment_receive_amt := x.finance_receipt_amt;
        END IF;
      END;  -- Not Zero Amount Check
   
      BEGIN -- Not NULL Finance Receipt No Check
        IF x.finance_receipt_no IS NULL THEN
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
                   last_update_datetime   = SYSDATE,
                   username               = pv_username
             WHERE ROWID = x.rowid;
            dbms_output.put_line('Appl Id: '|| x.application_id || ' - CONTRIBUTION DATE ' || x.contribution_date || ' is not a valid date.');
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
                   last_update_datetime   = SYSDATE,
                   username               = pv_username
             WHERE ROWID = x.rowid;
            dbms_output.put_line('Appl Id: '|| x.application_id || ' - PAYMENT RECEIVED DATE ' || x.finance_receipt_date || ' is not a valid date.');
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
                   last_update_datetime   = SYSDATE,
                   username               = pv_username
             WHERE ROWID = x.rowid;
            dbms_output.put_line('Appl Id: '|| x.application_id || ' - POLICY_CODE '|| x.policy_code || ' does not exist.');
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
                   last_update_datetime   = SYSDATE,
                   username               = pv_username
             WHERE ROWID = x.rowid;
            dbms_output.put_line('Appl Id: '|| x.application_id || ' - PERSON_CODE '|| x.person_code || ' does not exist.');
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
                   last_update_datetime   = SYSDATE,
                   username               = pv_username
             WHERE ROWID = x.rowid;
            dbms_output.put_line('Appl Id: '|| x.application_id || ' - PRODUCT_CODE '|| x.product_code || ' does not exist.');
            RAISE;
      END;  -- Person Code Check
      IF lv_enpr_id > 0 THEN
        ccs.product_code         := x.product_code;
      END IF;

      BEGIN -- Group Code Check
        lv_grac_id := NULL;
        SELECT MAX(grac_id) INTO lv_grac_id
          FROM ohi_groups
         WHERE group_code = x.group_code
         GROUP BY group_code;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            UPDATE comms_payments_received 
               SET
                   processed_ind          = 'TF',
                   processed_desc         = 'Failed: Group Code '|| x.group_code || ' does not exist',
                   last_update_datetime   = SYSDATE,
                   username               = pv_username
             WHERE ROWID = x.rowid;
            dbms_output.put_line('Appl Id: '|| x.application_id || ' - GROUP_CODE '|| x.group_code || ' does not exist.');
            RAISE;
      END;  -- Group Code Check
      IF lv_grac_id > 0 THEN
        ccs.group_code           := x.group_code;
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
                   last_update_datetime   = SYSDATE,
                   username               = pv_username
             WHERE ROWID = x.rowid;
            dbms_output.put_line('Appl Id: '|| x.application_id || ' - POEP record for ENPR '|| lv_enpr_id || ', INSE ' || lv_inse_id 
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
           AND grac.group_code              = x.group_code
           AND x.contribution_date between pogr.effective_start_date and pogr.effective_end_date
         GROUP BY poli.policy_code, grac.group_code;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            UPDATE comms_payments_received 
               SET
                   processed_ind          = 'TF',
                   processed_desc         = 'Failed: Policy - Group link does not exist for Policy '|| x.policy_code 
                                            || ', Group ' || x.group_code || ' and Date ' || x.contribution_date,
                   last_update_datetime   = SYSDATE,
                   username               = pv_username
             WHERE ROWID = x.rowid;
            dbms_output.put_line('Appl Id: '|| x.application_id || ' - POGR record for Policy '|| x.policy_code || ', Group ' || x.group_code || 
                                 ' and Date ' || x.contribution_date || ' does not exist.');
            RAISE;
      END;  -- Policy Groups Check

      BEGIN -- Broker Id Check
        lv_broker_id := NULL;
        lv_company_id := NULL;
        SELECT MAX(company_id_no), MAX(broker_id_no) INTO lv_company_id, lv_broker_id
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
           AND x.contribution_date between pogr.effective_start_date and pogr.effective_end_date
          JOIN ohi_groups              grac
            ON pogr.grac_id = grac.grac_id
          JOIN ohi_products            enpr
            ON poep.enpr_id                 = enpr.enpr_id
         WHERE poli.policy_code             = x.policy_code
           AND inse.inse_code               = x.person_code
           AND x.contribution_date between poep.effective_start_date and poep.effective_end_date
           AND grac.group_code              = x.group_code
           AND enpr.product_code            = x.product_code
         GROUP BY poli.policy_code, inse.inse_code, grac.group_code, enpr.product_code;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            UPDATE comms_payments_received 
               SET
                   processed_ind          = 'TF',
                   processed_desc         = 'Failed: Policy - Broker/Company link does not exist for Policy '|| x.policy_code 
                                            || ', Person ' || x.person_code || ', Group ' || x.group_code || ', Product ' || x.product_code 
                                            || ' and Date ' || x.contribution_date,
                   last_update_datetime   = SYSDATE,
                   username               = pv_username
             WHERE ROWID = x.rowid;
            dbms_output.put_line('Appl Id: '|| x.application_id || ' - POBR record for Policy '|| x.policy_code || ', Person ' || x.person_code 
                                            || ', Group ' || x.group_code || ', Product ' || x.product_code || ' and Date ' || x.contribution_date || ' does not exist.');
            RAISE;
      END;  -- Broker Id Check

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
                         last_update_datetime   = SYSDATE,
                         username               = pv_username
                   WHERE ROWID = x.rowid;
                  dbms_output.put_line('Appl Id: ' || x.application_id || ' - Broker ' || lv_broker_id || ' does not link to a valid Company.');
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
                   last_update_datetime   = SYSDATE,
                   username               = pv_username
             WHERE ROWID = x.rowid;
            dbms_output.put_line('Appl Id: '|| x.application_id || ' - COMPANY_COUNTRY record for Company '|| lv_company_id || ' and Country ' || x.country_code 
                                            || ' does not exist.');
            RAISE;
      END;  -- Company Country Check
      IF lv_country_code IS NOT NULL THEN
        ccs.country_code            := lv_country_code;
      END IF;
      
      BEGIN -- Exchange Rate Check
        lv_currency_code := NULL;
    		lv_exch_currency_code := NULL;
		    ln_exch_rate := null;
		    lv_pref_curr_required := null;

    		OPEN c_check_currency_code;
		    FETCH c_check_currency_code into lv_pref_curr_required,lv_currency_code;
		    CLOSE c_check_currency_code;
			
          SELECT c.code INTO ln_pref_curr_id
            FROM POL_POLICIES_V@POLICIES.LIBERTY.CO.ZA a,
                 FCOD_PREFCUR@POLICIES.LIBERTY.CO.ZA c
           WHERE tec_ind_last_version = 'Y'
             AND a.code = ccs.policy_code
             AND a.prefcur_id = c.id;
		 
    		IF lv_pref_curr_required = 'Y' AND lv_currency_code IS NULL THEN
		      raise_application_error(-20007,'No preferred currency set for brokerage.');
    		ELSIF lv_pref_curr_required = 'Y' AND lv_currency_code IS NOT NULL THEN		

		    IF ln_pref_curr_id IS NULL THEN
  			
			SELECT c.code INTO ln_pref_curr_id
              FROM POL_GROUP_ACCOUNTS_V@POLICIES.LIBERTY.CO.ZA a,
                    FCOD_PREFCUR@POLICIES.LIBERTY.CO.ZA c
             WHERE object_version_number = (SELECT MAX(object_version_number)
                                              FROM POL_GROUP_ACCOUNTS_V@POLICIES.LIBERTY.CO.ZA
                                             WHERE a.code = code)
               AND a.code = ccs.group_code
               AND a.prefcur_id = c.id;
	        END IF;

  		    IF ln_pref_curr_id IS NOT NULL THEN
            SELECT e.rate,  c_to.code to_currency_code  INTO ln_exch_rate, lv_exch_currency_code
              FROM OHI_CLAIMS_VIEWS_OWNER.OHI_CURRENCIES_V@CLAIMS.LIBERTY.CO.ZA c_from,    
                   OHI_CLAIMS_VIEWS_OWNER.OHI_EXCHANGE_RATES_V@CLAIMS.LIBERTY.CO.ZA e,    
                   OHI_CLAIMS_VIEWS_OWNER.OHI_CURRENCIES_V@CLAIMS.LIBERTY.CO.ZA c_to    
             WHERE e.curr_id_from = c_from.id    
               AND e.curr_id_to = c_to.id
               AND e.rate_context is null
               AND c_from.code = ln_pref_curr_id
               AND c_to.code = lv_currency_code
               AND ccs.payment_receive_date BETWEEN e.start_date AND NVL(e.end_Date,TRUNC(SYSDATE));
    				IF ln_exch_rate IS NULL THEN
              RAISE E_NO_PREF_CUR;
            END IF;				   
		      ELSE
		        RAISE E_NO_PREF_CUR;
		      END IF;				
    			ccs.exchange_rate := ln_exch_rate;
		    	ccs.exchange_rate_currency_code := lv_exch_currency_code;
		    ELSE 
  		   	ccs.exchange_rate := 1;
	    	ccs.exchange_rate_currency_code := nvl(lv_currency_code,ln_pref_curr_id);
    		END IF;
		
        EXCEPTION
    		  WHEN E_NO_PREF_CUR THEN
            UPDATE comms_payments_received 
               SET
                   processed_ind          = 'TF',
                   processed_desc         = 'Failed: No preferred currency found on OHI for the group or policy' ,
                   last_update_datetime   = SYSDATE,
                   username               = pv_username
             WHERE ROWID = x.rowid;
            dbms_output.put_line('Appl Id: '|| x.application_id || ' - No preferred currency found on OHI for the group or policy '|| lv_company_id );		  
      		  RAISE;
          WHEN NO_DATA_FOUND THEN
            UPDATE comms_payments_received 
               SET
                   processed_ind          = 'TF',
                   processed_desc         = 'Failed: Current exchange rate for Brokerage ' || lv_company_id || ' and currency code '||lv_currency_code||' does not exist on OHI',
                   last_update_datetime   = SYSDATE,
                   username               = pv_username
             WHERE ROWID = x.rowid;
            dbms_output.put_line('Appl Id: '|| x.application_id ||' Current exchange rate for Brokerage' || lv_company_id || ' and currency code '||lv_currency_code||' does not exist on OHI');
            RAISE;
      END;  -- Exchange Rate Check
	  
      IF lv_country_code IS NOT NULL THEN
        ccs.country_code            := lv_country_code;
      END IF;
      -- Deciding on the Commission Percentage
      lv_comm_perc            := NULL;
      commissions_pkg.get_percentage(p_date => to_date(x.contribution_date)
                                    ,p_poep => lv_poep_id
                                    ,p_percentage => l_percentage
                                    ,p_description => l_description
                                    ,p_return_msg => l_return_msg);
      dbms_output.put_line('Get Percentage: ' || to_date(x.contribution_date) || ' - ' ||  lv_poep_id || ' - ' ||  l_percentage || ' - ' || l_description || ' - ' || l_return_msg);
      IF l_percentage IS NOT NULL THEN
        ccs.comms_perc         := nvl(check_resigned_status(ccs.broker_id_no, ccs.company_id_no, ccs.contribution_date), ROUND(l_percentage, 2)); --if broker/brokerage is resigned, percentage should be 0
        lv_processed_desc      := l_return_msg;
      ELSE
        dbms_output.put_line('Appl Id: '|| x.application_id || ' - No Commission Percentage found for Any Combination. ' || lv_processed_desc);
        raise_application_error(-20004,'No Commission Percentage found for Any Combination.');
      END IF;
      -- Setting the rest of the Values
      ccs.comms_calculated_amt := ccs.payment_receive_amt * ccs.comms_perc / 100;
	  ccs.comms_calculated_exch_amt := ccs.comms_calculated_amt * ccs.exchange_rate;
      ccs.calculation_datetime := ld_calculation_date; 
      ccs.comms_calc_type_code := 'T';
      ccs.invoice_no           := NULL;
      ccs.last_update_datetime := SYSDATE;
      ccs.username             := pv_username;
      dbms_output.put_line('Appl Id: '|| x.application_id || ' - Record: ' || 'coun' || ccs.country_code || ' prod' ||  ccs.product_code 
                                      || ' poep' ||  ccs.poep_id || ' inse' ||  ccs.person_code || ' poli' ||  ccs.policy_code || ' grac' 
                                      ||  ccs.group_code || ' brok' ||  ccs.broker_id_no || ' comp' ||  ccs.company_id_no || ' perc' 
                                      ||  ccs.comms_perc || ' cdte' ||  ccs.contribution_date || ' pmnt' ||  ccs.payment_receive_amt 
                                      || ' camt' ||  ccs.comms_calculated_amt|| ' cant-exch' ||  ccs.comms_calculated_exch_amt
									  || ' exch' ||  ccs.exchange_rate|| ' exch-curr' ||  ccs.exchange_rate_currency_code);

      -- Writing the Values to Comms Payments Received
      INSERT INTO comms_calc_snapshot VALUES ccs;

      -- Update Comms Payments Received on Success
      UPDATE comms_payments_received 
         SET
             processed_ind          = 'TY',
             processed_desc         = lv_processed_desc,
             last_update_datetime   = SYSDATE,
             username               = pv_username
       WHERE ROWID = x.rowid;   
      lv_processed_success         := lv_processed_success + 1;
 
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
        -- dbms_output.put_line('Appl Id: '|| x.application_id || ' - No OHI Data Found.');
      WHEN DUP_VAL_ON_INDEX THEN
        dbms_output.put_line('Appl Id: '|| x.application_id || ' - Duplicate Value on Index.');
        UPDATE comms_payments_received 
           SET
               processed_ind          = 'TF',
               processed_desc         = 'Failed: Record combination already exists',
               last_update_datetime   = SYSDATE,
               username               = pv_username
         WHERE ROWID = x.rowid;   
      WHEN OTHERS THEN
        IF SQLCODE = -20003 THEN
          dbms_output.put_line('Appl Id: '|| x.application_id || ' - Zero Amounts are not Processed.');
          UPDATE comms_payments_received 
             SET
                 processed_ind          = 'TY',
                 processed_desc         = 'Failed: Zero amounts are not processed',
                 last_update_datetime   = SYSDATE,
                 username               = pv_username
           WHERE ROWID = x.rowid;
        ELSIF SQLCODE = -20004 THEN
          -- dbms_output.put_line('Appl Id: '|| x.application_id || ' - No Commission Percentage found for Any Combination.');
          UPDATE comms_payments_received 
             SET
                 processed_ind          = 'TF',
                 processed_desc         = 'Failed: ' || l_return_msg,
                 last_update_datetime   = SYSDATE,
                 username               = pv_username
           WHERE ROWID = x.rowid;
        ELSIF SQLCODE = -20005 THEN
          dbms_output.put_line('Appl Id: '|| x.application_id || ' - Not Calculating Commission for transactions without a Finance Receipt No.');
          UPDATE comms_payments_received 
             SET
                 processed_ind          = 'TF',
                 processed_desc         = 'Failed: Not Calculating Commission for transactions without a Finance Receipt No.',
                 last_update_datetime   = SYSDATE,
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
                 last_update_datetime   = SYSDATE,
                 username               = pv_username
           WHERE ROWID = x.rowid;
        ELSE
          dbms_output.put_line('Appl Id: '|| x.application_id || ' - Other Error: ' || sqlerrm);
		  lv_processed_desc := sqlerrm;
          UPDATE comms_payments_received 
             SET
                 processed_ind          = 'TF',
                 processed_desc         = 'Failed: Unhandled exception: '||lv_processed_desc,
                 last_update_datetime   = SYSDATE,
                 username               = pv_username
           WHERE ROWID = x.rowid;
        END IF;
    END;
  END LOOP;
  COMMIT;
  
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
   
EXCEPTION
  WHEN OTHERS THEN
    logger.log_error('Unhandled Exception', l_scope, null, l_params);
    dbms_output.put_line(' - Unhandled Exception Error: ' || sqlerrm);
    ROLLBACK;
    pv_return_msg := 'System failed with error: ' || sqlerrm;
END commissions_calc_run;

/**********************************************************************************************************************/

PROCEDURE recalc_changes_run  (pv_username IN VARCHAR2,
                               pv_return_msg    OUT VARCHAR2) 


  IS

  gc_scope_prefix       CONSTANT VARCHAR2(31)           
                                 := lower($$PLSQL_UNIT) || '.';
  l_scope                        logger_logs.scope%TYPE 
                                 := 'CommissionsSelfBuild: ' || gc_scope_prefix;
  l_params                       logger.tab_param;

  ccs                            comms_calc_snapshot%ROWTYPE;
  ld_current_date                DATE := sysdate;
  ln_broker_id_no                broker.broker_id_no%TYPE;
  lv_poep_id                     ohi_enrollment_products.poep_id%TYPE;
  lv_processed_desc              comms_payments_received.processed_desc%TYPE;
  l_percentage                   ohi_comm_perc.comm_perc%type;   
  l_description                  ohi_comm_perc.comm_desc%type;
  l_return_msg                   VARCHAR2(500);
  NO_BROKER_EXCEPTION            exception;

CURSOR c_get_poep_id IS
   SELECT DISTINCT(trecalc.poep_id)              		 AS poep_id
     FROM COMMS_RECALC                            trecalc
    WHERE processed_date = ld_current_date;

  CURSOR c_get_poepid_to_change IS
    SELECT 
       -- DISTINCT(trecal.poep_id)              		 AS poep_id,	
		   oldccs.poep_id                   	      	 	 AS oldccs_poep_id,
		   oldccs.group_code 	      			               AS oldccs_group_code,
		   oldccs.country_code  			                   AS oldccs_country_code,
		   oldccs.product_code     			                 AS oldccs_product_code,
		   oldccs.policy_code			              	   		 AS oldccs_policy_code,		   
		   oldccs.person_code 	     	    	             AS oldccs_person_code,		   
		   oldccs.broker_id_no                           AS oldccs_broker_id_no,
		   oldccs.company_id_no    	                     AS oldccs_company_id_no,
		   oldccs.comms_perc				                     AS oldccs_comms_perc,
       oldccs.finance_receipt_no   		               AS oldccs_finance_receipt_no,
		   oldccs.payment_receive_amt    	               AS oldccs_payment_receive_amt,
		   oldccs.payment_receive_date       	           AS oldccs_payment_receive_date,
       oldccs.contribution_date               		   AS oldccs_contribution_date,
       oldccs.exchange_rate_currency_code            AS oldccs_exch_rate_curr_code,
       oldccs.calculation_datetime                   AS oldccs_calculation_datetime,
       pobr.company_id_no                            AS pobr_company_id_no,
       poli.policy_code                              AS poli_policy_code,
       grps.group_code                               AS grps_group_code,
       prod.product_code                             AS prod_product_code,
       poli.poli_id                                  AS poli_poli_id,
       pobr.poli_id                                  AS pobr_poli_id,
       oldccs.comms_calculated_amt                   AS oldccs_comms_calculated_amt,
       oldccs.comms_calculated_exch_amt              AS oldccs_comms_calc_exch_amt,
       oldccs.exchange_rate                          AS oldccs_exchange_rate
	FROM comms_calc_snapshot                 oldccs
	LEFT OUTER JOIN ohi_enrollment_products  poep
	    ON oldccs.poep_id = poep.poep_id
	LEFT OUTER JOIN ohi_policy_enrollments   poen
	    ON (poep.poen_id = poen.poen_id)
	LEFT OUTER JOIN ohi_policies             poli
	    ON (poen.poli_id = poli.poli_id)
    LEFT OUTER JOIN ohi_policy_brokers       pobr
        ON (poli.poli_id = pobr.poli_id) 
	LEFT OUTER JOIN ohi_policy_groups        grac
	    ON (poli.poli_id = grac.poli_id)
	LEFT OUTER JOIN ohi_groups               grps
	    ON (grac.grac_id = grps.grac_id)
	LEFT OUTER JOIN ohi_insured_entities     inse
	    ON (poen.inse_id = inse.inse_id)
	LEFT OUTER JOIN ohi_products             prod
	    ON (poep.enpr_id = prod.enpr_id)
    WHERE oldccs.comms_calc_type_code = 'P' 
      and oldccs.poep_id = lv_poep_id
    ORDER BY oldccs_contribution_date;
	  
  
BEGIN
    
	UPDATE comms_recalc
	   SET processed_date = ld_current_date,
	       last_update_datetime = sysdate,
		   username = pv_username
	 WHERE processed_date = to_date(get_system_parameter('LB_HEALTH_COMMS','SYSTEM','SYSTEM_START_DATE'));
	 
  FOR y IN c_get_poep_id LOOP           
      lv_poep_id  := y.poep_id;    
         
  FOR x IN c_get_poepid_to_change LOOP
         
           l_percentage := null;
           l_description := null;
           l_return_msg := null;
           ln_broker_id_no := null;
           
           commissions_pkg.get_percentage(p_date => to_date(x.oldccs_contribution_date)
                                    ,p_poep => lv_poep_id
                                    ,p_percentage => l_percentage
                                    ,p_description => l_description
                                    ,p_return_msg => l_return_msg);
                                    
          IF l_percentage IS NULL THEN
            l_return_msg := 'Could not find a Commission %';
          ELSE 
             l_return_msg := null;
          END IF;
          
     
          IF l_percentage <> x.oldccs_comms_perc OR x.oldccs_company_id_no <> x.pobr_company_id_no 
             OR x.oldccs_group_code <> x.grps_group_code OR x.oldccs_product_code <> x.prod_product_code THEN
        
         BEGIN 
          -- Initialize changing ccs record
          ccs.country_code := x.oldccs_country_code;
          ccs.product_code := x.oldccs_product_code;
          ccs.poep_id := lv_poep_id;
          ccs.person_code := x.oldccs_person_code;
          ccs.policy_code := x.oldccs_policy_code;
          ccs.group_code := x.oldccs_group_code;
          ccs.broker_id_no := x.oldccs_broker_id_no;
          ccs.company_id_no := x.oldccs_company_id_no;
          ccs.comms_perc := x.oldccs_comms_perc;
          ccs.contribution_date := x.oldccs_contribution_date;
          ccs.payment_receive_date := x.oldccs_payment_receive_date;
          ccs.finance_receipt_no := x.oldccs_finance_receipt_no;
          ccs.calculation_datetime := ld_current_date;
          ccs.comms_calc_type_code := 'R';
          ccs.payment_receive_amt := x.oldccs_payment_receive_amt;
          ccs.comms_calculated_amt := x.oldccs_comms_calculated_amt*-1;
          ccs.exchange_rate := x.oldccs_exchange_rate;
          ccs.exchange_rate_currency_code := x.oldccs_exch_rate_curr_code;
          ccs.comms_calculated_exch_amt := x.oldccs_comms_calc_exch_amt*-1;
          ccs.invoice_no := null;
          ccs.last_update_datetime := sysdate;
          ccs.username := pv_username;
          
          INSERT INTO comms_calc_snapshot VALUES ccs;  
       EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
                 dbms_output.put_line('Duplicate R for poep '||lv_poep_id);
          update comms_calc_snapshot
             SET comms_calculated_amt = comms_calculated_amt+x.oldccs_comms_calculated_amt*-1,
                 comms_calculated_exch_amt = comms_calculated_exch_amt+x.oldccs_comms_calc_exch_amt*-1,
                 last_update_datetime = sysdate,
                 username = pv_username
           WHERE product_code = x.oldccs_product_code
             AND poep_id = lv_poep_id
             AND person_code = x.oldccs_person_code
             AND policy_code = x.oldccs_policy_code
             AND group_code = x.oldccs_group_code
             AND broker_id_no = x.oldccs_broker_id_no
             AND company_id_no = x.oldccs_company_id_no
             AND contribution_date = x.oldccs_contribution_date
             AND payment_receive_date = x.oldccs_payment_receive_date
             AND finance_receipt_no = x.oldccs_finance_receipt_no
             AND calculation_datetime = ld_current_date
             AND comms_calc_type_code = 'R'
             AND exchange_rate_currency_code = x.oldccs_exch_rate_curr_code;
        WHEN OTHERS THEN
         l_return_msg := 'Processed failed with unkown error: '||sqlerrm;
      END; 
        
        BEGIN
          ln_broker_id_no := get_broker_from_comp(x.pobr_company_id_no);
          
          IF ln_broker_id_no IS NULL THEN
            RAISE NO_BROKER_EXCEPTION;
          END IF;
          
          ccs.country_code := x.oldccs_country_code;
          ccs.product_code := x.prod_product_code;
          ccs.poep_id := lv_poep_id;
          ccs.person_code := x.oldccs_person_code;
          ccs.policy_code := x.poli_policy_code;
          ccs.group_code := x.grps_group_code;
          ccs.broker_id_no := ln_broker_id_no; 
          ccs.company_id_no := x.pobr_company_id_no;
          ccs.comms_perc := l_percentage;
          ccs.contribution_date := x.oldccs_contribution_date;
          ccs.payment_receive_date := x.oldccs_payment_receive_date;
          ccs.finance_receipt_no := x.oldccs_finance_receipt_no;
          ccs.calculation_datetime := ld_current_date;
          ccs.comms_calc_type_code := 'A';
          ccs.payment_receive_amt := x.oldccs_payment_receive_amt;
          ccs.comms_calculated_amt := (ccs.payment_receive_amt*l_percentage)/100;
          ccs.exchange_rate := x.oldccs_exchange_rate;
          ccs.exchange_rate_currency_code := x.oldccs_exch_rate_curr_code;
          ccs.comms_calculated_exch_amt := ccs.comms_calculated_amt*ccs.exchange_rate;
          ccs.invoice_no := null;
          ccs.last_update_datetime := sysdate;
          ccs.username := pv_username;   
     	  INSERT INTO comms_calc_snapshot VALUES ccs;          
 
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         dbms_output.put_line('Duplicate A for poep '||lv_poep_id);
          update comms_calc_snapshot
             SET comms_calculated_amt = comms_calculated_amt+(ccs.payment_receive_amt*l_percentage)/100,
                 comms_calculated_exch_amt = comms_calculated_exch_amt+(ccs.comms_calculated_amt*ccs.exchange_rate),
                 last_update_datetime = sysdate,
                 username = pv_username
           WHERE product_code = x.prod_product_code
             AND poep_id = lv_poep_id
             AND person_code = x.oldccs_person_code
             AND policy_code = x.poli_policy_code
             AND group_code = x.grps_group_code
             AND broker_id_no = ln_broker_id_no
             AND company_id_no = x.pobr_company_id_no
             AND contribution_date = x.oldccs_contribution_date
             AND payment_receive_date = x.oldccs_payment_receive_date
             AND finance_receipt_no = x.oldccs_finance_receipt_no
             AND calculation_datetime = ld_current_date
             AND comms_calc_type_code = 'A'
             AND exchange_rate_currency_code = x.oldccs_exch_rate_curr_code;
      WHEN NO_BROKER_EXCEPTION THEN
         l_return_msg := 'No Broker linked to Brokerage Code '||x.pobr_company_id_no;       
      WHEN OTHERS THEN
         l_return_msg := 'Processed failed with unkown error: '||sqlerrm;
      END;
    END IF;
  END LOOP;
   
    IF l_return_msg IS NOT NULL THEN
      UPDATE COMMS_RECALC
         SET processed_date = to_date(get_system_parameter('LB_HEALTH_COMMS','SYSTEM','SYSTEM_START_DATE')),
             description = 'FAILED: '||l_return_msg,
             last_update_datetime = sysdate,
             username = pv_username
       WHERE poep_id = lv_poep_id;
    ELSE
      UPDATE COMMS_RECALC
         SET description = 'SUCCESS',
             last_update_datetime = sysdate,
             username = pv_username
       WHERE poep_id = lv_poep_id;
    END IF;
 END LOOP;

 COMMIT;
 
 
EXCEPTION
  WHEN OTHERS THEN
    pv_return_msg := 'Back dated changes failed with an unexpected error: ' || sqlerrm;
    ROLLBACK;      
END recalc_changes_run;



/**********************************************************************************************************************/
PROCEDURE approve_comms_run    (pn_company_id_no IN  NUMBER
                               ,pv_country_code  IN  VARCHAR2
							   ,pv_comms_consultant IN VARCHAR2
                               ,pv_group_code    IN  VARCHAR2
                               ,pv_product_code  IN  VARCHAR2
							   ,pv_username      IN  VARCHAR2
                               ,pv_return_msg    OUT VARCHAR2)

IS

  lv_error_msg                 VARCHAR2(500);
  ld_calculation_date          DATE;
  ln_invoice_no                invoice.invoice_no%TYPE;
  ln_total_invoice_line_amt    invoice_detail.fee_type_amt%TYPE;
  ln_total_invoice_exch_amt    invoice_detail.fee_type_exch_amt%TYPE;
  lv_hold_desc                 VARCHAR2(250);

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
     
BEGIN
  
    -- Update Comms Payments Received on Success
  UPDATE comms_payments_received 
     SET
         processed_ind          = 'Y',
         last_update_datetime   = SYSDATE,
         username               = pv_username
   WHERE processed_ind = 'TY'; 
       
  select max(calculation_datetime) into ld_calculation_date
    from COMMS_CALC_SNAPSHOT s
   where s.comms_calc_type_code = 'T'
   	 AND s.group_code = nvl(pv_group_code, s.group_code)
	 AND s.product_code = nvl(pv_product_code, s.product_code)
	 AND s.country_code = nvl(pv_country_code, s.country_code)
	 AND s.company_id_no = nvl(pn_company_id_no, s.company_id_no)
	 AND s.username = pv_comms_consultant;
   
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


   for x IN c_approved_comms_header loop
     ln_invoice_no := invoice_no_seq.nextval();
     ln_total_invoice_line_amt := 0;
     ln_total_invoice_exch_amt := 0;
	 lv_hold_desc := get_invoice_hold_reason(x.company_id_no,x.country_code,x.payment_receive_date,null);
	 
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
                          
     for y IN c_approved_comms_detail (x.company_id_no, x.country_code, x.payment_receive_date) loop
       ln_total_invoice_line_amt := ln_total_invoice_line_amt+y.comms_calculated_amt;
       ln_total_invoice_exch_amt := ln_total_invoice_exch_amt+y.comms_calculated_exch_amt;
	   
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
                                    y.comms_calculated_amt,
									y.comms_calculated_exch_amt,
                                    'Commissions',
                                    SYSDATE,
                                    pv_username);
		 exception 
		   when dup_val_on_index then
		     update invoice_detail
			    set fee_type_amt = fee_type_amt+y.comms_calculated_amt,
				    fee_type_exch_amt = fee_type_exch_amt+y.comms_calculated_exch_amt
			 where invoice_no = ln_invoice_no
			   and fee_type_id_no = 1;
		 end;
     END LOOP;
	 
	 update invoice  
	    set payment_amt = ln_total_invoice_exch_amt
	  where invoice_no = ln_invoice_no;	
	  
   END LOOP;
   
   commit;
   
   pv_return_msg := null;
   
EXCEPTION
  WHEN no_data_found then
    pv_return_msg := 'No Records found for posting';
  WHEN others then
     rollback;
     dbms_output.put_line('Error: '||sqlerrm);
	 pv_return_msg := 'System failed with error: '||sqlerrm;
END approve_comms_run;
/**********************************************************************************************************************/

PROCEDURE execute_payment_run  (pn_invoice_no    IN  NUMBER
                               ,pn_company_id_no IN  NUMBER
                               ,pv_country_code  IN  VARCHAR2
                               ,pv_username      IN  VARCHAR2
                               ,pv_return_msg    OUT VARCHAR2)

IS

lv_hold_reason_desc              VARCHAR2(250);
ld_release_date                  DATE := SYSDATE;

cursor c_get_invoice is
  select invoice_no, company_id_no, country_code, payment_receive_date
  from invoice
  where release_Date is null
    AND invoice_no = nvl(pn_invoice_no,invoice_no)
    AND country_code = nvl(pv_country_code,country_code)
    AND company_id_no = nvl(pn_company_id_no, company_id_no);

BEGIN
    --get all invoices that has not been processed and loop through each record
   for x IN c_get_invoice loop
      --See if there is any reason why the invoice cannot be paid
      lv_hold_reason_desc := get_invoice_hold_reason(x.company_id_no,x.country_code,trunc(sysdate), x.invoice_no);
	  
	  --If there is no reason to withold payment, update the invoice with todays date and stamp the invoice to be interfaced to fusion
	  if lv_hold_reason_desc is null then
	    update invoice  
	       set release_date = ld_release_date,
		       release_hold_reason = null,
		       last_update_datetime = SYSDATE,
			   username = pv_username
	     where invoice_no = x.invoice_no;

    	insert into dnld_invoice (invoice_no,
                                 stamp_datetime,
                                 stamp_ind,
                                 batch_no,
                                 last_update_datetime,
                                 username) 
		                 values (x.invoice_no,
						         SYSDATE,
								 'I',
								 0,
								 SYSDATE,
								 pv_username);	
	  else
	    --If there is a reason to withold payment, update the invoice record with the date and hold reason
	    update invoice  
	       set release_hold_reason = to_char(SYSDATE,'dd/MON/yyyy')||':'||lv_hold_reason_desc,
		       release_date = null,
		       last_update_datetime = SYSDATE,
			   username = pv_username
	     where invoice_no = x.invoice_no;	
	  END IF;
	 commit;
   END LOOP;
   
EXCEPTION
  WHEN others then
     rollback;
     dbms_output.put_line('Error: '||sqlerrm);
	 pv_return_msg := 'System failed with error: '||sqlerrm;
end execute_payment_run;

/**********************************************************************************************************************/

END COMMS_CALC_PKG;

/
