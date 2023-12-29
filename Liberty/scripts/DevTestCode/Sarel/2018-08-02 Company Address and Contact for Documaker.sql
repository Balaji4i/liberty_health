-- All three
SELECT
       comp.company_id_no
--      ,NVL(ctab.company_table_id_no, 000000000)      company_table
      ,NVL(to_char(cfun.company_table_type_id_no), '    * *') company_function
      ,NVL(ctyp.company_table_type_desc,           '    * *')  company_table_type
      ,NVL(cadr.address_line1,                     '    * *')  address_line1
      ,NVL(cadr.address_line2,                     '    * *')  address_line2
      ,NVL(cadr.address_line3,                     '    * *')  address_line3
      ,NVL(cadr.address_country_code,              '    * *')  template_country_code
      ,NVL(ccon1.contact_name,                     '    * *')  primary_contact_name
      ,NVL(ccon1.contact_email ,                   '    * *')  primary_contact_email
      ,NVL(ccon2.contact_name,                     '    * *')  secondary_contact_name
      ,NVL(ccon2.contact_email,                    '    * *')  secondary_contact_email
      ,NVL(ccon3.contact_name,                     '    * *')  multinat_contact_name
      ,NVL(ccon3.contact_email,                    '    * *')  multinat_contact_email
  FROM company               comp
  LEFT OUTER
  JOIN company_table         ctab
    ON     ctab.company_table_desc = 'Correspondence Address Country'
       AND SYSDATE BETWEEN ctab.effective_start_date and ctab.effective_end_date
  LEFT OUTER
  JOIN company_function      cfun
    ON     cfun.company_id_no            = comp.company_id_no
       AND cfun.company_table_id_no      = ctab.company_table_id_no
       AND SYSDATE BETWEEN cfun.effective_start_date and cfun.effective_end_date
  LEFT OUTER
  JOIN company_table_type    ctyp
    ON     ctyp.company_table_id_no = ctab.company_table_id_no
       AND ctyp.company_table_type_id_no = cfun.company_table_type_id_no
       AND SYSDATE BETWEEN ctyp.effective_start_date and ctyp.effective_end_date
  LEFT OUTER
  JOIN company_address       cadr
    ON     cadr.company_id_no      = comp.company_id_no
       AND cadr.country_code       = ctyp.company_table_type_desc
       AND cadr.address_type_code  = 'C'
       AND SYSDATE BETWEEN cadr.effective_start_date and cadr.effective_end_date
  LEFT OUTER
  JOIN company_contact       ccon1
    ON     ccon1.company_id_no      = comp.company_id_no
       AND ccon1.country_code       = ctyp.company_table_type_desc
       AND ccon1.company_contact_type_id_no  = 1
       AND SYSDATE BETWEEN ccon1.effective_start_date and ccon1.effective_end_date
  LEFT OUTER
  JOIN company_contact       ccon2
    ON     ccon2.company_id_no      = comp.company_id_no
       AND ccon2.country_code       = ctyp.company_table_type_desc
       AND ccon2.company_contact_type_id_no  = 2
       AND SYSDATE BETWEEN ccon2.effective_start_date and ccon2.effective_end_date
  LEFT OUTER
  JOIN company_contact       ccon3
    ON     ccon3.company_id_no      = comp.company_id_no
       AND ccon3.country_code       = ctyp.company_table_type_desc
       AND ccon3.company_contact_type_id_no  = 3
       AND SYSDATE BETWEEN ccon3.effective_start_date and ccon3.effective_end_date
