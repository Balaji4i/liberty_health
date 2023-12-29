select * from COMMS_CALC_SNAPSHOT where policy_code = '3925163549';

-- Reverse these 12 lines
UPDATE COMMS_CALC_SNAPSHOT 
   SET COMMS_CALC_TYPE_CODE = 'X'
 WHERE POLICY_CODE = '3925163549' AND INVOICE_NO = 6830;
/
DECLARE
      CURSOR c_get_poepid_to_change  IS
        SELECT 
               oldccs.rowid                       AS old_record_id,
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
               oldccs.comms_calculated_amt        AS oldccs_comms_calculated_amt,
               oldccs.comms_calculated_exch_amt   AS oldccs_comms_calc_exch_amt,
               oldccs.exchange_rate               AS oldccs_exchange_rate,
               oldccs.comms_calc_snapshot_no      AS oldccs_comms_calc_snapshot_no,  --LS-1061
               oldcct.trace_original_snapshot_no  AS old_trace_original_snapshot_no,  --LS-1061       
               oldccs.bu                          AS oldccs_bu
          FROM comms_calc_snapshot                 oldccs
          JOIN comms_calc_trace         oldcct                           --LS-1061
            ON (oldccs.comms_calc_snapshot_no = oldcct.comms_calc_snapshot_no)  --LS-1061                    
         WHERE POLICY_CODE = '3925163549' AND INVOICE_NO = 6830 AND oldccs.comms_calc_type_code in ( 'X') 
         ORDER BY oldccs_contribution_date;

      ld_current_date                DATE := SYSDATE;
      ccs                            comms_calc_snapshot%rowtype;
      cct                            comms_calc_trace%rowtype;             --LS-1061

    BEGIN
        FOR x IN c_get_poepid_to_change LOOP
              BEGIN -- Write the negative CCS record
                ccs.country_code                := x.oldccs_country_code;
                ccs.product_code                := x.oldccs_product_code;
                ccs.poep_id                     := x.oldccs_poep_id;
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
                ccs.username                    := 'BESD-6462';
                ccs.bu                          := x.oldccs_bu;
                ccs.comms_calc_snapshot_no      := comms_calc_snapshot_seq.NEXTVAL();
                insert into comms_calc_snapshot values ccs;              
              END;
                    BEGIN
                      cct.comms_calc_snapshot_no      := ccs.comms_calc_snapshot_no;  
                      cct.trace_base_snapshot_no      := x.oldccs_comms_calc_snapshot_no;
                      IF x.old_trace_original_snapshot_no IS NOT NULL
                        THEN cct.trace_original_snapshot_no := x.old_trace_original_snapshot_no;
                        ELSE cct.trace_original_snapshot_no := x.oldccs_comms_calc_snapshot_no;
                      END IF;  
                      INSERT INTO comms_calc_trace VALUES cct;
                    END;
        END LOOP;
    END;

/
-- Backup and Delete these 2470 lines
CREATE TABLE TEMP_BACKUP_BESD6462 AS (select * from COMMS_CALC_SNAPSHOT where username = 'BESD-6462' AND COMMS_CALC_TYPE_CODE IN ('A', 'R') AND GROUP_CODE IN ('COMVIVAMAL', 'INTERCAPEMAL', 'INTERTREKINT'));
DELETE FROM COMMS_CALC_SNAPSHOT where username = 'BESD-6462' AND COMMS_CALC_TYPE_CODE IN ('A', 'R') AND GROUP_CODE IN ('COMVIVAMAL', 'INTERCAPEMAL', 'INTERTREKINT');

-- Change these 1209 lines to 'P'
UPDATE COMMS_CALC_SNAPSHOT 
   SET COMMS_CALC_TYPE_CODE = 'P'
 WHERE username = 'BESD-6462' AND COMMS_CALC_TYPE_CODE IN ('X') AND GROUP_CODE IN ('COMVIVAMAL', 'INTERCAPEMAL');

/

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
    	           AND cc.group_code = nvl(NULL, cc.group_code)
    	           AND cc.product_code = nvl(NULL, cc.product_code)
    	           AND cc.country_code = nvl(NULL, cc.country_code)
    	           AND cc.company_id_no = nvl(832000095, cc.company_id_no)
