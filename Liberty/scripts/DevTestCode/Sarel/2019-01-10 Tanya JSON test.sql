SET SERVEROUTPUT ON;
DECLARE
BEGIN
  lhhcom.refresh_pay_comms;
END;
/
  SELECT DISTINCT cpr.payment_type, j.*
    FROM comms_payments_received cpr
    LEFT OUTER
    JOIN (SELECT 
                 j.data.CODE.code        premium_code
                ,j.data.COUNTRY.code     country_code
                ,to_date(j.data.startDate, 'YYYY-MM-DD')
                                         effective_start_date
                ,(case 
                  when JSON_EXISTS(j.data,'$.endDate') then to_date(NVL(j.data.endDate,'4711-12-01'), 'YYYY-MM-DD') 
                                                       else TO_DATE('31-DEC-4712') END)
                                         effective_end_date
                ,j.data.COMCALC.code     calculate_comms
            FROM globaltemp_json_workspace j 
         ) j
      ON     cpr.payment_type = j.premium_code
         AND (    cpr.country_code = j.country_code 
              OR  j.country_code is null)
         AND cpr.CONTRIBUTION_DATE BETWEEN j.effective_start_date AND j.effective_end_date;

/
  SELECT DISTINCT
         country_code
        ,contribution_date
        ,payment_type
        ,commissionable
        ,processed_ind
        ,processed_desc
    FROM comms_payments_received
   WHERE processed_ind <> 'Y'
     AND payment_type LIKE '%CORE%'
   ORDER BY 1, 3, 2;

/
SET SERVEROUTPUT ON;
DECLARE
      lv_result                      VARCHAR2(100);
      lv_commissionable              VARCHAR2(10);
      ln_count                       BINARY_INTEGER;
      l_array                        dbms_utility.lname_array;
      CURSOR c_cpr_payment_types IS
        SELECT DISTINCT
               TRIM(country_code) country_code
              ,contribution_date  contribution_date
              ,TRIM(payment_type) payment_type
              ,commissionable
          FROM comms_payments_received
         WHERE processed_ind <> 'Y'
         ORDER BY 1, 3, 2;
BEGIN
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
                  AND cpr.payment_type      =  x.payment_type;
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
                  AND cpr.payment_type      =  x.payment_type;
          ELSIF lv_result like '%Yes%' THEN
            UPDATE comms_payments_received cpr
              SET cpr.commissionable       = 'Y'
            WHERE     cpr.processed_ind     <> 'Y'
                  AND cpr.country_code      =  x.country_code
                  AND cpr.contribution_date =  x.contribution_date
                  AND cpr.payment_type      =  x.payment_type;
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
                  AND cpr.payment_type      =  x.payment_type;
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
END;