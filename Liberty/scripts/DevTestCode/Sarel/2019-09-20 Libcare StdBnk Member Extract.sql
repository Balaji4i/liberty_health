select 
    con.K_COMMON_KEY,
    mem.M_DT_RESIGNED,
    ben.B_TITLE,
    ben.B_FIRSTNAME,
    ben.B_SURNAME,
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
from VMEDLIVE.MEMBER mem
join VMEDLIVE.BENEF ben
    on (trim(ben.M_MEMBER) = trim (mem.M_MEMBER) and trim(ben.B_DEPEND) = trim(mem.B_DEPEND))
join VMEDLIVE.CONTACTS con
    on (trim(con.K_COMMON_KEY) = trim ('ME' || mem.M_MEMBER))
join VMEDLIVE.ACBBRN brn
    on (trim(con.CO_CLM_ACCT_BR) = trim(brn.AB_BR_CODE) and brn.AB_BANK = 1)
left outer
join (  select  
                aud.A_COMMON_KEY,
                aud.AD_DT_STAMP,
                aud.A_NEW,
                ROW_NUMBER() over (partition by aud.A_COMMON_KEY, aud.A_NEW order by aud.AD_DT_STAMP desc) rn
            from VMEDLIVE.AUDITA aud
            where substr(aud.A_COMMON_KEY, 1, 6) = 'MEMBER' and trim(aud.A_FIELD) = 'CO_CLM_ACCT' ) aud
    on (    aud.rn = 1 and
                trim(aud.A_COMMON_KEY) = trim('MEMBER' || mem.M_MEMBER) and
                trim(aud.A_NEW) = trim(CO_CLM_ACCT))
left outer
join (  select  
                deb.DB_COMMON_KEY,
                sum(deb.DB_AMOUNT)  DBT_BALANCE,
                sum(case when deb.DB_TRAN_TY = 'ACB ' then 1 else 0 end)  NO_OF_PMNTS
            from VMEDLIVE.DEBTOR deb
            where substr(deb.DB_COMMON_KEY, 1, 2) = 'ME'
            group by deb.DB_COMMON_KEY) deb
    on (trim(deb.DB_COMMON_KEY) = trim('ME' || mem.M_MEMBER))
where (mem.M_DT_RESIGNED > 20190601 or mem.M_DT_RESIGNED = 0);

select * from VMEDLIVE.DEBTOR where DB_COMMON_KEY like 'PR6619622%';
/
select  
                deb.DB_COMMON_KEY,
                sum(deb.DB_AMOUNT)  DBT_BALANCE,
                sum(case when deb.DB_TRAN_TY = 'ACB ' then 1 else 0 end)  NO_OF_PMNTS
            from VMEDLIVE.DEBTOR deb
            group by deb.DB_COMMON_KEY;