--                   AND calculation_datetime = ld_calculation_date
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
    	           AND cc.group_code = nvl(NULL, cc.group_code)
    	           AND cc.product_code = nvl(NULL, cc.product_code)
    	           AND cc.country_code = nvl(NULL, cc.country_code)
    	           AND cc.company_id_no = nvl(832000095, cc.company_id_no)
                   AND invoice_no is null
                 GROUP BY b.company_id_no, 
                          cc.country_code, 
                          cc.payment_receive_date, --this should be the date of receipt, not the contribution_date
    	         		  cc.exchange_rate,
    	         	      cc.exchange_rate_currency_code)
       GROUP BY company_id_no, country_code, payment_receive_date, exchange_rate, exchange_rate_currency_code;

select * from COMMS_CALC_SNAPSHOT where policy_code = '6471471';

      SELECT 
                   poep.poep_id,
                   inse.inse_code,
                   poli.policy_code,
                   enpr.product_code,
                   grac.group_code,
                   brok.broker_id_no,
                   comp.company_id_no,
                   poepcp.comm_perc AS poepcpcomm_perc,
                   insecp.comm_perc AS insecpcomm_perc,
                   policp.comm_perc AS policpcomm_perc,
                   grprcp.comm_perc AS grprcpcomm_perc,
                   graccp.comm_perc AS graccpcomm_perc,
                   brokcp.comm_perc AS brokcpcomm_perc,
                   compcp.comm_perc AS compcpcomm_perc,
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
             END a1
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
             END a2
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
             END a3
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
             AND to_date('01/12/19', 'DD/MM/YY')               BETWEEN     poepcp.effective_start_date 
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
             AND to_date('01/12/19', 'DD/MM/YY')               BETWEEN     insecp.effective_start_date 
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
             AND to_date('01/12/19', 'DD/MM/YY')               BETWEEN     policp.effective_start_date 
                                              AND policp.effective_end_date
        LEFT OUTER
        JOIN lhhcom.ohi_policy_groups           pogr
          ON     poli.poli_id = pogr.poli_id
             AND to_date('01/12/19', 'DD/MM/YY')               BETWEEN     pogr.effective_start_date 
                                              AND pogr.effective_end_date
        LEFT OUTER
        JOIN lhhcom.ohi_groups                  grac
          ON     pogr.grac_id = grac.grac_id
             AND to_date('01/12/19', 'DD/MM/YY')               BETWEEN     grac.effective_start_date 
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
             AND to_date('01/12/19', 'DD/MM/YY')               BETWEEN     grprcp.effective_start_date 
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
             AND to_date('01/12/19', 'DD/MM/YY')               BETWEEN     graccp.effective_start_date 
                                              AND graccp.effective_end_date
        LEFT OUTER
        JOIN lhhcom.ohi_policy_brokers          pobr
          ON     poli.poli_id = pobr.poli_id
             AND to_date('01/12/19', 'DD/MM/YY')               BETWEEN     pobr.effective_start_date 
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
             AND to_date('01/12/19', 'DD/MM/YY')               BETWEEN     brokcp.effective_start_date 
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
             AND to_date('01/12/19', 'DD/MM/YY')               BETWEEN     compcp.effective_start_date 
                                              AND compcp.effective_end_date
       WHERE poep.poep_id             = 1548712
         AND to_date('01/12/19', 'DD/MM/YY') BETWEEN           poep.effective_start_date 
                                  AND poep.effective_end_date;


/
SET SERVEROUTPUT ON;

declare
      l_percentage                   ohi_comm_perc.comm_perc%type;
      l_description                  ohi_comm_perc.comm_desc%type;
      l_return_msg                   VARCHAR2(500);
begin
  commissions_pkg.get_percentage(p_date => to_date('01/12/19', 'DD/MM/YY')
                                              ,p_poep => 1562075
                                              ,p_percentage => l_percentage
                                              ,p_description => l_description
                                              ,p_return_msg => l_return_msg);
    dbms_output.put_line('Perc: ' || l_percentage || '
    Desc: ' || l_description || '
    Mess: ' || l_return_msg);
end;

/

select * from OHI_COMM_PERC where product_code like '% %';
select * from OHI_COMM_PERC where group_code like '% %';
