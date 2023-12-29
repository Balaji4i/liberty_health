select * from comms_payments_received where FINANCE_RECEIPT_NO like 'LES%';
select * from COMMS_CALC_SNAPSHOT where FINANCE_RECEIPT_NO like 'LES%';
delete from COMMS_CALC_SNAPSHOT where FINANCE_RECEIPT_NO like 'LES%';
UPDATE comms_payments_received SET
  processed_ind          = 'N',
  processed_desc         = NULL
   where FINANCE_RECEIPT_NO like 'LES%';
commit;

DECLARE

  gc_scope_prefix       constant VARCHAR2(31)           
                                 := lower($$PLSQL_UNIT) || '.';
  l_scope                        logger_logs.scope%type 
                                 := 'CommissionsSelfBuild: ' || gc_scope_prefix;
  l_params                       logger.tab_param;

  ccs                            comms_calc_snapshot%rowtype;
  lv_poli_id                     ohi_policies.poli_id%type;
  lv_inse_id                     ohi_insured_entities.inse_id%type;
  lv_enpr_id                     ohi_products.enpr_id%type;
  lv_grac_id                     ohi_groups.grac_id%type;
  lv_poep_id                     ohi_enrollment_products.poep_id%type;
  lv_broker_id                   ohi_policy_brokers.broker_id_no%type;
  lv_company_id                  ohi_policy_brokers.company_id_no%type;
  lv_country_code                company_country.country_code%type;
  lv_comm_perc                   ohi_comm_perc.comm_perc%type;

  cursor c_get_payments_to_calc is
    select rowid,
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
      from COMMS_PAYMENTS_RECEIVED
     where PROCESSED_IND = 'N'
--       and application_id LIKE '3000000016064984%'
     order by CONTRIBUTION_DATE;

