SET SERVEROUTPUT ON;
define p_db_link = MEDWARE_PROD.LIBERTY.CO.ZA;

SELECT AG_CODE, COMPANY_ID_NO, AG_NAME from (
  select trim(AG_CODE) AG_CODE,
    check_if_number(trim(AG_CODE)) COMPANY_NO,
    trim(AG_PARENT_CODE) AG_PARENT_CODE,
    trim(AG_NAME) AG_NAME,
    case
      when trim(AG_TYPE) is null then 'Y'   ---company_table = 4
      when trim(AG_TYPE) = 'AGCY' then 'Y' ---company_table = 4
      when trim(AG_TYPE) = 'AGEN' then 'N'  --broker_Table = 1
      when trim(AG_TYPE) = 'AGNT' and trim(AG_PARENT_CODE) is not null then 'N' --broker_Table = 1 
      when trim(AG_TYPE) = 'AGNT' and trim(AG_PARENT_CODE) is null then 'Y' ---company_table = 4
      when trim(AG_TYPE) = 'BROK' then 'Y'   ---company_table = 4
      when trim(AG_TYPE) = 'CONS' then 'N' --broker_Table = 1 
      when trim(AG_TYPE) = 'DRCT' then 'Y' ---company_table = 4
      when trim(AG_TYPE) = 'HSE' then 'Y' ---company_table = 4
    end IS_COMPANY_RECORD,
    trim(AG_COMPANY_CODE) AG_COMPANY_CODE,
    trim(AG_CONSULTANT) AG_CONSULTANT, --KAM BROKER
    case 
      when length(trim(AG_DT_FROM)) = 8 then to_date(trim(AG_DT_FROM),'yyyymmdd')
     else
       to_date('20000101','yyyymmdd')
    end effective_start_date,
    case 
      when length(trim(AG_DT_TO)) = 8 then to_date(trim(AG_DT_TO),'yyyymmdd')
     else
       to_date('31000131','yyyymmdd')
    end effective_end_date,
    nvl(trim(AG_LANGUAGE),'E') AG_LANGUAGE,
    case
      when trim(AG_STATUS)  = 'ACTIVE' then 25
      when trim(AG_STATUS) = 'RESIGN' then 27
      when trim(AG_STATUS) = 'PREREG' then 24
     end AG_STATUS,     -- company table type, company_table id no = 2
    nvl(trim(AG_TITLE),'MR') AG_TITLE,
    trim(AG_INITLS) AG_INITLS,
    nvl(trim(AG_FIRST_NAME),trim(ag_name)) AG_FIRST_NAME,
    trim(AG_SURNAME) AG_SURNAME,
    decode(trim(AG_MULTINAT),null,'N','Y') AG_MULTINAT,
    trim(substr(trim(AG_NAME),instr(trim(AG_NAME),' ')+1, length(trim(AG_NAME)))) last_name
  from agent@&&p_db_link
  where trim(ag_dt_to) = 0
    and trim(ag_code) in (select trim(ag_code)
                      from agschem@&&p_db_link
                     where s_scheme not in ('BMIR','IMED','ESMA','HERI','CFC')
                       and substr(s_scheme,0,1) not in ('A','O','U'))    
  order by is_company_record, ag_parent_code desc, 1
  ) AGNT
  left outer join company comp
    on agnt.company_no = comp.company_id_no
 where IS_COMPANY_RECORD = 'Y'
 order by AG_CODE;

/

SELECT COMPANY_ID_NO, AG_CODE, COMPANY_NAME from 
  company comp
left outer join (
  select trim(AG_CODE) AG_CODE,
    check_if_number(trim(AG_CODE)) COMPANY_NO,
    trim(AG_PARENT_CODE) AG_PARENT_CODE,
    trim(AG_NAME) AG_NAME,
    case
      when trim(AG_TYPE) is null then 'Y'   ---company_table = 4
      when trim(AG_TYPE) = 'AGCY' then 'Y' ---company_table = 4
      when trim(AG_TYPE) = 'AGEN' then 'N'  --broker_Table = 1
      when trim(AG_TYPE) = 'AGNT' and trim(AG_PARENT_CODE) is not null then 'N' --broker_Table = 1 
      when trim(AG_TYPE) = 'AGNT' and trim(AG_PARENT_CODE) is null then 'Y' ---company_table = 4
      when trim(AG_TYPE) = 'BROK' then 'Y'   ---company_table = 4
      when trim(AG_TYPE) = 'CONS' then 'N' --broker_Table = 1 
      when trim(AG_TYPE) = 'DRCT' then 'Y' ---company_table = 4
      when trim(AG_TYPE) = 'HSE' then 'Y' ---company_table = 4
    end IS_COMPANY_RECORD,
    trim(AG_COMPANY_CODE) AG_COMPANY_CODE,
    trim(AG_CONSULTANT) AG_CONSULTANT, --KAM BROKER
    case 
      when length(trim(AG_DT_FROM)) = 8 then to_date(trim(AG_DT_FROM),'yyyymmdd')
     else
       to_date('20000101','yyyymmdd')
    end effective_start_date,
    case 
      when length(trim(AG_DT_TO)) = 8 then to_date(trim(AG_DT_TO),'yyyymmdd')
     else
       to_date('31000131','yyyymmdd')
    end effective_end_date,
    nvl(trim(AG_LANGUAGE),'E') AG_LANGUAGE,
    case
      when trim(AG_STATUS)  = 'ACTIVE' then 25
      when trim(AG_STATUS) = 'RESIGN' then 27
      when trim(AG_STATUS) = 'PREREG' then 24
     end AG_STATUS,     -- company table type, company_table id no = 2
    nvl(trim(AG_TITLE),'MR') AG_TITLE,
    trim(AG_INITLS) AG_INITLS,
    nvl(trim(AG_FIRST_NAME),trim(ag_name)) AG_FIRST_NAME,
    trim(AG_SURNAME) AG_SURNAME,
    decode(trim(AG_MULTINAT),null,'N','Y') AG_MULTINAT,
    trim(substr(trim(AG_NAME),instr(trim(AG_NAME),' ')+1, length(trim(AG_NAME)))) last_name
  from agent@&&p_db_link
  where trim(ag_dt_to) = 0
    and trim(ag_code) in (select trim(ag_code)
                      from agschem@&&p_db_link
                     where s_scheme not in ('BMIR','IMED','ESMA','HERI','CFC')
                       and substr(s_scheme,0,1) not in ('A','O','U'))    
  order by is_company_record, ag_parent_code desc, 1
  ) AGNT
    on agnt.company_no = comp.company_id_no
 order by COMPANY_ID_NO;
