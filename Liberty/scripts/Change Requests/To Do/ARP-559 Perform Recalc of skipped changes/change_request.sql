set define off;

/

CREATE OR REPLACE PROCEDURE adhoc_recalc_changes_run  (pv_group   IN  VARCHAR2)--,
--                                   pv_return_msg    OUT VARCHAR2) 

    AS

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
      l_return_msg                   VARCHAR2(5000);
      pv_return_msg                  VARCHAR2(5000);
      pv_username                    VARCHAR2(10)
                                     := 'BESD-6462';
      l_insert_cct                   BOOLEAN; --LS1061B
      NO_BROKER_EXCEPTION            EXCEPTION;
      lv_company_id                  ohi_policy_brokers.company_id_no%TYPE;
      E_NO_PREF_CUR                  EXCEPTION;
      lv_pref_curr_required          VARCHAR2(1);
      lv_count                       INTEGER(10);
      lv_count_r                     INTEGER(10);
      lv_count_a                     INTEGER(10);
      lv_currency_code               comms_calc_snapshot.exchange_rate_currency_code%TYPE;
      ln_exch_rate                   comms_calc_snapshot.exchange_rate%TYPE;
      lv_exch_currency_code          comms_calc_snapshot.exchange_rate_currency_code%TYPE;

      CURSOR c_get_poep_id           IS
        SELECT DISTINCT(ccs.poep_id) AS poep_id
          FROM COMMS_CALC_SNAPSHOT         trecalc
          JOIN ohi_enrollment_products     poep
            ON trecalc.poep_id = poep.poep_id
          JOIN ohi_policy_enrollments      poen
            ON poep.poen_id = poen.poen_id
          JOIN ohi_insured_entities        inse
            ON poen.inse_id = inse.inse_id
          JOIN ohi_products                enpr
            ON poep.enpr_id = enpr.enpr_id
          JOIN comms_calc_snapshot         ccs
            ON     inse.inse_code = ccs.person_code
               AND enpr.product_code = ccs.product_code
               AND ccs.contribution_date BETWEEN poep.effective_start_date AND poep.effective_end_date
         WHERE     trecalc.group_code LIKE trim(pv_group) || '%'
               AND trecalc.comms_calc_type_code in ('P', 'A');

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
               oldcct.trace_original_snapshot_no  AS old_trace_original_snapshot_no,  --LS-1061       
               oldccs.bu                          AS oldccs_bu
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
            ON (    poli.poli_id = grac.poli_id
                AND oldccs.contribution_date BETWEEN grac.effective_start_date and grac.effective_end_date)
          LEFT OUTER 
          JOIN ohi_groups               grps
            ON (    grac.grac_id = grps.grac_id
                AND oldccs.contribution_date BETWEEN grps.effective_start_date and grps.effective_end_date)
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
      lv_count   := 0;    
      lv_count_r := 0;
      lv_count_a := 0;
      FOR y IN c_get_poep_id LOOP
        lv_count     := lv_count + 1;
        lv_poep_id   := y.poep_id;    
        l_return_msg := null;
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
--          dbms_output.put_line('recalc POEP Id ('|| x.oldccs_poep_id || '/' || lv_new_poep || '), PERSON_CODE (' 
--                                                 || x.oldccs_person_code || ') and CONTRIBUTION DATE (' 
--                                                 || x.oldccs_contribution_date || ') = ' || l_percentage || '%');
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
                ccs.bu                          := x.oldccs_bu; -- 1.5
                ccs.comms_calc_snapshot_no      := comms_calc_snapshot_seq.NEXTVAL();  --LS-1061
                l_insert_cct                    := TRUE;    -- LS-1061B
                lv_count_r                      := lv_count_r + 1;
                logger.log_information('ADHOC_RECALC_CHANGES_RUN reversal for ' || ccs.group_code || ', ' || ccs.policy_code ||
                  ', ' || ccs.person_code || ', ' || ccs.contribution_date || ' for Company ' || ccs.company_id_no || 
                  ', ' || ccs.payment_receive_amt || ccs.payment_currency || ' x ' || ccs.comms_perc || '% = ' || ccs.comms_calculated_amt || 
                  ' and ' || ccs.comms_calculated_exch_amt
                  , l_scope, null, l_params);
                insert into comms_calc_snapshot values ccs;              
              EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                  l_insert_cct                  := FALSE;    --LS-1061B
                  dbms_output.put_line('Duplicate Reversal Record for POEP_ID ' || lv_poep_id);
                  lv_count_r                    := lv_count_r - 1;
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
                ccs.bu                          := x.oldccs_bu; -- 1.5
                ccs.comms_calc_snapshot_no      := comms_calc_snapshot_seq.nextval();   --LS-1061
                l_insert_cct                    := TRUE;   --LS-1061B
                lv_count_a                      := lv_count_a + 1;
                logger.log_information('ADHOC_RECALC_CHANGES_RUN adjustment for ' || ccs.group_code || ', ' || ccs.policy_code ||
                  ', ' || ccs.person_code || ', ' || ccs.contribution_date || ' for Company ' || ccs.company_id_no || 
                  ', ' || ccs.payment_receive_amt || ccs.payment_currency || ' x ' || ccs.comms_perc || '% = ' || ccs.comms_calculated_amt || 
                  ' and ' || ccs.comms_calculated_exch_amt
                  , l_scope, null, l_params);
           	    INSERT INTO comms_calc_snapshot VALUES ccs;          
              EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                  l_insert_cct                  := FALSE;  --LS1061B          
                  dbms_output.put_line('Duplicate Adjustment Record for New POEP_ID ' || lv_new_poep);
                  lv_count_a                    := lv_count_a - 1;
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
          INSERT INTO comms_recalc 
            VALUES (lv_poep_id, ld_current_date, 'FAILED: ' || l_return_msg, ld_current_date, pv_username);
          dbms_output.put_line('   - ' || lv_poep_id || ' ' || l_return_msg);
        ELSE
          INSERT INTO comms_recalc 
            VALUES (lv_poep_id, ld_current_date, 'SUCCESS: ' || lv_count_r || ' reversals and ' || lv_count_a || ' adjustments processed', ld_current_date, pv_username);
        END IF;
      END LOOP;
      IF lv_count > 0 THEN
        l_return_msg := lv_count || ' POEP_IDs: ' || lv_count_r || ' reversals and ' || lv_count_a || ' adjustments processed';
      ELSE
        l_return_msg := 'No POEP_IDs to process';
      END IF;

      pv_return_msg := l_return_msg;