BEGIN
  FOR x IN c_get_payments_to_calc LOOP
    BEGIN
      -- Setting the logger values in case of errors
      logger.append_param(l_params, 'Action:', 'Application Id: '|| x.application_id);

      -- Initialize changing ccs record
      ccs.country_code         := NULL;
      ccs.product_code         := NULL;
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

      BEGIN -- Not Zero Amount Check
        IF x.finance_receipt_amt = 0 THEN
          raise_application_error(-20003,'Not Calculating Commission for Zero Amounts.');
        ELSE
          ccs.payment_receive_amt := x.finance_receipt_amt;
        END IF;
      END;  -- Not Zero Amount Check
   
      BEGIN -- Contribution Date Check
        ccs.contribution_date    := to_date(x.contribution_date);
        EXCEPTION
          WHEN OTHERS THEN
            UPDATE comms_payments_received 
               SET
                   processed_ind          = 'F',
                   last_update_datetime   = sysdate,
                   username               = USER
             WHERE ROWID = x.rowid;
            dbms_output.put_line('Appl Id: '|| x.application_id || ' - CONTRIBUTION DATE '|| x.contribution_date || ' is not a valid date.');
            RAISE;
      END;  -- Contribution Date Check

      BEGIN -- Payment Received Date Check
        ccs.payment_receive_date := to_date(x.finance_receipt_date);
        EXCEPTION
          WHEN OTHERS THEN
            UPDATE comms_payments_received 
               SET
                   processed_ind          = 'F',
                   last_update_datetime   = sysdate,
                   username               = USER
             WHERE ROWID = x.rowid;
            dbms_output.put_line('Appl Id: '|| x.application_id || ' - PAYMENT RECEIVED DATE '|| x.finance_receipt_date || ' is not a valid date.');
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
                   processed_ind          = 'F',
                   last_update_datetime   = sysdate,
                   username               = USER
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
                   processed_ind          = 'F',
                   last_update_datetime   = sysdate,
                   username               = USER
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
                   processed_ind          = 'F',
                   last_update_datetime   = sysdate,
                   username               = USER
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
                   processed_ind          = 'F',
                   last_update_datetime   = sysdate,
                   username               = USER
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
           AND to_date(x.contribution_date) between poep.effective_start_date and poep.effective_end_date
         GROUP BY poen.inse_id, poep.enpr_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            UPDATE comms_payments_received 
               SET
                   processed_ind          = 'F',
                   last_update_datetime   = sysdate,
                   username               = USER
             WHERE ROWID = x.rowid;
            dbms_output.put_line('Appl Id: '|| x.application_id || ' - POEP record for ENPR '|| lv_enpr_id || ', INSE ' || lv_inse_id 
                                            || ' and Contr Dt ' || x.contribution_date || ' does not exist.');
            RAISE;
      END;  -- POEP Id Check
      IF lv_poep_id > 0 THEN
        ccs.poep_id            := lv_poep_id;
      END IF;

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
          JOIN ohi_groups              grac
            ON poli.grac_id = grac.grac_id
          JOIN ohi_products            enpr
            ON poep.enpr_id                 = enpr.enpr_id
         WHERE poli.policy_code             = x.policy_code
           AND inse.inse_code               = x.person_code
           AND to_date(x.contribution_date) between poep.effective_start_date and poep.effective_end_date
           AND grac.group_code              = x.group_code
           AND enpr.product_code            = x.product_code
         GROUP BY poli.policy_code, inse.inse_code, grac.group_code, enpr.product_code;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            UPDATE comms_payments_received 
               SET
                   processed_ind          = 'F',
                   last_update_datetime   = sysdate,
                   username               = USER
             WHERE ROWID = x.rowid;
            dbms_output.put_line('Appl Id: '|| x.application_id || ' - POBR record for Policy '|| x.policy_code || ', Person ' || x.person_code 
                                            || ', Group ' || x.group_code || ', Product ' || x.product_code || ' and Date ' || x.contribution_date || ' does not exist.');
            RAISE;
      END;  -- Broker Id Check
      IF lv_broker_id > 0 THEN
        BEGIN -- Company Id Check
          ccs.broker_id_no       := lv_broker_id;
          lv_company_id := NULL;
          SELECT MAX(company_id_no) INTO lv_company_id
            FROM broker
           WHERE broker_id_no             = lv_broker_id
           GROUP BY broker_id_no;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              UPDATE comms_payments_received 
                 SET
                     processed_ind          = 'F',
                     last_update_datetime   = sysdate,
                     username               = USER
               WHERE ROWID = x.rowid;
              dbms_output.put_line('Appl Id: '|| x.application_id || ' - Broker '|| lv_broker_id || ' does not link to a valid Company.');
              RAISE;
        END; -- Company Id Check
      END IF;
      IF lv_company_id > 0 THEN
        ccs.company_id_no         := lv_company_id;
      END IF;

      BEGIN -- Company Country Check
        lv_country_code := NULL;
        SELECT MAX(country_code) INTO lv_country_code
          FROM company_country
         WHERE company_id_no = lv_company_id
           AND country_code = x.country_code
           AND to_date(x.contribution_date) between effective_start_date and effective_end_date
         GROUP BY company_id_no, country_code;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            UPDATE comms_payments_received 
               SET
                   processed_ind          = 'F',
                   last_update_datetime   = sysdate,
                   username               = USER
             WHERE ROWID = x.rowid;
            dbms_output.put_line('Appl Id: '|| x.application_id || ' - COMPANY_COUNTRY record for Company '|| lv_company_id || ' and Country ' || x.country_code 
                                            || ' does not exist.');
            RAISE;
      END;  -- Company Country Check
      IF lv_country_code IS NOT NULL THEN
        ccs.country_code            := lv_country_code;
      END IF;

      BEGIN -- Finance Receipt Number Check
        IF TRIM(x.finance_receipt_no) IS NOT NULL THEN
          ccs.finance_receipt_no      := TRIM(x.finance_receipt_no);
        ELSE
          raise_application_error(-20005,'FINANCE_RECEIPT_NO cannot be blank.');
        END IF;
      END;  -- Finance Receipt Number Check

      -- Deciding on the Commission Percentage
      lv_comm_perc            := NULL;
      IF lv_comm_perc IS NULL THEN
        BEGIN -- POEP level Commission
          IF ccs.poep_id IS NOT NULL THEN
            SELECT MAX(comm_perc) INTO lv_comm_perc
              FROM ohi_comm_perc
             WHERE product_code  IS NULL
               AND poep_id       = lv_poep_id
               AND inse_code     IS NULL
               AND policy_code   IS NULL
               AND group_code    IS NULL
               AND broker_id_no  IS NULL
               AND company_id_no IS NULL
               AND to_date(x.contribution_date) between effective_start_date and effective_end_date
             GROUP BY product_code, poep_id, inse_code, policy_code, group_code, broker_id_no, company_id_no;
          END IF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN 
              -- dbms_output.put_line('Appl Id: '|| x.application_id || ' - - No OHI_COMM_PERC for POEP.');
              NULL;
        END;  -- POEP level Commission
      END IF;
      IF lv_comm_perc IS NULL THEN
        BEGIN -- Person level Commission
          IF ccs.person_code IS NOT NULL THEN
            SELECT MAX(comm_perc) INTO lv_comm_perc
              FROM ohi_comm_perc
             WHERE product_code  IS NULL
               AND poep_id       IS NULL
               AND inse_code     = x.person_code
               AND policy_code   IS NULL
               AND group_code    IS NULL
               AND broker_id_no  IS NULL
               AND company_id_no IS NULL
               AND to_date(x.contribution_date) between effective_start_date and effective_end_date
             GROUP BY product_code, poep_id, inse_code, policy_code, group_code, broker_id_no, company_id_no;
          END IF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN 
              -- dbms_output.put_line('Appl Id: '|| x.application_id || ' - - No OHI_COMM_PERC for Person.');
              NULL;
        END;  -- Person level Commission
      END IF;
      IF lv_comm_perc IS NULL THEN
        BEGIN -- Policy level Commission
          IF ccs.policy_code IS NOT NULL THEN
            SELECT MAX(comm_perc) INTO lv_comm_perc
              FROM ohi_comm_perc
             WHERE product_code  IS NULL
               AND poep_id       IS NULL
               AND inse_code     IS NULL
               AND policy_code   = x.policy_code
               AND group_code    IS NULL
               AND broker_id_no  IS NULL
               AND company_id_no IS NULL
               AND to_date(x.contribution_date) between effective_start_date and effective_end_date
             GROUP BY product_code, poep_id, inse_code, policy_code, group_code, broker_id_no, company_id_no;
          END IF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN 
              -- dbms_output.put_line('Appl Id: '|| x.application_id || ' - - No OHI_COMM_PERC for Policy.');
              NULL;
        END;  -- Policy level Commission
      END IF;
      IF lv_comm_perc IS NULL THEN
        BEGIN -- Group, Product level Commission
          IF ccs.product_code IS NOT NULL AND ccs.group_code IS NOT NULL THEN
            SELECT MAX(comm_perc) INTO lv_comm_perc
              FROM ohi_comm_perc
             WHERE product_code  = x.product_code
               AND poep_id       IS NULL
               AND inse_code     IS NULL
               AND policy_code   IS NULL
               AND group_code    = x.group_code
               AND broker_id_no  IS NULL
               AND company_id_no IS NULL
               AND to_date(x.contribution_date) between effective_start_date and effective_end_date
             GROUP BY product_code, poep_id, inse_code, policy_code, group_code, broker_id_no, company_id_no;
          END IF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN 
              -- dbms_output.put_line('Appl Id: '|| x.application_id || ' - - No OHI_COMM_PERC for Group / Product.');
              NULL;
        END;  -- Group, Product level Commission
      END IF;
      IF lv_comm_perc IS NULL THEN
        BEGIN -- Group level Commission
          IF ccs.group_code IS NOT NULL THEN
            SELECT MAX(comm_perc) INTO lv_comm_perc
              FROM ohi_comm_perc
             WHERE product_code  IS NULL
               AND poep_id       IS NULL
               AND inse_code     IS NULL
               AND policy_code   IS NULL
               AND group_code    = x.group_code
               AND broker_id_no  IS NULL
               AND company_id_no IS NULL
               AND to_date(x.contribution_date) between effective_start_date and effective_end_date
             GROUP BY product_code, poep_id, inse_code, policy_code, group_code, broker_id_no, company_id_no;
          END IF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN 
              -- dbms_output.put_line('Appl Id: '|| x.application_id || ' - - No OHI_COMM_PERC for Group.');
              NULL;
        END;  -- Group level Commission
      END IF;
      IF lv_comm_perc IS NULL THEN
        BEGIN -- Broker level Commission
          IF lv_broker_id IS NOT NULL THEN
            SELECT MAX(comm_perc) INTO lv_comm_perc
              FROM ohi_comm_perc
             WHERE product_code  IS NULL
               AND poep_id       IS NULL
               AND inse_code     IS NULL
               AND policy_code   IS NULL
               AND group_code    IS NULL
               AND broker_id_no  = lv_broker_id
               AND company_id_no IS NULL
               AND to_date(x.contribution_date) between effective_start_date and effective_end_date
             GROUP BY product_code, poep_id, inse_code, policy_code, group_code, broker_id_no, company_id_no;
          END IF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN 
              -- dbms_output.put_line('Appl Id: '|| x.application_id || ' - - No OHI_COMM_PERC for Broker.');
              NULL;
        END;  -- Broker level Commission
      END IF;
      IF lv_comm_perc IS NULL THEN
        BEGIN -- Company level Commission
          IF lv_company_id IS NOT NULL THEN
            SELECT MAX(comm_perc) INTO lv_comm_perc
              FROM ohi_comm_perc
             WHERE product_code  IS NULL
               AND poep_id       IS NULL
               AND inse_code     IS NULL
               AND policy_code   IS NULL
               AND group_code    IS NULL
               AND broker_id_no  IS NULL
               AND company_id_no = lv_company_id
               AND to_date(x.contribution_date) between effective_start_date and effective_end_date
             GROUP BY product_code, poep_id, inse_code, policy_code, group_code, broker_id_no, company_id_no;
          END IF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN 
              -- dbms_output.put_line('Appl Id: '|| x.application_id || ' - - No OHI_COMM_PERC for Company.');
              NULL;
        END;  -- Company level Commission
      END IF;
      IF lv_comm_perc IS NOT NULL THEN
        ccs.comms_perc         := lv_comm_perc;
      ELSE
        raise_application_error(-20004,'No Commission Percentage found for Any Combination.');
      END IF;

      -- Setting the rest of the Values
      ccs.comms_calculated_amt := ccs.payment_receive_amt * ccs.comms_perc / 100;
      ccs.calculation_datetime := SYSDATE;
      ccs.comms_calc_type_code := 'T';
      ccs.invoice_no           := NULL;
      ccs.last_update_datetime := SYSDATE;
      ccs.username             := USER;
     