;
/
-- Old Template (No longer used) Use function get_comp_template instead
SELECT
       comp.company_id_no
      ,NVL(cadr.address_country_code,              '    * *')  template
  FROM company               comp
  LEFT OUTER
  JOIN company_table         ctab
    ON     ctab.company_table_desc = 'Correspondence Address Country'
       AND SYSDATE BETWEEN ctab.effective_start_date and ctab.effective_end_date
  LEFT OUTER
  JOIN company_function      cfun
    ON     cfun.company_id_no            = comp.company_id_no
       AND cfun.company_table_id_no      = ctab.company_table_id_no
       AND SYSDATE BETWEEN cfun.effective_start_date and cfun.effective_end_date
  LEFT OUTER
  JOIN company_table_type    ctyp
    ON     ctyp.company_table_id_no = ctab.company_table_id_no
       AND ctyp.company_table_type_id_no = cfun.company_table_type_id_no
       AND SYSDATE BETWEEN ctyp.effective_start_date and ctyp.effective_end_date
  LEFT OUTER
  JOIN company_address       cadr
    ON     cadr.company_id_no      = comp.company_id_no
       AND cadr.country_code       = ctyp.company_table_type_desc
       AND cadr.address_type_code  = 'C'
       AND SYSDATE BETWEEN cadr.effective_start_date and cadr.effective_end_date
;
/ Correspondence Address - Make this into a Procedure
SELECT
       comp.company_id_no
      ,NVL(cadr.address_line1,           ' ')  address_line1
      ,NVL(cadr.address_line2,           ' ')  address_line2
      ,NVL(cadr.address_line3,           ' ')  address_line3
      ,NVL(cadr.address_country_code,    ' ')  country_code
      ,NVL(cadr.postal_code,             ' ')  postal_code
  FROM company               comp
  LEFT OUTER
  JOIN company_address       cadr
    ON     cadr.company_id_no      = comp.company_id_no
       AND cadr.address_type_code  = 'C'
       AND SYSDATE BETWEEN cadr.effective_start_date and cadr.effective_end_date
;

/ Correspondence Contact - Make this into a Procedure
SELECT
       comp.company_id_no
      ,NVL(ccon.contact_name,            ' ')  contact_name
      ,NVL(ccon.contact_cellphone_no,    ' ')  contact_cellphone
      ,NVL(ccon.contact_email,           ' ')  contact_email
      ,NVL(ccon.contact_fax_no,          ' ')  contact_fax
      ,NVL(ccon.contact_telephone_no,    ' ')  contact_tel
  FROM company               comp
  LEFT OUTER
  JOIN company_contact       ccon
    ON     ccon.company_id_no      = comp.company_id_no
       AND ccon.company_contact_type_id_no  = 3
       AND SYSDATE BETWEEN ccon.effective_start_date and ccon.effective_end_date
;

select * from company_contact cc join company_contact_type cct on cc.company_contact_type_id_no  = cct.company_contact_type_id_no;
/
SELECT
       comp.company_id_no
      ,NVL(ccon.contact_name,                     '    * *')  contact_name
      ,NVL(ccon.contact_cellphone_no,             '    * *')  contact_cellphone
      ,NVL(ccon.contact_email,                    '    * *')  contact_email
  FROM company               comp
  LEFT OUTER
  JOIN company_table         ctab
    ON     ctab.company_table_desc = 'Correspondence Address Country'
       AND SYSDATE BETWEEN ctab.effective_start_date and ctab.effective_end_date
  LEFT OUTER
  JOIN company_function      cfun
    ON     cfun.company_id_no            = comp.company_id_no
       AND cfun.company_table_id_no      = ctab.company_table_id_no
       AND SYSDATE BETWEEN cfun.effective_start_date and cfun.effective_end_date
  LEFT OUTER
  JOIN company_table_type    ctyp
    ON     ctyp.company_table_id_no = ctab.company_table_id_no
       AND ctyp.company_table_type_id_no = cfun.company_table_type_id_no
       AND SYSDATE BETWEEN ctyp.effective_start_date and ctyp.effective_end_date
  LEFT OUTER
  JOIN company_contact_type  cctp
    ON     cctp.company_contact_type_desc = 'Correspondence Contact'
       AND SYSDATE BETWEEN cctp.effective_start_date and cctp.effective_end_date
  LEFT OUTER
  JOIN company_contact       ccon
    ON     ccon.company_id_no      = comp.company_id_no
       AND ccon.country_code       = ctyp.company_table_type_desc
       AND ccon.company_contact_type_id_no  = cctp.company_contact_type_id_no
       AND SYSDATE BETWEEN ccon.effective_start_date and ccon.effective_end_date
;
