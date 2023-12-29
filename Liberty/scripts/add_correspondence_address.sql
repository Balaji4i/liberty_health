insert into company_address 
select COMPANY_ID_NO       , 
       COUNTRY_CODE        , 
       'C', 
       EFFECTIVE_START_DATE, 
       EFFECTIVE_END_DATE  , 
       ADDRESS_LINE1       , 
       ADDRESS_LINE2       , 
       ADDRESS_LINE3       , 
       ADDRESS_COUNTRY_CODE, 
       POSTAL_CODE         , 
       sysdate, 
       'jzb2412' 
 from (select COMPANY_ID_NO       , 
              COUNTRY_CODE        , 
              ADDRESS_TYPE_CODE   , 
              EFFECTIVE_START_DATE, 
              EFFECTIVE_END_DATE  , 
              ADDRESS_LINE1       , 
              ADDRESS_LINE2       , 
              ADDRESS_LINE3       , 
              ADDRESS_COUNTRY_CODE, 
              POSTAL_CODE,
              rank() over (partition by company_id_no order by  address_Type_code, effective_Start_date desc) rank_no
         from company_Address
        where company_id_no in (select company_id_no
                                  from company
                                 where company_id_no not in (select company_id_no
                                                               from company_address
                                                              where address_type_code in ('c', 'C')))
         and effective_end_date >= trunc(sysdate))
where rank_no = 1;
