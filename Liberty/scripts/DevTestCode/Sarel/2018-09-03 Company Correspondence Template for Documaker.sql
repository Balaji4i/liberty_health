SELECT
       company_id_no                    company
      ,lhhcom.get_comp_template(company_id_no) template
  FROM lhhcom.company
 WHERE company_id_no = 832000015;

SELECT
       comp.company_id_no          company
      ,ctt.company_table_type_desc template
  FROM company comp
  JOIN company_table ct
    ON ct.company_table_desc = 'Corr Template'
   AND SYSDATE BETWEEN ct.effective_start_date AND ct.effective_end_date
--  LEFT OUTER
  JOIN company_function cf
    ON cf.company_table_id_no = ct.company_table_id_no
   AND cf.company_id_no = comp.company_id_no
   AND SYSDATE BETWEEN cf.effective_start_date AND cf.effective_end_date
--  LEFT OUTER
  JOIN COMPANY_TABLE_TYPE ctt
    ON ctt.company_table_id_no = ct.company_table_id_no
   AND ctt.company_table_type_id_no = cf.company_table_type_id_no
   AND SYSDATE BETWEEN ctt.effective_start_date AND ctt.effective_end_date
 order by 1;

select distinct to_char(effective_start_date, 'YYYY-MM-DD HH:MI:SS') s_date, to_char(effective_end_date, 'YYYY-MM-DD HH:MI:SS') e_date from COMPANY_TABLE;
select distinct to_char(effective_start_date, 'YYYY-MM-DD HH:MI:SS') s_date, to_char(effective_end_date, 'YYYY-MM-DD HH:MI:SS') e_date from COMPANY_TABLE_TYPE;
select distinct to_char(effective_start_date, 'YYYY-MM-DD HH:MI:SS') s_date, to_char(effective_end_date, 'YYYY-MM-DD HH:MI:SS') e_date from COMPANY_FUNCTION;

select * from COMPANY_TABLE ct
  LEFT OUTER
  JOIN COMPANY_TABLE_TYPE ctt
    ON ct.company_table_id_no = ctt.company_table_id_no
 where ct.company_table_id_no = 7
 order by 1 desc, 8;

UPDATE COMPANY_TABLE 
   set company_table_desc = 'Corr Template'
 where company_table_id_no = 7;

UPDATE COMPANY_FUNCTION
   set company_table_type_id_no = 1
 where company_table_id_no = 7
   and company_table_type_id_no > 3;

SET DEFINE OFF;

DELETE from COMPANY_TABLE_TYPE 
 where company_table_id_no = 7
   and company_table_type_id_no > 3;
Insert into COMPANY_TABLE_TYPE (COMPANY_TABLE_ID_NO,COMPANY_TABLE_TYPE_ID_NO,COMPANY_TABLE_TYPE_DESC,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values (7,1,'ZA',to_date('01/JAN/18','DD/MON/RR'),to_date('31/JAN/00','DD/MON/RR'),to_date('31/MAY/18','DD/MON/RR'),'LHHCOM');
Insert into COMPANY_TABLE_TYPE (COMPANY_TABLE_ID_NO,COMPANY_TABLE_TYPE_ID_NO,COMPANY_TABLE_TYPE_DESC,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values (7,2,'LS',to_date('01/JAN/18','DD/MON/RR'),to_date('31/JAN/00','DD/MON/RR'),to_date('31/MAY/18','DD/MON/RR'),'LHHCOM');
Insert into COMPANY_TABLE_TYPE (COMPANY_TABLE_ID_NO,COMPANY_TABLE_TYPE_ID_NO,COMPANY_TABLE_TYPE_DESC,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values (7,3,'UG',to_date('01/JAN/18','DD/MON/RR'),to_date('31/JAN/00','DD/MON/RR'),to_date('31/MAY/18','DD/MON/RR'),'LHHCOM');

GRANT EXECUTE ON lhhcom.get_comp_template TO LHHCORR;