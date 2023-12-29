select 
       ccs.COMPANY_ID_NO
      ,ccs.EXCHANGE_RATE_CURRENCY_CODE
      ,ccs.GROUP_CODE
      ,ccs.POLICY_CODE
      ,ccs.PERSON_CODE
      ,ccs.CONTRIBUTION_DATE
      ,ccs.POEP_ID
      ,ccs.COMMS_CALC_SNAPSHOT_NO
      ,ccs.COMMS_CALC_TYPE_CODE
      ,ccs.INVOICE_NO
      ,ccs.PAYMENT_RECEIVE_AMT || ' ' || ccs.PAYMENT_CURRENCY LOCAL_AMOUNT
      ,ccs.COMMS_CALCULATED_AMT || ' ' || ccs.PAYMENT_CURRENCY LOCAL_AMOUNT
      ,ccs.COMMS_CALCULATED_EXCH_AMT || ' ' || ccs.EXCHANGE_RATE_CURRENCY_CODE PAID_AMOUNT
  from LHHCOM.COMMS_CALC_SNAPSHOT ccs
  left outer
  join LHHCOM.COMMS_PAYMENTS_RECEIVED cpr
    on cpr.COMMS_CALC_SNAPSHOT_NO = ccs.COMMS_CALC_SNAPSHOT_NO
 where cpr.COMMS_CALC_SNAPSHOT_NO is NULL
   and ccs.USERNAME <> 'Medware'
   and ccs.COMMS_CALC_TYPE_CODE <> 'T'
  order by 1, 2, 3, 4;

/

select 
       ccs.EXCHANGE_RATE_CURRENCY_CODE CURRENCY, ccs.COMPANY_ID_NO Company, sum(PAYMENT_RECEIVE_AMT) PAYMENTS, sum(COMMS_CALCULATED_AMT) LOCAL_COMMS, sum(COMMS_CALCULATED_EXCH_AMT) PAID_COMMS
  from LHHCOM.COMMS_CALC_SNAPSHOT ccs
  left outer
  join LHHCOM.COMMS_PAYMENTS_RECEIVED cpr
    on cpr.COMMS_CALC_SNAPSHOT_NO = ccs.COMMS_CALC_SNAPSHOT_NO
 where cpr.COMMS_CALC_SNAPSHOT_NO is NULL
   and ccs.USERNAME <> 'Medware'
   and ccs.COMMS_CALC_TYPE_CODE <> 'T'
  group by ccs.EXCHANGE_RATE_CURRENCY_CODE, ccs.COMPANY_ID_NO
  order by 1, 2, 3, 4;

/

select 
       ccs.EXCHANGE_RATE_CURRENCY_CODE
      ,ccs.COMPANY_ID_NO
      ,ccs.GROUP_CODE
      ,ccs.POLICY_CODE
      ,ccs.PERSON_CODE
      ,ccs.CONTRIBUTION_DATE
      ,ccs.POEP_ID
      ,ccs.COMMS_CALC_TYPE_CODE
      ,ccs.COMMS_CALC_SNAPSHOT_NO
      ,to_char(ccs.PAYMENT_RECEIVE_AMT, '999990D00') || ' '|| ccs.PAYMENT_CURRENCY LOCAL_AMOUNT
      ,to_char(ccs.COMMS_CALCULATED_AMT, '999990D00') || ' '|| ccs.PAYMENT_CURRENCY LOCAL_AMOUNT
      ,to_char(ccs.COMMS_CALCULATED_EXCH_AMT, '999990D00') || ' '|| ccs.EXCHANGE_RATE_CURRENCY_CODE PAID_AMOUNT
      ,ccs.INVOICE_NO
      ,occs.COMMS_CALC_SNAPSHOT_NO
      ,to_char(occs.PAYMENT_RECEIVE_AMT, '999990D00') || ' '|| occs.PAYMENT_CURRENCY LOCAL_AMOUNT
      ,to_char(occs.COMMS_CALCULATED_AMT, '999990D00') || ' '|| occs.PAYMENT_CURRENCY LOCAL_AMOUNT
      ,to_char(occs.COMMS_CALCULATED_EXCH_AMT, '999990D00') || ' '|| occs.EXCHANGE_RATE_CURRENCY_CODE PAID_AMOUNT
      ,occs.INVOICE_NO
  from LHHCOM.COMMS_CALC_SNAPSHOT ccs
  left outer
  join LHHCOM.COMMS_PAYMENTS_RECEIVED cpr
    on cpr.COMMS_CALC_SNAPSHOT_NO = ccs.COMMS_CALC_SNAPSHOT_NO
  left outer
  join LHHCOM.COMMS_CALC_SNAPSHOT occs
    on     occs.COMMS_CALC_SNAPSHOT_NO      <> ccs.COMMS_CALC_SNAPSHOT_NO
       and occs.COMPANY_ID_NO               =  ccs.COMPANY_ID_NO
       and occs.EXCHANGE_RATE_CURRENCY_CODE =  ccs.EXCHANGE_RATE_CURRENCY_CODE
       and occs.GROUP_CODE                  =  ccs.GROUP_CODE
       and occs.POLICY_CODE                 =  ccs.POLICY_CODE
       and occs.PERSON_CODE                 =  ccs.PERSON_CODE
       and occs.CONTRIBUTION_DATE           =  ccs.CONTRIBUTION_DATE
       and occs.POEP_ID                     =  ccs.POEP_ID
       and occs.COMMS_CALC_TYPE_CODE        =  ccs.COMMS_CALC_TYPE_CODE
 where cpr.COMMS_CALC_SNAPSHOT_NO is NULL
   and ccs.USERNAME <> 'Medware'
   and ccs.COMMS_CALC_TYPE_CODE <> 'T'
  order by 1, 2, 3, 4, 5, 6;