/*
      dbms_output.put_line('Appl Id: '|| x.application_id || ' - Record: ' || 'coun' || ccs.country_code || ' prod' ||  ccs.product_code 
                                      || ' poep' ||  ccs.poep_id || ' inse' ||  ccs.person_code || ' poli' ||  ccs.policy_code || ' grac' 
                                      ||  ccs.group_code || ' brok' ||  ccs.broker_id_no || ' comp' ||  ccs.company_id_no || ' perc' 
                                      ||  ccs.comms_perc || ' cdte' ||  ccs.contribution_date || ' pmnt' ||  ccs.payment_receive_amt 
                                      || ' camt' ||  ccs.comms_calculated_amt);
*/

      -- Writing the Values to Comms Payments Received
      INSERT INTO comms_calc_snapshot VALUES ccs;

      -- Update Comms Payments Received on Success
      UPDATE comms_payments_received 
         SET
             processed_ind          = 'Y',
             last_update_datetime   = sysdate,
             username               = USER
       WHERE ROWID = x.rowid;   
 
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
        -- dbms_output.put_line('Appl Id: '|| x.application_id || ' - No OHI Data Found.');
      WHEN DUP_VAL_ON_INDEX THEN
        dbms_output.put_line('Appl Id: '|| x.application_id || ' - Duplicate Value on Index.');
        UPDATE comms_payments_received 
           SET
               processed_ind          = 'F',
               last_update_datetime   = sysdate,
               username               = USER
         WHERE ROWID = x.rowid;   
      WHEN OTHERS THEN
        IF SQLCODE = -20003 THEN
          dbms_output.put_line('Appl Id: '|| x.application_id || ' - Zero Amounts are not Processed.');
          UPDATE comms_payments_received 
             SET
                 processed_ind          = 'F',
                 last_update_datetime   = sysdate,
                 username               = USER
           WHERE ROWID = x.rowid;
        ELSIF SQLCODE = -20004 THEN
          dbms_output.put_line('Appl Id: '|| x.application_id || ' - Zero Amounts are not Processed.');
          UPDATE comms_payments_received 
             SET
                 processed_ind          = 'F',
                 last_update_datetime   = sysdate,
                 username               = USER
           WHERE ROWID = x.rowid;
        ELSIF SQLCODE = -20005 THEN
          dbms_output.put_line('Appl Id: '|| x.application_id || ' - FINANCE_RECEIPT_NO cannot be blank.');
          UPDATE comms_payments_received 
             SET
                 processed_ind          = 'F',
                 last_update_datetime   = sysdate,
                 username               = USER
           WHERE ROWID = x.rowid;
        ELSE
          dbms_output.put_line('Appl Id: '|| x.application_id || ' - Other Error: ' || sqlerrm);
          UPDATE comms_payments_received 
             SET
                 processed_ind          = 'F',
                 last_update_datetime   = sysdate,
                 username               = USER
           WHERE ROWID = x.rowid;
        END IF;
    END;
  END LOOP;
