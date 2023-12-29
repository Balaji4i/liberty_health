select 
    con.K_COMMON_KEY,
    pro.P_DT_TO,
    pro.P_PRACTICE_NAME,
    con.CO_CELL,
    con.CO_TEL_HOME,
    con.CO_TEL_WORK,
    con.CO_EMAIL,
    aud.AD_DT_STAMP LAST_CHANGED,
    con.CO_CLM_ACCT_TYPE,
    con.CO_CLM_ACCT_BR,
    con.CO_CLM_ACCT,
    deb.DBT_BALANCE,
    deb.NO_OF_PMNTS
from VMEDLIVE.PROVIDER pro
join VMEDLIVE.CONTACTS con
    on (trim(substr(con.K_COMMON_KEY, 1, 18)) = trim ('PR' || pro.P_PROVIDER))
join VMEDLIVE.ACBBRN brn
    on (trim(con.CO_CLM_ACCT_BR) = trim(brn.AB_BR_CODE) and brn.AB_BANK = 1)
left outer
join (  select  
                aud.A_COMMON_KEY,
                aud.AD_DT_STAMP,
                aud.A_NEW,
                ROW_NUMBER() over (partition by aud.A_COMMON_KEY, aud.A_NEW order by aud.AD_DT_STAMP desc) rn
            from VMEDLIVE.AUDITA aud
            where substr(aud.A_COMMON_KEY, 1, 6) = 'PROVID' and trim(aud.A_FIELD) = 'CO_CLM_ACCT') aud
    on (    aud.rn = 1 and
                trim(substr(aud.A_COMMON_KEY, 1, 18)) = trim('PROVID' || pro.P_PROVIDER) and
                trim(aud.A_NEW) = trim(CO_CLM_ACCT))
left outer
join (  select  
                deb.DB_COMMON_KEY,
                sum(deb.DB_AMOUNT)  DBT_BALANCE,
                sum(case when substr(deb.DB_TRAN_TY, 1, 3) = 'ACB' then 1 else 0 end)  NO_OF_PMNTS
            from VMEDLIVE.DEBTOR deb
            where substr(deb.DB_COMMON_KEY, 1, 2) = 'PR'
            group by deb.DB_COMMON_KEY) deb
    on (trim(substr(deb.DB_COMMON_KEY, 1, 14)) = trim('PR' || pro.P_PROVIDER))
where (pro.P_DT_TO > 20190601 or pro.P_DT_TO = 0);

select * from VMEDLIVE.DEBTOR where DB_COMMON_KEY like 'PR6619622%';

select * from VMEDLIVE.AUDITA aud
where substr(aud.A_COMMON_KEY, 1, 6) = 'PROVID' and trim(aud.A_FIELD) = 'CO_CLM_ACCT';