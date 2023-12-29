select K_COMMON_KEY, CO_CLM_ACCT, CO_CLM_ACCT_BR, CO_CLM_ACCT_TYPE, AB_CLM_SWIFT_CODE, AB_CLM_IBAN_NO
from LHAFLIVE.CONTACTS
WHERE K_COMMON_KEY like 'PR%';
select * from LHAFLIVE.ACBBRN where AB_BANK_CODE like '28006%';
select * from LHAFLIVE.ACBBANK where AB_COUNTRY like 'L%';

select
  branch.ab_br_code
 ,bank.ab_country
 ,bank.ab_bank
 ,bank.ab_bank_name
 ,branch.ab_branch_name
 ,branch.ab_add_l1
 ,branch.ab_add_l2
 ,branch.ab_dialling_code
 ,branch.ab_phone
from LHAFLIVE.ACBBANK              bank
left outer
join LHAFLIVE.ACBBRN               branch
  on bank.ab_bank = branch.ab_bank
  where AB_COUNTRY like 'L%';