insert into company_contact
select COMPANY_ID_NO              ,
       COUNTRY_CODE               ,
       3 ,
       EFFECTIVE_START_DATE       ,
       EFFECTIVE_END_DATE         ,
       CONTACT_NAME               ,
       CONTACT_CELLPHONE_NO       ,
       CONTACT_EMAIL              ,
       CONTACT_FAX_NO             ,
       CONTACT_TELEPHONE_NO       ,
       CONTACT_DESC             ,
       sysdate, 
       'jzb2412' 
 from (select COMPANY_ID_NO              ,
              COUNTRY_CODE               ,
              COMPANY_CONTACT_TYPE_ID_NO ,
              EFFECTIVE_START_DATE       ,
              EFFECTIVE_END_DATE         ,
              CONTACT_NAME               ,
              CONTACT_CELLPHONE_NO       ,
              CONTACT_EMAIL              ,
              CONTACT_FAX_NO             ,
              CONTACT_TELEPHONE_NO       ,
              CONTACT_DESC               ,
              rank() over (partition by company_id_no order by  company_contact_type_id_no, effective_Start_date desc) rank_no
         from company_contact
        where company_id_no in (select company_id_no
                                  from company
                                 where company_id_no not in (select company_id_no
                                                               from company_contact
                                                              where company_contact_type_id_no = 3))
         and effective_end_date >= trunc(sysdate))
where rank_no = 1;
