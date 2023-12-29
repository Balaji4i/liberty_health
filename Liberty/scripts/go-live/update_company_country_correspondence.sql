begin
-- first insert all possible entries into the company_table_type table
FOR c_rec IN (
    SELECT DISTINCT fc.CODE
      FROM fcod_country@policies fc
    WHERE NOT EXISTS (SELECT 'x' FROM company_table_type WHERE company_table_type_desc = fc.code)
    ORDER BY 1 ASC) LOOP
 BEGIN
     INSERT INTO company_table_type VALUES (7,ACCREDITATION_TYPE_SEQ_NO.nextval,c_rec.code,
                                           trunc(sysdate),TO_DATE('31-JAN-3100'),trunc(sysdate),'TPZ0605');
       dbms_output.put_line('info inserted for '||c_rec.code);                                    
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Unexpected error for  '||c_rec.code|| 'error is '||sqlerrm);
  END;  
end loop;

-- second set the company default country correspondence template
-- if a multinational default to ZA otherwise to the country they are operating in as a local broker
 FOR c_temp IN 
 (     SELECT DISTINCT info.company_id_no, info.country_template, ctt.company_table_type_id_no, ctt.company_table_type_desc
         FROM (
                SELECT DISTINCT co.company_id_no, co.company_name,cc.country_code, 
                   (CASE WHEN multi.company_table_type_desc = 'Y' THEN
                       'ZA'
                    WHEN  multi.company_table_type_desc = 'N' AND
                       COUNT(1) OVER (PARTITION BY co.company_id_no) > 1 THEN
                         'Local but more than one country'
                    ELSE
                      cc.country_code
                    END) country_template
                FROM company co, company_country cc, 
                (SELECT DISTINCT cf.company_id_no, cf.effective_start_date, cf.effective_end_date,
                        ct.company_table_desc,
                        ctt.company_table_type_desc
                   FROM company_function cf,
                        company_table_type ctt,
                        company_table ct
                WHERE 1=1
                  AND ct.company_table_desc = 'Multinational'
                  AND cf.company_table_type_id_no = ctt.company_Table_type_id_no
                  AND ctt.company_table_id_no = ct.company_table_id_no
                  AND ctt.company_table_id_no = cf.company_table_id_no
                --  and cc.company_id_no  = cf.company_id_no
                  AND TRUNC(sysdate) BETWEEN TRUNC(cf.effective_start_date) AND TRUNC(cf.effective_end_date)
                 -- and trunc(sysdate) between trunc(cc.effective_start_date) and trunc(cc.effective_end_date)
                  AND TRUNC(sysdate) BETWEEN TRUNC(ct.effective_start_date) AND TRUNC(ct.effective_end_date)
                  AND TRUNC(sysdate) BETWEEN TRUNC(ctt.effective_start_date) AND TRUNC(ctt.effective_end_date)
                  ) multi
                WHERE cc.company_id_no = co.company_id_no
                  AND multi.company_id_no = co.company_id_no
                  AND TRUNC(sysdate) BETWEEN TRUNC(cc.effective_start_date) and trunc(cc.effective_end_date)
          ) info,
          company_table_type ctt
      WHERE info.country_template  = ctt.company_table_type_desc
        AND ctt.company_table_id_no = 7
        AND NOT EXISTS (SELECT 'x' 
                          FROM company_function cf
                         WHERE cf.company_id_no =  info.company_id_no 
                         --  AND cf.company_table_type_id_no = ctt.company_table_type_id_no
                           AND cf.company_table_id_no = 7
                           AND TRUNC(sysdate) BETWEEN  TRUNC(cf.effective_start_date) and trunc(cf.effective_end_date)
                         )
    ) LOOP
    BEGIN   
       INSERT INTO company_function VALUES
       (c_temp.company_id_no,7,TRUNC(SYSDATE),TO_DATe('31-JAN-3100'),c_temp.company_table_type_id_no,TRUNC(SYSDATE),'TZP0605');
        dbms_output.put_line('Info Inserted for comp ,'||c_temp.company_id_no||', company table id 7,'||' table type id number ,'||c_temp.company_table_type_id_no);
       
    EXCEPTION 
        WHEN OTHERS THEN
          dbms_output.put_line('UNEXPECTED ERROR '||SQLERRM||' FOR company '||c_temp.company_id_no||' table type id no'||c_temp.company_table_type_id_no);
     end;   
        
  END LOOP;
END;
