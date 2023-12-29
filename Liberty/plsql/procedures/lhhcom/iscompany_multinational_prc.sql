create or replace PROCEDURE        lhhcom.iscompany_multinational(p_companyId_No IN NUMBER, p_result OUT VARCHAR2)  IS
  
  l_exists VARCHAR2(1);

BEGIN

   SELECT DISTINCT 'X'
    INTO l_exists
    FROM company_country cc,
         company_function cf,
         company_table_type ctt,
         company_table ct
    WHERE 1=1
      AND nvl(company_table_type_desc,'N') = 'Y'
      AND ct.company_table_desc = 'Multinational'
      AND cf.company_table_type_id_no = ctt.company_Table_type_id_no
      AND ctt.company_table_id_no = ct.company_table_id_no
      AND ctt.company_table_id_no = cf.company_table_id_no
      AND cc.company_id_no  = cf.company_id_no
      AND cc.company_id_no = p_companyId_No
      AND trunc(sysdate) between trunc(NVL(cf.effective_start_date,TO_DATE('01-JAN-1900'))) and trunc(NVL(cf.effective_end_date,TO_DATE('31-DEC-4712')))
      AND trunc(sysdate) between trunc(NVL(cc.effective_start_date,TO_DATE('01-JAN-1900'))) and trunc(NVL(cc.effective_end_date,TO_DATE('31-DEC-4712')))
      AND trunc(sysdate) between trunc(NVL(ct.effective_start_date,TO_DATE('01-JAN-1900'))) and trunc(NVL(ct.effective_end_date,TO_DATE('31-DEC-4712')))
      AND trunc(sysdate) between trunc(NVL(ctt.effective_start_date,TO_DATE('01-JAN-1900'))) and trunc(NVL(ctt.effective_end_date,TO_DATE('31-DEC-4712')));

      p_result := 'Y';

EXCEPTION 
  WHEN NO_DATA_FOUND THEN
      p_result := 'N';
  WHEN OTHERS THEN
     p_result := 'N';
END;