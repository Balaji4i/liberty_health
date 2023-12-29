--------------------------------------------------------
--  File created - Tuesday-November-20-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package COMMISSIONS_DM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "LHHCOM"."COMMISSIONS_DM_PKG" AUTHID CURRENT_USER AS 

 /**
* <pre>
* ----------------------------------------------------------------------
* Project:     : Commission Self Build
*
*                Description  : Package to run Data migration processes per Country
*                File Name    : Liberty\plsql\packages\lhhcom\commissions_dm_pkg.sql
*
*                Amendments   :
*                Date        User     Change Description
*                ========    ======== =================================================
*                2018-10-19  T.Percy   Initial Version - code written by Jaco and amended by Sarel.
*                                      T.Percy wrapped into a dm package for future use, to be submitted via job dashboard
*                                      For approval by the business
*               
*
* </pre>         */

      PROCEDURE MIGRATE_FROM_MEDWARE(
                                p_stage             IN NUMBER DEFAULT 0
                               ,p_pre_load          IN VARCHAR2 DEFAULT 'Y'
                               ,p_comm_run_date     IN DATE DEFAULT NULL
                               ,p_country           IN VARCHAR2
                               ,p_group_code        IN VARCHAR2 DEFAULT NULL
                               ,p_scheme            IN VARCHAR2 DEFAULT NULL
                               ,p_user_name         IN VARCHAR2 DEFAULT NULL
                               ,p_approve_run       IN VARCHAR2 DEFAULT 'N'
                               ,p_logger_identifer  IN VARCHAR2 DEFAULT NULL
                         );

END COMMISSIONS_DM_PKG;