--      ROLLBACK;  

      logger.log_information('ADHOC_RECALC_CHANGES_RUN for Group ' || pv_group || ': ' || l_return_msg, l_scope, null, l_params);

    EXCEPTION
      WHEN OTHERS THEN
        pv_return_msg := 'Back dated changes failed with an unexpected error: ' || sqlerrm;
       -- RAISE_APPLICATION_ERROR('-000001','Recalc changes Run Failed please see log');
        ROLLBACK;      
    END adhoc_recalc_changes_run;

/

--/* Ad Hoc Code

SET SERVEROUTPUT ON;

DECLARE
  l_return_msg VARCHAR2(5000);
  l_group      VARCHAR2(50);
  l_script     VARCHAR2(5000);
      CURSOR c_groups                      IS
        SELECT DISTINCT(ccs.group_code) AS group_code
          FROM COMMS_CALC_SNAPSHOT         ccs
         WHERE ccs.comms_calc_type_code in ('P', 'A')
               AND ccs.group_code LIKE l_group || '%'
         ORDER BY 1;
      CURSOR c_groups1                     IS
        SELECT DISTINCT(ccs.group_code) AS group_code
          FROM COMMS_CALC_SNAPSHOT         ccs
         WHERE ccs.comms_calc_type_code in ('P', 'A')
               AND ccs.group_code >= 'INTERNJUSTUG'
               AND ccs.group_code < 'MOTHAEDIAMONDS'
         ORDER BY 1;
      CURSOR c_groups2                     IS
        SELECT DISTINCT(ccs.group_code) AS group_code
          FROM COMMS_CALC_SNAPSHOT         ccs
         WHERE ccs.comms_calc_type_code in ('P', 'A')
               AND ccs.group_code >= 'COEETHICS'
               AND ccs.group_code < 'JSIRESEARCHANDTRAINING'
         ORDER BY 1;
      CURSOR c_groups3                     IS
        SELECT DISTINCT(ccs.group_code) AS group_code
          FROM COMMS_CALC_SNAPSHOT         ccs
         WHERE ccs.comms_calc_type_code in ('P', 'A')
               AND ccs.group_code >= 'JSIRESEARCHANDTRAINING'
               AND ccs.group_code < 'UGANDABREWER'
         ORDER BY 1;
      CURSOR c_groups4                     IS
        SELECT DISTINCT(ccs.group_code) AS group_code
          FROM COMMS_CALC_SNAPSHOT         ccs
         WHERE ccs.comms_calc_type_code in ('P', 'A')
               AND ccs.group_code >= 'UGANDABREWER'
         ORDER BY 1;
      CURSOR c_groups5                     IS
        SELECT DISTINCT(ccs.group_code) AS group_code
          FROM COMMS_CALC_SNAPSHOT         ccs
         WHERE ccs.comms_calc_type_code in ('P', 'A')
               AND ccs.group_code IS NULL
         ORDER BY 1;
BEGIN
--  dbms_output.put_line('Start');
--/*
  BEGIN
    l_group := 'INTERNJUSTUG to MOTHAEDIAMONDS';
    l_script := 'BEGIN
      ';
    FOR y IN c_groups1 LOOP
      l_script := l_script || 'adhoc_recalc_changes_run(''' || y.group_code || '''); commit;
      ';
    END LOOP;
    l_script := l_script || 'END;';
    DBMS_SCHEDULER.CREATE_JOB (
       job_name             => 'BESD_6462',
       job_type             => 'PLSQL_BLOCK',
       job_action           => l_script,
       job_class            => 'DEFAULT_JOB_CLASS',
       start_date           => systimestamp + interval '10' second,
       enabled              => TRUE,
       comments             => 'Running adhoc_recalc_changes_run procedure for groups starting with ' || l_group || '...');
  END;
--*/
/*
  FOR y IN c_groups1 LOOP
    adhoc_recalc_changes_run(y.group_code, l_return_msg);
    dbms_output.put_line(y.group_code || ' Success: ' || l_return_msg);
  END LOOP;
--*/
/*
  FOR y IN c_groups2 LOOP
    adhoc_recalc_changes_run(y.group_code, l_return_msg);
    dbms_output.put_line(y.group_code || ' Success: ' || l_return_msg);
  END LOOP;
--*/
/*
  FOR y IN c_groups3 LOOP
    adhoc_recalc_changes_run(y.group_code, l_return_msg);
    dbms_output.put_line(y.group_code || ' Success: ' || l_return_msg);
  END LOOP;
--*/
/*
  FOR y IN c_groups4 LOOP
    adhoc_recalc_changes_run(y.group_code, l_return_msg);
    dbms_output.put_line(y.group_code || ' Success: ' || l_return_msg);
  END LOOP;
--*/
/*
  FOR y IN c_groups5 LOOP
    adhoc_recalc_changes_run(y.group_code, l_return_msg);
    dbms_output.put_line(y.group_code || ' Success: ' || l_return_msg);
  END LOOP;
--*/
--  ROLLBACK;  

EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Error: ' || l_return_msg || '
    ' || sqlerrm);
END;

--*/

/

-- SELECT STATE, JOB_ACTION, COMMENTS FROM ALL_SCHEDULER_JOBS WHERE JOB_NAME = 'BESD_6462';
-- SELECT * FROM ALL_SCHEDULER_JOBS WHERE JOB_NAME = 'BESD_6462';
-- SELECT ID, TEXT, TIME_STAMP FROM LOGGER_LOGS WHERE TEXT like 'ADHOC%' AND ID > 215959 ORDER BY 1;
  
SET SERVEROUTPUT OFF;
set define on;
--drop PROCEDURE adhoc_recalc_changes_run;

/*
declare
begin
    DBMS_SCHEDULER.STOP_JOB (job_name             => 'BESD_6462');
end;

/

        SELECT trecalc.group_code, count (DISTINCT ccs.poep_id) AS poep_id
          FROM COMMS_CALC_SNAPSHOT         trecalc
          JOIN ohi_enrollment_products     poep
            ON trecalc.poep_id = poep.poep_id
          JOIN ohi_policy_enrollments      poen
            ON poep.poen_id = poen.poen_id
          JOIN ohi_insured_entities        inse
            ON poen.inse_id = inse.inse_id
          JOIN ohi_products                enpr
            ON poep.enpr_id = enpr.enpr_id
          JOIN comms_calc_snapshot         ccs
            ON     inse.inse_code = ccs.person_code
               AND enpr.product_code = ccs.product_code
               AND ccs.contribution_date BETWEEN poep.effective_start_date AND poep.effective_end_date
         WHERE     trecalc.comms_calc_type_code in ('P', 'A')
         GROUP BY trecalc.group_code
         ORDER BY 1;

SELECT STATE, JOB_ACTION, COMMENTS FROM ALL_SCHEDULER_JOBS WHERE JOB_NAME = 'BESD_6462';

SELECT ID, TEXT, TIME_STAMP FROM LOGGER_LOGS WHERE TEXT like 'ADHOC%' AND ID > 234446 ORDER BY 1;

select * from COMMS_CALC_SNAPSHOT where policy_code = '3925163549';
select * from COMMS_PAYMENTS_RECEIVED where policy_code = '3925163549';
-- */