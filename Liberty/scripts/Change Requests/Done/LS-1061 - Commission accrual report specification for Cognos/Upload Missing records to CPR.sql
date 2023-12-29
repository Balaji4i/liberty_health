INSERT INTO lhhcom.comms_payments_received
  (application_id,
   group_code,
   country_code,
   product_code,
   policy_code,
   person_code,
   contribution_date,
   finance_receipt_no, 
   finance_receipt_date,
   finance_invoice_no,
   finance_invoice_date,
   finance_receipt_amt,
   currency_code,
   exchange_rate,
   comms_calc_snapshot_no,
   processed_ind, 
   processed_desc, 
   last_update_datetime,
   username)
SELECT 
  ls1061b.application_id,
  ls1061b.group_code,
  ls1061b.country_code,
  ls1061b.product_code,
  ls1061b.policy_code,
  ls1061b.person_code,
  ls1061b.contribution_date,
  ls1061b.finance_receipt_no,
  ls1061b.finance_receipt_date,
  ls1061b.finance_invoice_no,
  ls1061b.finance_invoice_date,
  ls1061b.finance_receipt_amt,
  NULL,
  NULL,
  NULL,
  ls1061b.processed_ind,
  ls1061b.processed_desc,
  ls1061b.last_update_datetime,
  ls1061b.username
FROM
  (SELECT * FROM 
    (SELECT 
      application_id,
      group_code,
      product_code,
      country_code,
      policy_code,
      person_code,
      contribution_date,
      finance_receipt_no,
      finance_receipt_date  
    FROM lhhcom.temp_backup_ls1061b)

    MINUS
  
    (SELECT 
      application_id,
      group_code,
      product_code,
      country_code,
      policy_code,
      person_code,
      contribution_date,
      finance_receipt_no,
      finance_receipt_date
    FROM lhhcom.comms_payments_received)) not_loaded
      INNER JOIN lhhcom.temp_backup_ls1061b ls1061b
        ON not_loaded.application_id = ls1061b.application_id AND 
           not_loaded.group_code = ls1061b.group_code AND 
           not_loaded.product_code = ls1061b.product_code AND
           not_loaded.country_code = ls1061b.country_code AND
           not_loaded.policy_code = ls1061b.policy_code AND
           not_loaded.person_code = ls1061b.person_code AND
           not_loaded.contribution_date = ls1061b.contribution_date AND
           not_loaded.finance_receipt_no = ls1061b.finance_receipt_no AND
           not_loaded.finance_receipt_date = ls1061b.finance_receipt_date;  

/
select 
       GROUP_CODE
      ,PROCESSED_IND
      ,sum(FINANCE_RECEIPT_AMT)
      ,count(*)
from lhhcom.comms_payments_received
group by
       GROUP_CODE
      ,PROCESSED_IND
order by 1, 2
;
select 
       GROUP_CODE
      ,PROCESSED_IND
      ,sum(FINANCE_RECEIPT_AMT)
      ,count(*)
from lhhcom.temp_backup_ls1061b
group by
       GROUP_CODE
      ,PROCESSED_IND
order by 1, 2
;
select count (*) from lhhcom.temp_backup_ls1061b;
/
select * from lhhcom.comms_payments_received where trunc(sysdate) = trunc(last_update_datetime);


/

select 
       GROUP_CODE
      ,PROCESSED_IND
      ,CONTRIBUTION_DATE
      ,sum(FINANCE_RECEIPT_AMT)
      ,count(*)
from lhhcom.comms_payments_received
group by
       GROUP_CODE
      ,PROCESSED_IND
      ,CONTRIBUTION_DATE
order by 1, 2
;
select 
       GROUP_CODE
      ,PROCESSED_IND
      ,CONTRIBUTION_DATE
      ,sum(FINANCE_RECEIPT_AMT)
      ,count(*)
from lhhcom.temp_backup_ls1061b
group by
       GROUP_CODE
      ,PROCESSED_IND
      ,CONTRIBUTION_DATE
order by 1, 2
;