/
--------------------------------------------------------
--  DDL for Package Body COMMISSIONS_DM_PKG
--------------------------------------------------------

  
  create or replace PACKAGE BODY               COMMISSIONS_DM_PKG  AS 
    
     /**
    * <pre>
    * ----------------------------------------------------------------------
    * Project:     : Commission Self Build
    *
    *                Description  : Package to run Data migration processes per Country
    *                File Name    : Liberty\plsql\packages\lhhcom\commissions_dm_pkg.sql
    *
    *                Amendments   :
    *                Date        User     Change Description
    *                ========    ======== =================================================
    *                2018-10-19  T.Percy   Initial Version - code written by Jaco and amended by Sarel.
    *                                      T.Percy formalized process, added performance considerations,
    *                                      improved logging, reconciliation processes, approval processes
    *                                      updating of invoice no on comms calc to match payment records
    *               
    *
    * </pre>         */
  
          g_pre_load         VARCHAR2(1);
          g_as_from_date     NUMBER; 
          g_broker_id        comms_calc_snapshot.company_id_no%TYPE;
          g_group_code       VARCHAR2(32000);
          g_country          comms_calc_snapshot.country_code%TYPE; 
          g_scheme           VARCHAR2(32000);
          gc_scope_prefix    CONSTANT VARCHAR2(31) DEFAULT lower($$PLSQL_UNIT) || '.';
          g_scope            logger_logs.scope%TYPE;
          g_job_id           NUMBER;
          g_no_prior_run     BOOLEAN DEFAULT TRUE;
          g_approve          VARCHAR2(1) DEFAULT 'N';
          g_log_file_name    VARCHAR2(400);
          g_output_file_name VARCHAR2(400);
          g_directory        VARCHAR2(100) DEFAULT 'LOGDATA';
          g_logger_identifier NUMBER;
  
          l_params           logger.tab_param;  
          l_err_count        NUMBER;
  
          -- Exception handlers
          E_UNEXPECTED       EXCEPTION;
          DML_ERRORS         EXCEPTION;
  
          CURSOR c_dm_tables IS
          SELECT inv.invoice_date,
                 inv.invoice_date contribution_date,
                 inv.country_code,
                 inv.company_id_no,
                 inv.release_date,
                 inv.payment_date,
                 inv.payment_amt,
                 inv.payment_exch_rate exchange_rate, 
                 inv.currency_code,
                 invd.fee_type_amt, 
                 invd.fee_type_exch_amt,
                 invd.FEE_TYPE_DESC fee_desc,
                 invd.username
            FROM invoice_dm         inv,
                 invoice_detail_dm  invd
           WHERE inv.invoice_no     = invd.invoice_no;
  
  
  
    PROCEDURE write_csv(p_file_name IN VARCHAR2, p_query IN VARCHAR2) IS
  
  
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
  
     -- commissions_pkg.write_to_file(  p_file_name,p_query);
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
    END write_csv;
  
    PROCEDURE update_invoice_no IS
  
      CURSOR c_recon is
      WITH comms_calc as (
                          SELECT  TRUNC(calculation_datetime) calculation_datetime,
                                  company_id_no,
                                  sum(comms_calculated_amt) comms_calculated_amt, 
                                  sum(comms_calculated_exch_amt) comms_calculated_exch_amt,
                                  exchange_rate_currency_code, 
                                  payment_currency
                             FROM lhhcom.comms_calc_snapshot
                            WHERE country_code      = g_country
                              AND invoice_no        = 0
                            GROUP BY calculation_datetime,company_id_no, 
                                     exchange_rate_currency_code, 
                                     payment_currency
                            ORDER BY calculation_datetime asc),
                  inv as (select inv.invoice_no,inv.invoice_date, inv.invoice_type_id_no,TRUNC(payment_receive_date)payment_receive_date, country_code, release_date, payment_date, payment_amt,
                         invd.fee_type_amt, fee_type_exch_amt, fee_type_desc, inv.company_id_no,inv.currency_code
                          from lhhcom.invoice inv, lhhcom.invoice_detail invd
                          where inv.invoice_no = invd.invoice_no
                            AND  INV.INVOICE_TYPE_ID_NO = 1
                            AND inv.country_code = g_country
                           and not exists (select 'x' from lhhcom.comms_calc_snapshot where invoice_no = inv.invoice_no and country_code = g_country)
                           ORDER BY inv.payment_receive_date asc)
        SELECT inv.company_id_no ,
               inv.invoice_no, 
               inv.payment_receive_date, 
               comms_calc.exchange_rate_currency_code, 
               inv.currency_code invoice_currency,
               SUM(comms_calc.comms_calculated_amt) TOTAL_COMMS_CALC,
               inv.fee_type_amt total_inv, 
               (inv.fee_type_amt-SUM(comms_calc.comms_calculated_amt)) diff_total,
               SUM(comms_calc.comms_calculated_exch_amt) total_comms_exch,
               inv.fee_type_exch_amt total_inv_exch,
               (inv.fee_type_exch_amt-SUM(comms_calc.comms_calculated_exch_amt)) diff_exch,
               inv.payment_amt total_inv_payment,
               min(comms_calc.calculation_datetime) min_calc_date,
               max(comms_calc.calculation_datetime) max_calc_date,
               null comms_calc_snapshot_no
          FROM comms_calc, inv 
         WHERE (comms_calc.calculation_datetime > (SELECT max(payment_receive_date)
                                                   FROM lhhcom.invoice DT 
                                                   WHERE DT.payment_receive_date < inv.payment_receive_date
                                                    and company_id_no = inv.company_id_no
                                                    and dt.country_code = g_country
                                                   ) 
          AND comms_calc.calculation_datetime   <= inv.payment_receive_date) 
          AND comms_calc.company_id_no          = inv.company_id_no
          AND TRIM(inv.currency_code)           = TRIM(comms_calc.exchange_rate_currency_code)
        GROUP BY inv.invoice_no,inv.company_id_no 
                 ,inv.payment_receive_date 
                 ,inv.fee_type_amt  
                 ,inv.fee_type_exch_amt 
                 ,inv.payment_amt
                 ,comms_calc.exchange_rate_currency_code
                 ,inv.currency_code
         ORDER BY 1,2 ASC;
  
  
         CURSOR c_update_invoice_no IS
         SELECT csiv.invoice_no,
                ccc.comms_calc_snapshot_no
           FROM lhhcom.comms_calc_snapshot      ccc, 
                lhhcom.comms_snapshot_invupd_dm csiv
          WHERE ccc.country_code                = g_country
            AND ccc.invoice_no                  = 0
            AND TRUNC(ccc.calculation_datetime) BETWEEN  TRUNC(csiv.min_calc_date) AND TRUNC(csiv.max_calc_date);
  
         TYPE comms_invoice_t                IS TABLE OF c_update_invoice_no%ROWTYPE INDEX BY PLS_INTEGER;
         comms_invoice_local                 comms_invoice_t; 
  
          TYPE comms_recon_t                IS TABLE OF c_recon%ROWTYPE INDEX BY PLS_INTEGER;
         comms_recon_local                  comms_recon_t; 
  
  
    BEGIN
  
  
  
        IF  g_pre_load = 'Y'  THEN  
  
  
          OPEN c_recon;
  
          LOOP
            FETCH c_recon BULK COLLECT INTO comms_recon_local LIMIT 100000;
  
  
  
              BEGIN
               FORALL idx IN 1 .. comms_recon_local.COUNT SAVE EXCEPTIONS -- here to manage the DUP_VAL_ON_INDEX
  
                 INSERT INTO LHHCOM.COMMS_SNAPSHOT_INVUPD_DM VALUES comms_recon_local(idx);
  
  
                 EXIT WHEN comms_recon_local.COUNT = 0;
  
              EXCEPTION
  
                   WHEN DML_ERRORS THEN
                     l_err_count := SQL%BULK_EXCEPTIONS.COUNT;
                     FOR i IN 1 .. l_err_count LOOP
                      IF SQL%BULK_EXCEPTIONS(i).ERROR_CODE > 0 THEN
                       commissions_pkg.write_to_file(  g_log_file_name,'bulk insert failed: ' || SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
                      ELSE
                       commissions_pkg.write_to_file(  g_log_file_name,'bulk insert failed: ' || SQLERRM(SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
                      END IF;
                     END LOOP;
              END;
  
            END LOOP;     
            CLOSE c_recon;
  
         ELSE 
            IF g_approve = 'Y' THEN 
                OPEN c_update_invoice_no;
  
                FETCH c_update_invoice_no BULK COLLECT INTO comms_invoice_local LIMIT 100000;
  
                LOOP
  
                  BEGIN
                    FORALL idx IN 1 .. comms_invoice_local.COUNT SAVE EXCEPTIONS -- here to manage the DUP_VAL_ON_INDEX
  
                     UPDATE lhhcom.comms_calc_snapshot 
                       SET invoice_no             = comms_invoice_local(idx).invoice_no
                     WHERE comms_calc_snapshot_no = comms_invoice_local(idx).comms_calc_snapshot_no;
  
                     EXIT WHEN comms_invoice_local.COUNT = 0;
  
                  EXCEPTION
  
                       WHEN DML_ERRORS THEN
                         l_err_count := SQL%BULK_EXCEPTIONS.COUNT;
                         FOR i IN 1 .. l_err_count LOOP
                          IF SQL%BULK_EXCEPTIONS(i).ERROR_CODE > 0 THEN
                           commissions_pkg.write_to_file(  g_log_file_name,'bulk insert failed: ' || SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
                          ELSE
                          commissions_pkg.write_to_file(  g_log_file_name,'bulk insert failed: ' || SQLERRM(SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
                          END IF;
                         END LOOP; 
                  END;
                 END LOOP;
                  CLOSE c_update_invoice_no;
              END IF;    
          END IF;
  
  
         COMMIT;
  
         IF g_approve = 'Y' THEN
  
            dbms_stats.gather_table_stats (
                                             ownname    => 'LHHCOM',
                                             tabname    => 'COMMS_CALC_SNAPSHOT');
  
           write_csv(g_output_file_name,'SELECT * FROM lhhcom.comms_calc_snapshot WHERE country_code = '||g_country);
  
         ELSE 
            dbms_stats.gather_table_stats (
                                             ownname    => 'LHHCOM',
                                             tabname    => 'COMMS_CALC_SNAPSHOT_DM');
           write_csv(g_output_file_name,'SELECT * FROM LHHCOM.COMMS_SNAPSHOT_INVUPD_DM');
  
         END IF;
  
         -- after everything ensure that for the groups the invoice totals match
         -- check that the groups for the invoice side have not been loaded before 
         -- if they have then you need to remove the invoice data
  
  
  
    EXCEPTION 
      WHEN OTHERS THEN
       CLOSE c_recon;
       CLOSE c_update_invoice_no;
    END update_invoice_no;
  
    PROCEDURE load_history(p_type IN VARCHAR2) IS
  
      cursor c_history is
      SELECT invoice_date,
             contribution_date,
             country_code,
             company_id_no,
             payment_date,     
             (CASE WHEN payment_date IS NULL THEN 
                  NULL
              ELSE 
                  contribution_date
              END) release_date,
             currency_code,
             fee_desc,
             username,
             header_amt,
             (CASE WHEN payment_date IS NULL   /*START to confirm with Sharon on testing*/
                   THEN NULL
              ELSE (header_amt * -1)
              END) payment_amt,
              (CASE WHEN payment_date IS NULL THEN
                   payment_amt ELSE
                   (payment_amt*-1) 
               end)    fee_type_amt,
               (CASE WHEN payment_date IS NULL THEN
                    (comms_calculated_excg_amt) else
                    (comms_calculated_excg_amt*-1)
             END) fee_type_exch_amt, /*end to confirm with Sharon on testing*/
             exchange_rate,
             comms_calculated_excg_amt
        FROM (
      select to_date(trim(ad_dt_stamp),'yyyy-mm-dd') invoice_date,
             to_date(trim(ad_dt_stamp),'yyyy-mm-dd') contribution_date,
             trim(co_street_country) country_code,
             trim(ag_code) company_id_no,
             (case when cm_dt_pay > 0 THEN 
                  to_date(trim(cm_dt_pay),'yyyy-mm-dd')
              else 
                  null 
              end) as payment_date,     
             trim(cur_key) currency_code,
             trim(cm_narration) fee_desc,
             trim(u_user) username,
             sum(to_number(trim(cm_conv_amt_excl))) header_amt,
             sum(to_number(trim(cm_amt_excl_vat))) payment_amt,
             sum(to_number(trim(ag_rate_used))) exchange_rate,
             sum(to_number(trim(cm_conv_amt_excl))) comms_calculated_excg_amt
        from saghist@MEDWARE.LIBERTY.CO.ZA com,
             contacts@MEDWARE.LIBERTY.CO.ZA c
       where 'SC'||trim(com.s_scheme) = trim(c.k_common_key)
         and trim(cm_rectr_type) = p_type -- 'JNL' OR 'PAYM'
         and trim(com.s_scheme) in (
                        select REGEXP_SUBSTR(g_scheme,'[^,]+',1,level) from dual
                        connect by regexp_substr(g_scheme,'[^,]+',1,level) is not null
                        )
        and trim(co_street_country) = g_country
        -- and (    floor(months_between(sysdate, to_date(trim(ad_dt_stamp),'yyyy-mm-dd'))) <= 24
       --       or trim(cm_dt_pay) = 0) -- T.PERCY COMMENTED OUT INPUT DATE TO BE COMPLETED BY THE USER
        and (trim(ad_dt_stamp) >= g_as_from_date      
           or trim(cm_dt_pay) = 0)
       group by to_date(trim(ad_dt_stamp),'yyyy-mm-dd') ,
                to_date(trim(ad_dt_stamp),'yyyy-mm-dd') ,
                trim(co_street_country) ,
                trim(ag_code) ,
                cm_dt_pay,
                trim(cur_key) ,
                trim(cm_narration) ,
                trim(u_user)
      having    sum(to_number(trim(cm_conv_amt_excl))) <> 0
             OR sum(to_number(trim(cm_amt_excl_vat))) <> 0) info
        WHERE NOT EXISTS (SELECT 'X' FROM invoice where country_code = g_country);
  
  
  
  
       l_invoice_type_id                     invoice.invoice_type_id_no%TYPE;
       l_default_id                           NUMBER DEFAULT 1;
       ln_id_no                               VARCHAR2(20);
       l_company_id_no                        NUMBER;
       l_invoice_no                           NUMBER;
       l_table                                VARCHAR2(100);  
       l_det_table                            VARCHAR2(100);
       l_invoice_insert                       VARCHAR2(30000);
       l_detail_insert                        VARCHAR2(30000);
       l_null                                 VARCHAR2(20) DEFAULT NULL;
    BEGIN
  
     -- SAVEPOINT SAVEPOINT_HISTORY;
       IF g_pre_load = 'Y' AND g_no_prior_run THEN
        DELETE FROM INVOICE_DM;
        DELETE FROM INVOICE_DETAIL_DM;
        COMMIT;
        g_no_prior_run := FALSE;
      END IF;
      commissions_pkg.write_to_file(  g_log_file_name,'History Load has started For - '||p_type);
  
      -- USE THE bulk collect to insert all the rows - improves performance -- instead of going row by row
      IF g_pre_load    = 'Y' THEN 
         l_table       := 'invoice_dm';
         l_det_table   := 'invoice_detail_dm';
  
         FOR c_rec in c_history LOOP
  
            BEGIN
  
              ln_id_no := check_if_number(trim(c_rec.company_id_no));  
  
              IF ln_id_no IS NULL THEN
  
                  l_company_id_no   := TRIM(c_rec.company_id_no);
  
              ELSE
  
                  l_company_id_no := get_company_id_no(trim(c_rec.company_id_no));
  
              END IF;
              IF p_type = 'JNL' THEN
                 l_invoice_type_id := 2;
              ELSE
                 l_invoice_type_id := 1;
              END IF;
  
              IF l_company_id_no is not null then
                 commissions_pkg.write_to_file(  g_log_file_name,'Inserting information into the '||l_table ||' and '||l_det_table);
                l_invoice_no := round(dbms_random.value(1,999999));
  
  
                l_invoice_insert   := 'insert into '||l_table||' VALUES (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16,:17)';
                l_detail_insert    := 'insert into '||l_det_table||' VALUES (:1,:2,:3,:4,:5,:6,:7)';
  
  
                EXECUTE IMMEDIATE l_invoice_insert USING  l_invoice_no,c_rec.invoice_date,c_rec.contribution_date,c_rec.country_code,
                                                              c_rec.company_id_no,l_invoice_type_id,c_rec.release_date, l_null, c_rec.payment_date, l_null,l_null,
                                                              c_rec.payment_amt,c_rec.exchange_rate, c_rec.currency_code,SYSDATE, c_rec.username, l_null;
                EXECUTE IMMEDIATE l_detail_insert USING   l_invoice_no, l_default_id,c_rec.fee_type_amt, c_rec.fee_type_exch_amt,
                                                              c_rec.fee_desc, SYSDATE, c_rec.username; 
  
              END IF;
  
              EXCEPTION
  
                WHEN OTHERS THEN 
                    commissions_pkg.write_to_file(  g_log_file_name,'Unexpected Error occurred in load History for  : '||sqlerrm);
                    commissions_pkg.write_to_file(  g_log_file_name,'Record Loading at time of error - Invoice No : '||l_invoice_no);
                    commissions_pkg.write_to_file(  g_log_file_name,'Invoice Date                                 : '||c_rec.invoice_date);
                    commissions_pkg.write_to_file(  g_log_file_name,'Contribution Date                            : '||c_rec.contribution_date);
                    commissions_pkg.write_to_file(  g_log_file_name,'Country Code                                 : '||c_rec.country_code);
                    commissions_pkg.write_to_file(  g_log_file_name,'Brokerage Code                               : '||c_rec.company_id_no);
                    commissions_pkg.write_to_file(  g_log_file_name,'Payment Date                                 : '||c_rec.payment_date);
                    commissions_pkg.write_to_file(  g_log_file_name,'Payment Amount                               : '||c_rec.payment_date);
                    commissions_pkg.write_to_file(  g_log_file_name,'Currency Code                                : '||c_rec.currency_code);
  
              END;
  
          END LOOP;
  
  
      ELSE
        l_table       := 'invoice';
        l_det_table   := 'invoice_detail';
  
        IF g_approve = 'Y' THEN
          FOR c_rec IN c_dm_tables LOOP
  
  
           BEGIN
               l_invoice_no := invoice_no_seq.nextval;
               l_invoice_insert   := 'insert into '||l_table||' VALUES (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16,:17)';
               l_detail_insert    := 'insert into '||l_det_table||' VALUES (:1,:2,:3,:4,:5,:6,:7)';
  
  
               EXECUTE IMMEDIATE l_invoice_insert USING  l_invoice_no,c_rec.invoice_date,c_rec.contribution_date,c_rec.country_code,
                                                                  c_rec.company_id_no,l_invoice_type_id,c_rec.release_date, l_null, c_rec.payment_date, l_null,l_null,
                                                                  c_rec.payment_amt,c_rec.exchange_rate, c_rec.currency_code,SYSDATE, c_rec.username, l_null;
               EXECUTE IMMEDIATE l_detail_insert USING   l_invoice_no, l_default_id,c_rec.fee_type_amt, c_rec.fee_type_exch_amt,
                                                                  c_rec.fee_desc, SYSDATE, c_rec.username; 
            EXCEPTION
  
                WHEN OTHERS THEN 
                    commissions_pkg.write_to_file(  g_log_file_name,'Unexpected Error occurred in load History for  : '||sqlerrm);
                    commissions_pkg.write_to_file(  g_log_file_name,'Record Loading at time of error - Invoice No : '||l_invoice_no);
                    commissions_pkg.write_to_file(  g_log_file_name,'Invoice Date                                 : '||c_rec.invoice_date);
                    commissions_pkg.write_to_file(  g_log_file_name,'Contribution Date                            : '||c_rec.contribution_date);
                    commissions_pkg.write_to_file(  g_log_file_name,'Country Code                                 : '||c_rec.country_code);
                    commissions_pkg.write_to_file(  g_log_file_name,'Brokerage Code                               : '||c_rec.company_id_no);
                    commissions_pkg.write_to_file(  g_log_file_name,'Payment Date                                 : '||c_rec.payment_date);
                    commissions_pkg.write_to_file(  g_log_file_name,'Payment Amount                               : '||c_rec.payment_date);
                    commissions_pkg.write_to_file(  g_log_file_name,'Currency Code                                : '||c_rec.currency_code);
  
              END;
          END LOOP;
        END IF; 
      END IF;
  
      commissions_pkg.write_to_file(  g_log_file_name,'performed a commit');
      COMMIT;
  
      write_csv(g_output_file_name,'SELECT * FROM '||l_table||' inv,'||l_det_table ||' det  WHERE inv.invoice_no = det.invoice_no');
  
  
  
    EXCEPTION
      WHEN OTHERS THEN
       --  ROLLBACK TO SAVEPOINT_HISTORY;
         commissions_pkg.write_to_file(  g_log_file_name,'Unexpected Error occurred in load History '||SQLERRM);
    END load_history;
  
    PROCEDURE load_invoice_tbp IS
  
     cursor c_invoices_to_be_paid is
      select to_date(trim(ad_dt_stamp),'yyyy-mm-dd') invoice_date,
             to_date(trim(ad_dt_stamp),'yyyy-mm-dd') contribution_date,
             trim(co_street_country) country_code,
             trim(ag_code) company_id_no,
             trim(cur_key) currency_code,
             trim(cm_narration) fee_desc,
             trim(u_user) username,
             sum(to_number(trim(cm_conv_amt_excl))) header_amt,
             sum(to_number(trim(cm_amt_excl_vat))) payment_amt,
             sum(to_number(trim(ag_rate_used))) exchange_rate,
             sum(to_number(trim(cm_conv_amt_excl))) comms_calculated_excg_amt
        from saghist@MEDWARE.LIBERTY.CO.ZA com,
             contacts@MEDWARE.LIBERTY.CO.ZA c
       where 'SC'||trim(com.s_scheme) = trim(c.k_common_key)
          and trim(cm_rectr_type)     = 'RUN'
          and trim(cm_dt_pay)         = 0
          AND trim(com.s_scheme) in (
                            select trim(REGEXP_SUBSTR(g_scheme,'[^,]+',1,level)) from dual
                            connect by regexp_substr(g_scheme,'[^,]+',1,level) is not null
                            )  
          --and trim(s_scheme) in ('IBUG', 'LBLU')     -- LS in ('LHLS')--not in ('BMIR','IMED','ESMA','HERI','CFC')
          --and substr(s_scheme,0,1) not in ('A','O','U')
          and trim(co_street_country) = g_country
        group by to_date(trim(ad_dt_stamp),'yyyy-mm-dd'),
                 to_date(trim(ad_dt_stamp),'yyyy-mm-dd'),
                 trim(co_street_country),
                 trim(ag_code),
                 trim(cur_key),
                 trim(cm_narration),
                 trim(u_user)
      having    sum(to_number(trim(cm_conv_amt_excl))) <> 0
             OR sum(to_number(trim(cm_amt_excl_vat))) <> 0
      order by 4, 1;
  
       ln_id_no                               VARCHAR2(20);
       l_company_id_no                        NUMBER;
       l_invoice_no                           NUMBER;
       l_table                                VARCHAR2(100);  
       l_det_table                            VARCHAR2(100);
       l_invoice_insert                       VARCHAR2(30000);
       l_detail_insert                        VARCHAR2(30000);
       l_null                                 VARCHAR2(20) DEFAULT NULL;
  
    BEGIN 
      SAVEPOINT JOURNAL;
      commissions_pkg.write_to_file(  g_log_file_name,'History Load for Unpaid Invoices has started');
      -- set g_scope to be a request Number with value of what it is for
    --  g_scope := lhhcom.commissions_job_id.nextval||' - '||'Data Migration Load '||g_country||' pre load '||g_pre_load;
      -- USE THE bulk collect to insert all the rows - improves performance -- instead of going row by row
      IF g_pre_load    = 'Y' THEN 
         l_table       := 'invoice_dm';
         l_det_table   := 'invoice_detail_dm';
  
  
       FOR c_rec in c_invoices_to_be_paid loop
  
         BEGIN
  
          ln_id_no := check_if_number(trim(c_rec.company_id_no));  
  
          IF ln_id_no IS NULL THEN
  
              l_company_id_no   := TRIM(c_rec.company_id_no);
  
          ELSE
  
              l_company_id_no := get_company_id_no(trim(c_rec.company_id_no));
  
          END IF;
  
          IF l_company_id_no is not null then
  
            IF g_pre_load = 'N' then
  
              l_invoice_no := invoice_no_seq.nextval;
  
                l_invoice_insert   := 'insert into '||l_table||' VALUES (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16,:17)';
                l_detail_insert    := 'insert into '||l_det_table||' VALUES (:1,:2,:3,:4,:5,:6,:7)';
  
                EXECUTE IMMEDIATE l_invoice_insert USING  l_invoice_no,c_rec.invoice_date,c_rec.contribution_date,c_rec.country_code,
                                                          c_rec.company_id_no,1,l_null, l_null, l_null, l_null,l_null,
                                                          l_null,c_rec.exchange_rate, c_rec.currency_code,SYSDATE, c_rec.username, l_null;
                EXECUTE IMMEDIATE l_detail_insert USING   l_invoice_no, 1,c_rec.payment_amt, c_rec.comms_calculated_excg_amt,
                                                          c_rec.fee_desc, SYSDATE, c_rec.username; 
  
            END IF;
          END IF;
  
         EXCEPTION
  
            WHEN OTHERS THEN 
  
               commissions_pkg.write_to_file(  g_log_file_name,'Unexpected Error occurred in load Unpaid Invoices  : '||sqlerrm);
               commissions_pkg.write_to_file(  g_log_file_name,'Record Loading at time of error - Invoice No       : '||l_invoice_no);
               commissions_pkg.write_to_file(  g_log_file_name,'Invoice Date                                       : '||c_rec.invoice_date);
               commissions_pkg.write_to_file(  g_log_file_name,'Contribution Date                                  : '||c_rec.contribution_date);
               commissions_pkg.write_to_file(  g_log_file_name,'Country Code                                       : '||c_rec.country_code);
               commissions_pkg.write_to_file(  g_log_file_name,'Brokerage Code                                     : '||c_rec.company_id_no);
               commissions_pkg.write_to_file(  g_log_file_name,'Currency Code                                      : '||c_rec.currency_code);
  
  
         END;
  
        END LOOP;  
      ELSE
        l_table       := 'invoice';
        l_det_table   := 'invoice_detail';
  
        IF g_approve = 'Y' THEN
          FOR c_rec IN c_dm_tables LOOP
  
  
           BEGIN
               l_invoice_no := invoice_no_seq.nextval;
               l_invoice_insert   := 'insert into '||l_table||' VALUES (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16,:17)';
               l_detail_insert    := 'insert into '||l_det_table||' VALUES (:1,:2,:3,:4,:5,:6,:7)';
  
  
               EXECUTE IMMEDIATE l_invoice_insert USING  l_invoice_no,c_rec.invoice_date,c_rec.contribution_date,c_rec.country_code,
                                                                  c_rec.company_id_no,1,c_rec.release_date, l_null, c_rec.payment_date, l_null,l_null,
                                                                  c_rec.payment_amt,c_rec.exchange_rate, c_rec.currency_code,SYSDATE, c_rec.username, l_null;
               EXECUTE IMMEDIATE l_detail_insert USING   l_invoice_no, 1,c_rec.fee_type_amt, c_rec.fee_type_exch_amt,
                                                                  c_rec.fee_desc, SYSDATE, c_rec.username; 
            EXCEPTION
  
                WHEN OTHERS THEN 
                    commissions_pkg.write_to_file(  g_log_file_name,'Unexpected Error occurred in load History for  : '||sqlerrm);
                    commissions_pkg.write_to_file(  g_log_file_name,'Record Loading at time of error - Invoice No : '||l_invoice_no);
                    commissions_pkg.write_to_file(  g_log_file_name,'Invoice Date                                 : '||c_rec.invoice_date);
                    commissions_pkg.write_to_file(  g_log_file_name,'Contribution Date                            : '||c_rec.contribution_date);
                    commissions_pkg.write_to_file(  g_log_file_name,'Country Code                                 : '||c_rec.country_code);
                    commissions_pkg.write_to_file(  g_log_file_name,'Brokerage Code                               : '||c_rec.company_id_no);
                    commissions_pkg.write_to_file(  g_log_file_name,'Payment Date                                 : '||c_rec.payment_date);
                    commissions_pkg.write_to_file(  g_log_file_name,'Payment Amount                               : '||c_rec.payment_date);
                    commissions_pkg.write_to_file(  g_log_file_name,'Currency Code                                : '||c_rec.currency_code);
  
              END;
          END LOOP;
        END IF; 
      END IF; 
      COMMIT;
  
       --create the csv file
  
       write_csv(g_output_file_name,'SELECT * FROM '||l_table||' inv,'||l_det_table ||' det  WHERE inv.invoice_no = det.invoice_no');
  
  
    EXCEPTION
      WHEN OTHERS THEN
       ROLLBACK TO SAVEPOINT JOURNAL;
       commissions_pkg.write_to_file(  g_log_file_name,'Unexpected Error occurred in load Unpaid Invoices     : '||sqlerrm);
    END load_invoice_tbp;
  
    PROCEDURE load_comms_history IS
  
        CURSOR c_comms_history IS
         SELECT  (CASE WHEN g_pre_load = 'Y' THEN
                     lhhcom.COMMS_DM_SEQUENCE.nextval ELSE
                    comms_calc_snapshot_seq.nextval
                 END) comms_calc_snapshot_no
                 ,ccs.country_code                
                 ,ccs.product_code                
                 ,ccs.poep_id
                 ,ccs.person_code                 
                 ,ccs.policy_code                 
                 ,ccs.group_code                  
                 ,ccs.broker_id_no                
                 ,ccs.broker_id_no company_id_no
                 ,ccs.comms_perc                  
                 ,ccs.contribution_date           
                 ,ccs.contribution_date           payment_receive_date        
                 ,0 finance_receipt_no
                 ,ccs.calculation_datetime
                 ,'P' comms_calc_type_code        
                 ,ccs.payment_receive_amt
                 ,ccs.base_cur payment_currency            
                 ,ccs.comms_calculated_amt
                 ,ccs.exch_rate exchange_rate
                 ,ccs.cur_key exchange_rate_currency_code 
                 ,ccs.comms_calculated_exc_amt comms_calculated_exch_amt   
                 ,0                               invoice_no                  
                 ,SYSDATE                         last_update_datetime        
                 ,'Medware'                       username,
                 fusion.bu
        FROM (   SELECT 
    		 country_code
    		,product_code
    		,person_code
    		,policy_code
    		,group_code
            ,NVL(CASE 
                        WHEN isvalid_person_code(PERSON_CODE)  = 'TRUE' THEN 
                            get_poep_id(p_date => CONTRIBUTION_DATE, p_person => PERSON_CODE)
                        WHEN isvalid_policy_code(PERSON_CODE)  = 'TRUE' THEN 
                           get_poep_id(p_date => CONTRIBUTION_DATE, p_policy => PERSON_CODE)
                      END, 
                  0) poep_id
    		,broker_id_no
    		,contribution_date
    		,calculation_datetime
    		,base_cur
    		,cur_key
    		,max(exch_rate)                exch_rate
    		,max(comms_perc)               comms_perc
    		,sum(payment_receive_amt)      payment_receive_amt
    		,sum(comms_calculated_exc_amt) comms_calculated_exc_amt
    		,sum(comms_calculated_amt)     comms_calculated_amt
    	    FROM (
    		  SELECT trim(com.ag_code)                           broker_id_no
    			,trim(com.g_group)                               group_code
    			,trim(co_street_country)                         country_code
    			,trim(com.o_option)                              product_code
    			,trim(com.m_member)                              policy_code
    			,trim(mem.m_member) || '-' || trim(mem.b_depend) person_code
    			,sch.s_base_cur                                  base_cur
    			,cur_key
    			,to_date(trim(sa_dt_subs),'yyyy-mm-dd')          contribution_date
    			,to_date(trim(cm_dt_run),'yyyy-mm-dd')           calculation_datetime
    			,CASE WHEN to_number(trim(cm_amt_excl_vat)) = 0 THEN 0
    			      ELSE round(sum(to_number(trim(cm_conv_amt_excl))) / sum(to_number(trim(cm_amt_excl_vat))),9)
    			  END                                            exch_rate
    			,sum(to_number(trim(cm_1st_recu_amt)))           comms_perc
    			,CASE WHEN trim(cm_tran_type)= 'PADJ' THEN (sum(to_number(trim(cm_amt_excl_vat))) * sum(to_number(trim(cm_1st_recu_amt))))
    			      ELSE sum(to_number(trim(cm_subs_paid*-1)))
    			  END                                            payment_receive_amt
    			,sum(to_number(trim(cm_conv_amt_excl)))          comms_calculated_exc_amt
    			,sum(to_number(trim(cm_amt_excl_vat)))           comms_calculated_amt
    		    FROM commhist@medware.liberty.co.za com
    		    LEFT OUTER
    		    JOIN (select co_street_country, trim(REPLACE(k_common_key,'SC','')) k_common_key
                        from contacts@MEDWARE.LIBERTY.CO.ZA
                        WHERE 1=1
                        AND k_common_key LIKE 'SC%'
                        AND trim(REPLACE(k_common_key,'SC','')) in (
                        select REGEXP_SUBSTR(g_scheme,'[^,]+',1,level) from dual
                        connect by regexp_substr(g_scheme,'[^,]+',1,level) is not null
                        )) con
    		      ON trim(com.s_scheme) = trim(con.k_common_key)
    		    LEFT OUTER
    		    JOIN scheme@MEDWARE.LIBERTY.CO.ZA                              sch
    		      ON trim(sch.s_scheme) = trim(com.s_scheme)
                  AND sch.s_scheme in (
                        select REGEXP_SUBSTR(g_scheme,'[^,]+',1,level) from dual
                        connect by regexp_substr(g_scheme,'[^,]+',1,level) is not null
                        )
    		    LEFT OUTER
    		    JOIN member@MEDWARE.LIBERTY.CO.ZA                              mem
    		      ON com.m_member = mem.m_member
    		   WHERE  1=1
               AND (    cm_dt_run >= g_as_from_date --20160901 
    			      OR  cm_dt_pay = 0)
    			 AND cm_post_status = 'P'
    			 AND trim(com.s_scheme) in (
                        select trim(REGEXP_SUBSTR(g_scheme,'[^,]+',1,level)) from dual
                        connect by regexp_substr(g_scheme,'[^,]+',1,level) is not null
                        )
    			 AND (    0 <> (SELECT sum(to_number(trim(cm_amt_excl_vat))) 
    					  FROM commhist@MEDWARE.LIBERTY.CO.ZA
    					 WHERE  ag_code = com.ag_code
    					       AND g_group  = com.g_group
                             AND o_option = com.o_option
    					       AND m_member = com.m_member
    					       AND cur_key = com.cur_key
    					       AND cm_tran_type = com.cm_tran_type
    					       AND sa_dt_subs = com.sa_dt_subs
    					       AND cm_dt_run = com.cm_dt_run)
    			      OR  0 <> (SELECT sum(to_number(trim(cm_conv_amt_excl)))
    					  FROM commhist@MEDWARE.LIBERTY.CO.ZA
    					 WHERE     ag_code = com.ag_code
    					       AND g_group = com.g_group
    					       AND o_option = com.o_option
    					       AND m_member = com.m_member
    					       AND cur_key = com.cur_key
    					       AND cm_tran_type = com.cm_tran_type
    					       AND sa_dt_subs = com.sa_dt_subs
    					       AND cm_dt_run = com.cm_dt_run))         
    		   GROUP BY trim(com.ag_code) 
    			   ,trim(com.g_group)
    			   ,trim(co_street_country)
    			   ,trim(com.o_option)
    			   ,trim(com.m_member)
    			   ,trim(mem.m_member) || '-' || trim(mem.b_depend)
    			   ,sch.s_base_cur
    			   ,cur_key
    			   ,trim(cm_tran_type)
    			   ,to_date(trim(sa_dt_subs),'yyyy-mm-dd')
    			   ,to_date(trim(cm_dt_run),'yyyy-mm-dd')
    			   ,to_number(trim(cm_amt_excl_vat)))
    	   GROUP BY
    		    country_code
    		   ,product_code
    		   ,person_code
    		   ,policy_code
    		   ,group_code
    		   ,broker_id_no
    		   ,contribution_date
    		   ,calculation_datetime
    		   ,base_cur
    		   ,cur_key
               ,NVL(CASE 
                        WHEN isvalid_person_code(PERSON_CODE)  = 'TRUE' THEN 
                            get_poep_id(p_date => CONTRIBUTION_DATE, p_person => PERSON_CODE)
                        WHEN isvalid_policy_code(PERSON_CODE)  = 'TRUE' THEN 
                           get_poep_id(p_date => CONTRIBUTION_DATE, p_policy => PERSON_CODE)
                      END, 
                  0)) ccs,
             (SELECT ORGANIZATION_NAME bu,
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
               WHERE PROCESS_NAME = 'FUSION_ORGANIZATIONS'
                  AND LEDGER_NAME <> 'THT Nigeria') fusion     
        WHERE 1=1    
          AND fusion.country    = ccs.country_code
          AND NOT EXISTS (SELECT 'X' 
                            FROM comms_calc_snapshot 
                           WHERE country_code = g_country 
                             AND  trim(group_code) = ccs.group_code
                          ); -- check to ensure not migrated -- need to change this as if one group exists will meet */
  
       CURSOR c_comms_dm_history IS
       SELECT  comms_calc_snapshot_seq.nextval
               ,COUNTRY_CODE
               ,PRODUCT_CODE
               ,POEP_ID
               ,PERSON_CODE
               ,POLICY_CODE
               ,GROUP_CODE
               ,BROKER_ID_NO
               ,COMPANY_ID_NO
               ,COMMS_PERC
               ,CONTRIBUTION_DATE
               ,PAYMENT_RECEIVE_DATE
               ,FINANCE_RECEIPT_NO
               ,CALCULATION_DATETIME
               ,COMMS_CALC_TYPE_CODE
               ,PAYMENT_RECEIVE_AMT
               ,PAYMENT_CURRENCY
               ,COMMS_CALCULATED_AMT
               ,EXCHANGE_RATE
               ,EXCHANGE_RATE_CURRENCY_CODE
               ,COMMS_CALCULATED_EXCH_AMT
               ,INVOICE_NO
               ,LAST_UPDATE_DATETIME
               ,USERNAME
               ,BU
         FROM COMMS_CALC_SNAPSHOT_DM
        WHERE COUNTRY_CODE = G_COUNTRY;
  
  
       l_comms_calc_snapshot               comms_calc_snapshot.comms_calc_snapshot_no%TYPE;
  
       TYPE comms_history_t                IS TABLE OF c_comms_history%ROWTYPE INDEX BY PLS_INTEGER;
       comms_history_local                 comms_history_t;
  
       TYPE comms_dm_history_t             IS TABLE OF c_comms_dm_history%ROWTYPE INDEX BY PLS_INTEGER;
       comms_dm_history_local              comms_dm_history_t;
  
    BEGIN
      
      
      SAVEPOINT COMMS_HISTORY_SVP;
      
      IF g_pre_load = 'Y' THEN
        DELETE FROM COMMS_CALC_SNAPSHOT_DM WHERE COUNTRY_CODE = G_COUNTRY;
        COMMIT;
      END IF;
  
      commissions_pkg.write_to_file(  g_log_file_name,'Data Migration Load for the commissions History Has Started: '||SYSDATE);
  
     
  
      IF g_approve = 'Y' THEN
          OPEN c_comms_dm_history;
  
          LOOP
            FETCH c_comms_dm_history BULK COLLECT INTO comms_dm_history_local LIMIT 100000;
  
  
               BEGIN
  
                   FORALL idx IN 1 .. comms_dm_history_local.COUNT SAVE EXCEPTIONS -- here to manage the DUP_VAL_ON_INDEX
  
                     INSERT INTO comms_calc_snapshot VALUES comms_dm_history_local(idx);
  
  
                     EXIT WHEN comms_dm_history_local.COUNT = 0;
  
                EXCEPTION
  
  
                   WHEN DML_ERRORS THEN
                     l_err_count := SQL%BULK_EXCEPTIONS.COUNT;
                     FOR i IN 1 .. l_err_count LOOP
                      IF SQL%BULK_EXCEPTIONS(i).ERROR_CODE > 0 THEN
                      commissions_pkg.write_to_file(  g_log_file_name,'bulk insert failed: ' || SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
                      ELSE
                      commissions_pkg.write_to_file(  g_log_file_name,'bulk insert failed: ' || SQLERRM(SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
                      END IF;
                     END LOOP;
                   WHEN OTHERS THEN
                      commissions_pkg.write_to_file(  g_log_file_name,'bulk insert failed: ' ||sqlerrm);
                 END;
               FOR idx IN 1 .. comms_history_local.COUNT LOOP
  
                l_comms_calc_snapshot := comms_history_local(idx).comms_calc_snapshot_no;
                INSERT INTO COMMS_CALC_TRACE(comms_calc_snapshot_no,trace_base_snapshot_no, trace_original_snapshot_no)
                 VALUES (l_comms_calc_snapshot,null,null);
                -- INSERT INTO comms_calc_trace(comms_calc_snapshot_no)  VALUES  comms_history_local(idx).comms_calc_snapshot_no;
  
                END LOOP;  
             END LOOP;
  
             CLOSE c_comms_dm_history;
  
         ELSE
  
              OPEN c_comms_history;
  
              LOOP
              FETCH c_comms_history BULK COLLECT INTO comms_history_local LIMIT 100000;
  
  
                  BEGIN
                    FORALL idx IN 1 .. comms_history_local.COUNT SAVE EXCEPTIONS -- here to manage the DUP_VAL_ON_INDEX
  
                     INSERT INTO comms_calc_snapshot_dm VALUES comms_history_local(idx);
  
                     EXIT WHEN comms_history_local.COUNT = 0;
  
                    EXCEPTION
  
                       WHEN DML_ERRORS THEN
                         l_err_count := SQL%BULK_EXCEPTIONS.COUNT;
                         FOR i IN 1 .. l_err_count LOOP
                          IF SQL%BULK_EXCEPTIONS(i).ERROR_CODE > 0 THEN
                           commissions_pkg.write_to_file(  g_log_file_name,'bulk insert failed: ' || SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
                          ELSE
                          commissions_pkg.write_to_file(  g_log_file_name,'bulk insert failed: ' || SQLERRM(SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
                          END IF;
                         END LOOP;
                        WHEN OTHERS THEN
                           commissions_pkg.write_to_file(  g_log_file_name,'bulk insert failed: ' ||sqlerrm);  
                     END;
  
               END LOOP;
               
               DELETE FROM comms_calc_snapshot_dm 
               WHERE group_code NOT IN (SELECT  CASE WHEN substr(com.g_parent_group,1,1) = ' ' THEN
                                                    TRIM(com.g_group)
                                                  ELSE
                                                    TRIM(com.g_parent_group)
                                                  END
                                              FROM groups@MEDWARE.LIBERTY.CO.ZA com  
                                              where 1=1
                                              and NVL(TRIM(com.g_parent_group), TRIM(com.g_group))  IN (
                                                                                    select trim(REGEXP_SUBSTR(g_group_code,'[^,]+',1,level)) from dual
                                                                                    connect by regexp_substr(g_group_code,'[^,]+',1,level) is not null
                                                                                    ));
               COMMIT;
               
               SYS.DBMS_STATS.GATHER_TABLE_STATS('LHHCOM', 'comms_calc_snapshot_dm', CASCADE => TRUE);
  
               CLOSE c_comms_history;
  
          END IF;
  
  
  
         COMMIT;
  
          --generate the csv file
         IF g_approve = 'Y' THEN
  
             write_csv(g_output_file_name,'SELECT * FROM comms_calc_snapshot where country_code ='''||g_country||'''');
  
         ELSE
  
             write_csv(g_output_file_name,'SELECT * FROM comms_calc_snapshot_dm where country_code ='''||g_country||'''');
  
         END IF;
  
  
         commissions_pkg.write_to_file(  g_log_file_name,'Data Migration for the Commissions History has Ended Successfully :'||SYSDATE);
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK TO SAVEPOINT COMMS_HISTORY_SVP;
        commissions_pkg.write_to_file(  g_log_file_name,'Unexpected Error occurred in load Commissions History     : '||sqlerrm);
    END load_comms_history;
  
    PROCEDURE MIGRATE_FROM_MEDWARE(
                              p_stage             IN NUMBER DEFAULT 0
                             ,p_pre_load          IN VARCHAR2 DEFAULT 'Y'
                             ,p_comm_run_date     IN DATE DEFAULT NULL
                             ,p_country           IN VARCHAR2
                             ,p_group_code        IN VARCHAR2 DEFAULT NULL
                             ,p_scheme            IN VARCHAR2 DEFAULT NULL
                             ,p_user_name         IN VARCHAR2 DEFAULT NULL
                             ,p_approve_run       IN VARCHAR2 DEFAULT 'N'
                             ,p_logger_identifer  IN VARCHAR2 DEFAULT NULL
                             ) IS
       l_session_id VARCHAR2(200);
       l_slave_id   NUMBER;
    BEGIN
  
    --SELECT userenv('sessionid')         INTO l_session_id from dual;
     select sys_context('userenv','sid') INTO l_session_id from dual;
     select userenv('PID') into l_slave_id FROM DUAL;
  
     dbms_output.put_line('IDS ARE '||L_SESSION_ID|| ' - '||L_SLAVE_ID);
  
     g_logger_identifier := get_scheduler_job_id(l_session_id,l_slave_id);
  
     g_scope            := g_logger_identifier;
     g_log_file_name    := g_logger_identifier||'.html';
     g_output_file_name := g_logger_identifier||'.csv';
  
     --open up a log and output file to store the run and output information for reference
     commissions_pkg.create_file(  
                          p_file_name     => g_log_file_name,
                          p_process       => 'Data Migration For '||p_country
                        );
  
     commissions_pkg.create_file(  
                          p_file_name     => g_output_file_name,
                          p_process       => 'Data Migration For '||p_country
                        );                   
  
  
     --dbms_session.set_identifier(p_logger_identifer);
     --logger.set_level('DEBUG',sys_context('userenv','client_identifier'));
  
    /*  1) Load Journal History
    *   2) Load Invoice History
    *   3) Load Invoices to Be Paid
    *   4) Load Commissions History
    */
  
  
  
     g_pre_load       := p_pre_load;
     g_approve        := p_approve_run;
     g_as_from_date   := TO_NUMBER(to_char(p_comm_run_date,'YYYYMMDD')); 
     g_country        := p_country; 
     g_scheme         := p_scheme;
     g_no_prior_run   := TRUE;
     g_group_code     := p_group_code;
  
     commissions_pkg.write_to_file(  g_log_file_name,'Loading Information for Stage    '||p_stage);
     commissions_pkg.write_to_file(  g_log_file_name,'Loading Information for Country  '||g_country); 
     commissions_pkg.write_to_file(  g_log_file_name,'Loading Information for Pre Load '||g_pre_load);
     commissions_pkg.write_to_file(  g_log_file_name,'Loading Information from Date    '||g_as_from_date);
     commissions_pkg.write_to_file(  g_log_file_name,'Loading Information for Scheme   '||g_scheme);
     commissions_pkg.write_to_file(  g_log_file_name,'Loading Information for Group    '||g_group_code);
     commissions_pkg.write_to_file(  g_log_file_name,'Loading Information for approval '||g_approve);
  
      -- clear all tables so output is accurate for the business for reconciliation before main run
     IF g_pre_load = 'Y' THEN
  
         DELETE FROM COMMS_CALC_SNAPSHOT_DM;
         DELETE FROM INVOICE_DM;
         DELETE FROM INVOICE_DETAIL_DM;
         DELETE FROM COMMS_SNAPSHOT_INVUPD_DM;
         COMMIT;
     END IF;
  
     IF p_stage = 1 THEN
        load_history('JNL');
     ELSIF p_stage = 2 THEN
        load_history('PAYM');
     ELSIF p_stage = 3 THEN
        load_invoice_tbp;
     ELSIF p_stage = 4 THEN
        load_comms_history;
  
     ELSIF p_stage = 5 THEN
        update_invoice_no;
     ELSE
        load_history('JNL');
        load_history('PAYM');
        load_invoice_tbp;
        load_comms_history;
     END IF;
     --logger.unset_client_level(p_client_id => p_logger_identifer);
     IF p_approve_run = 'Y' THEN
       commissions_pkg.write_to_file(  g_log_file_name,'Approval completed deleting information from staging tables');
       IF p_stage = 4 THEN
         commissions_pkg.write_to_file(  g_log_file_name,'Deleted comms calc snapshot');
         DELETE FROM COMMS_CALC_SNAPSHOT_DM;
       ELSIF p_stage = 6 THEN
         commissions_pkg.write_to_file(  g_log_file_name,'Deleted Invoice information from staging');
         DELETE FROM INVOICE_DETAIL_DM;
         DELETE FROM INVOICE_DM;
       ELSIF p_stage = 5 THEN
         commissions_pkg.write_to_file(  g_log_file_name,'Deleted staging table to sync comms calc with invoices');
         DELETE FROM COMMS_SNAPSHOT_INVUPD_DM;
       ELSE
         NULL;
       END IF;   
     END IF;
  
  
    EXCEPTION
      WHEN E_UNEXPECTED THEN
        commissions_pkg.write_to_file(  g_log_file_name,'Unexpected error occurred in '||gc_scope_prefix||SQLERRM);
      --  logger.unset_client_level(p_client_id => p_logger_identifer);
    END migrate_from_medware;
  
  
END COMMISSIONS_DM_PKG;
/