--  COMMIT;
   
EXCEPTION
  WHEN OTHERS THEN
--	  pv_return_msg := 'System failed with error: ' || sqlerrm;
    logger.log_error('Unhandled Exception', l_scope, null, l_params);
    dbms_output.put_line(' - Unhandled Exception Error: ' || sqlerrm);
    ROLLBACK;
END;

/*
  ln_broker_id_no                broker.broker_id_no%type;
  ln_comms_calculated_amt        comms_calc_snapshot.comms_calculated_amt%type;
  ln_comm_perc                   comms_calc_snapshot.comms_perc%type;
  ld_comms_run_date			         comms_calc_snapshot.calculation_datetime%type := sysdate;	
  lv_error_msg                   varchar2(500);

  e_no_broker                    exception;

  cursor c_get_broker_id_no (pv_group_code varchar2, pv_country_code varchar2, pv_product_code varchar2, pv_person_code varchar2, pd_date date) is
    select broker_id_no, nvl(company_comm_perc,0)
      from broker b, company_comm_perc c
     where b.company_id_no = c.company_id_no(+)
       and pd_date between c.effective_start_date(+) and c.effective_end_date(+)
       and broker_id_no = 10000061;

       open c_get_broker_id_no(x.group_code, x.country_code, x.product_code, x.person_code, x.contribution_date);
       fetch c_get_broker_id_no into ln_broker_id_no,ln_comm_perc;
       if c_get_broker_id_no%notfound then
         close c_get_broker_id_no;
         lv_error_msg := 'No broker found for Group Code: '||x.group_code||' in country: '||x.country_code;
         raise e_no_broker;
       end if;
     close c_get_broker_id_no;

  WHEN E_NO_BROKER THEN
--  	pv_return_msg := 'System failed with No Broker error: ' || sqlerrm;
    logger.log_error('No Broker Error', l_scope, null, l_params);
    dbms_output.put_line(' - No Broker Error: ' || sqlerrm);
    ROLLBACK;
*/     

