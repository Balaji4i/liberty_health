SELECT GROUP_CODE, LAST_UPDATE_DATETIME, PAYMENT_TYPE, sum(finance_receipt_amt)
  FROM COMMS_PAYMENTS_RECEIVED
-- WHERE GROUP_CODE = 'EASTHORNUGAN'
 WHERE FINANCE_INVOICE_NO = 3432
 GROUP BY GROUP_CODE, LAST_UPDATE_DATETIME, PAYMENT_TYPE
 ORDER BY 1;
 
 SELECT *
   FROM COMMS_PAYMENTS_RECEIVED
 WHERE FINANCE_INVOICE_NO = 3432;
-- WHERE GROUP_CODE = 'EASTHORNUGAN';

 SELECT *
   FROM COMMS_CALC_SNAPSHOT
  WHERE GROUP_CODE = 'EASTHORNUGAN';

SELECT CALCULATION_DATETIME, INVOICE_NO, GROUP_CODE, sum(PAYMENT_RECEIVE_AMT), sum(COMMS_CALCULATED_AMT)
  FROM COMMS_CALC_SNAPSHOT
-- WHERE GROUP_CODE = 'EASTHORNUGAN'
 WHERE FINANCE_INVOICE_NO = 3432
-- WHERE INVOICE_NO = 3432
 GROUP BY CALCULATION_DATETIME, INVOICE_NO, GROUP_CODE
 ORDER BY 1, 2;

  SELECT ROWID, 
         upld_trn_no, 
         TRIM(substr(dataline,0,100))                application_id,
         TRIM(substr(dataline,101,100))              finance_receipt_no, 
         TRIM(substr(dataline,201,100))              group_code,
         TRIM(substr(dataline,301,4))                country_code, 
         TRIM(substr(dataline,305,100))              product_code,
         TRIM(substr(dataline,405,100))              policy_code,
         TRIM(substr(dataline,505,100))              person_code,
         TRIM(substr(dataline,605,10))               contribution_date,
         TRIM(substr(dataline,615,10))               finance_receipt_date,
         TRIM(substr(dataline,625,100))              finance_invoice_no,
         TRIM(substr(dataline,725,10))               finance_invoice_date,
         TRUNC(nvl(TRIM(replace(replace(substr(dataline,735,100),CHR(13),' '),CHR(10),' ')),0),2) finance_receipt_amt
    from util.upld_trn;
 WHERE TRIM(substr(dataline,625,100)) = '3432';
  
   SELECT *--GROUP_CODE, LAST_UPDATE_DATETIME, PAYMENT_TYPE, count(1), sum(finance_receipt_amt)
-- SELECT max(CONTRIBUTION_DATE)
  FROM COMMS_PAYMENTS_RECEIVED
-- WHERE GROUP_CODE = 'EASTHORNUGAN'
-- WHERE substr(policy_code,1,1) = '0'
 WHERE policy_code LIKE '02451095%';

select get_system_parameter('LB_HEALTH_COMMS','WSO2','SERVER_LINK')
from dual;

select payload from ws_soap_inbound where key_value = 3432;

