CREATE or REPLACE FUNCTION get_comp_template
                           (p_company        IN  NUMBER   DEFAULT NULL
                           ,p_date           IN  DATE     DEFAULT SYSDATE)
                           RETURN                company_table_type.company_table_type_desc%type

IS

  v_template       company_table_type.company_table_type_desc%type;
  v_return_msg     VARCHAR2(200);
  
BEGIN
  commissions_pkg.get_comp_template (p_company => p_company
                                    ,p_date => p_date
                                    ,p_template => v_template
                                    ,p_return_msg => v_return_msg);
  RETURN v_template;
END get_comp_template;