/*
cursor c_validate_data is
  select 
         ccs.country_code              ccsCntry
        ,grac.group_code               gracGroup
        ,prod.product_code             prodProd
        ,poep.poep_id                  poepPoep
        ,poli.policy_code              poliPolicy
        ,inse.inse_code                inseCode
        ,pobr.broker_id_no             pobrBroker
        ,pobr.company_id_no            pobrCompany
        ,ccs.contribution_date         ccsSubsDate
    from COMMS_PAYMENTS_RECEIVED       ccs
    inner  
    join (
          select 
                 trim(policy_code)     policy_cde
                ,max(poli_id)          max_poli
            from OHI_POLICIES
--           where last_update_datetime  <= ccs.contribution_date
           group by trim(policy_code)
         )                             maxpoli
      on maxpoli.policy_cde            = trim(ccs.policy_code)
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
     and trim(inse.INSE_CODE)          = trim(ccs.person_code)
    left outer 
    join OHI_ENROLLMENT_PRODUCTS       poep
      on poep.poen_id                  = poen.poen_id
    left outer 
    join OHI_PRODUCTS                  prod
      on prod.product_code             = ccs.product_code
    left outer 
    join OHI_POLICY_BROKERS            pobr
      on pobr.poli_id                  = poli.poli_id
   where ccs.policy_code = '5074444'
--   where ccs.group_code = 'M2M';
   order by ccs.policy_code;
*/