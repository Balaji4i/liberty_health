select to_Char(transaction_datetime , 'dd-Mon-yyyy hh:mi:ssAM') from OHI_COMM_PERC_audit;
select transaction_datetime, to_Char(transaction_datetime , 'yyyy-Mon-dd hh24:mi:ss') from OHI_COMM_PERC_audit;
select
  to_char(last_update_datetime,'RRRR') YEAR, 
  to_char(last_update_datetime,'MM') MONTH, 
  to_char(last_update_datetime,'DD') DAY, 
  to_char(last_update_datetime,'HH24:MI:SS') TIME,
  count(last_update_datetime) Records 
from 
  ohi_policy_brokers 
group by 
  to_char(last_update_datetime,'RRRR'), 
  to_char(last_update_datetime,'MM'), 
  to_char(last_update_datetime,'DD'), 
  to_char(last_update_datetime,'HH24:MI:SS') 
 ORDER BY 1, 2, 3, 4; 
 select to_Char(finance_receipt_amt, '9G999D9999', 'NLS_NUMERIC_CHARACTERS = ''. '' NLS_CURRENCY = ''R '' ') Amount from COMMS_PAYMENTS_RECEIVED;