SELECT ORGANIZATION_NAME
      ,CUSTOMER_NAME    
      ,CUSTOMER_NUMBER  
      ,INVOICE_TYPE     
      ,INVOICE_NO       
      ,DUE_DATE         
      ,TRX_DATE         
      ,GL_DATE          
      ,GL_DATE_CLOSED   
      ,CURRENCY_CODE    
      ,CITY             
      ,PAYMENT_SCHEDULE_CLASS
      ,INVOICE_AMT      
      ,PAYMENT_AMT      
      ,ADJUSTMENTS      
      ,CREDIT_MEMO      
      ,TAX_AMOUNT       
      ,BALANCE_AMT      
      FROM ws_soap_inbound t,    
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
    where t.process_name = 'FUSION_BILLING';

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
          AND t.payload IS NOT NULL -- T.Percy payload null fix 05/11/2020
            AND group_code              = 'EASTHORNUGAN'
            AND invoice_no              = '3432'
            AND RECEIPT_NUMBER          NOT IN (SELECT TO_CHAR(re_receipt_no) re_receipt_no
                                                  FROM COMM_MEDWARE_RECEIPTS_V);

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
         /* decode(instr(C_OHI_LINE_ID,'#'),0,decode(instr(C_OHI_LINE_ID,'_'),0,C_MEMBER_NUMBER,
                       substr(C_OHI_LINE_ID,1,instr(C_OHI_LINE_ID,'_')-1)),
                       substr(C_OHI_LINE_ID,3,instr(C_OHI_LINE_ID,'_')-3)) member_no,*/
           CASE WHEN C_OHI_LINE_ID = '1' THEN  
               decode(instr(C_DEPENDANT_NUMBER,'#'),0,decode(instr(C_DEPENDANT_NUMBER,'_'),0,C_MEMBER_NUMBER,
                       substr(C_DEPENDANT_NUMBER,1,instr(C_DEPENDANT_NUMBER,'_')-1)),
                       substr(C_DEPENDANT_NUMBER,3,instr(C_DEPENDANT_NUMBER,'_')-3))
          else 
              decode(instr(C_OHI_LINE_ID,'#'),0,decode(instr(C_OHI_LINE_ID,'_'),0,C_MEMBER_NUMBER,
                           substr(C_OHI_LINE_ID,1,instr(C_OHI_LINE_ID,'_')-1)),
                           substr(C_OHI_LINE_ID,3,instr(C_OHI_LINE_ID,'_')-3)) 
         end member_no,            
            CASE WHEN C_OHI_LINE_ID = '1' THEN  
              C_OHI_LINE_ID
            ELSE
              C_DEPENDANT_NUMBER
           END dependant_no,
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
           CASE WHEN C_OHI_LINE_ID = '1' THEN  
               SUBSTR(C_DEPENDANT_NUMBER,INSTR(C_DEPENDANT_NUMBER,'_',1,2)+1
                        ,INSTR(C_DEPENDANT_NUMBER,'_',1,3) - INSTR(C_DEPENDANT_NUMBER,'_',1,2)
                         - 1) 
            ELSE
             SUBSTR(C_OHI_LINE_ID,INSTR(C_OHI_LINE_ID,'_',1,2)+1
                      ,INSTR(C_OHI_LINE_ID,'_',1,3) - INSTR(C_OHI_LINE_ID,'_',1,2)
                       - 1) 
           END as payment_type             
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
       and t.payload is not null
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
         /* decode(instr(C_OHI_LINE_ID,'#'),0,decode(instr(C_OHI_LINE_ID,'_'),0,C_MEMBER_NUMBER,
                       substr(C_OHI_LINE_ID,1,instr(C_OHI_LINE_ID,'_')-1)),
                       substr(C_OHI_LINE_ID,3,instr(C_OHI_LINE_ID,'_')-3)) member_no,*/
           CASE WHEN C_OHI_LINE_ID = '1' THEN  
               decode(instr(C_DEPENDANT_NUMBER,'#'),0,decode(instr(C_DEPENDANT_NUMBER,'_'),0,C_MEMBER_NUMBER,
                       substr(C_DEPENDANT_NUMBER,1,instr(C_DEPENDANT_NUMBER,'_')-1)),
                       substr(C_DEPENDANT_NUMBER,3,instr(C_DEPENDANT_NUMBER,'_')-3))
          else 
              decode(instr(C_OHI_LINE_ID,'#'),0,decode(instr(C_OHI_LINE_ID,'_'),0,C_MEMBER_NUMBER,
                           substr(C_OHI_LINE_ID,1,instr(C_OHI_LINE_ID,'_')-1)),
                           substr(C_OHI_LINE_ID,3,instr(C_OHI_LINE_ID,'_')-3)) 
         end member_no,            
            CASE WHEN C_OHI_LINE_ID = '1' THEN  
              C_OHI_LINE_ID
            ELSE
              C_DEPENDANT_NUMBER
           END dependant_no,
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
           CASE WHEN C_OHI_LINE_ID = '1' THEN  
               SUBSTR(C_DEPENDANT_NUMBER,INSTR(C_DEPENDANT_NUMBER,'_',1,2)+1
                        ,INSTR(C_DEPENDANT_NUMBER,'_',1,3) - INSTR(C_DEPENDANT_NUMBER,'_',1,2)
                         - 1) 
            ELSE
             SUBSTR(C_OHI_LINE_ID,INSTR(C_OHI_LINE_ID,'_',1,2)+1
                      ,INSTR(C_OHI_LINE_ID,'_',1,3) - INSTR(C_OHI_LINE_ID,'_',1,2)
                       - 1) 
           END as payment_type             
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
       and t.payload is not null;
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
