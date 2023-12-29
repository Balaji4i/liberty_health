DECLARE
  l_poep_id     ohi_enrollment_products.poep_id%TYPE;
  l_return_msg  VARCHAR2(500);

  CURSOR c_comms_detail IS 
    SELECT ROWNUM
          ,country_code
          ,product_code
          ,poep_id
          ,person_code
          ,policy_code
          ,contribution_date
      FROM comms_calc_snapshot
     WHERE comms_calc_type_code IN ('P', 'R', 'A')
       AND country_code = 'LS';

BEGIN
  FOR x IN c_comms_detail LOOP
    IF x.policy_code = 0 THEN
      commissions_pkg.get_poep_id(p_date       => x.contribution_date
                                 ,p_product    => x.product_code
                                 ,p_policy     => x.person_code
                                 ,p_poep       => l_poep_id
                                 ,p_return_msg => l_return_msg);
      dbms_output.put_line(x.rownum || ': Cntry(' || x.country_code || '), Prod(' || x.product_code || '), Poli(' || x.policy_code || 
                          '), Person(' || x.person_code || ') and Date(' || x.contribution_date || ') = POEP Id - CCS(' || x.poep_id || '), Func(' || 
                          get_poep_id(x.contribution_date, p_policy => x.person_code) || '), Proc(' || l_poep_id || '), Msg ' ||  l_return_msg);
    ELSE
      commissions_pkg.get_poep_id(p_date       => x.contribution_date
                                 ,p_product    => x.product_code
                                 ,p_policy     => x.policy_code
                                 ,p_person     => x.person_code
                                 ,p_poep       => l_poep_id
                                 ,p_return_msg => l_return_msg);
      dbms_output.put_line(x.rownum || ': Cntry(' || x.country_code || '), Prod(' || x.product_code || '), Poli(' || x.policy_code || 
                          '), Person(' || x.person_code || ') and Date(' || x.contribution_date || ') = POEP Id - CCS(' || x.poep_id || '), Func(' || 
                          get_poep_id(x.contribution_date, p_person => x.person_code) || '), Proc(' || l_poep_id || '), Msg ' ||  l_return_msg);
    END IF;
  END LOOP;
END;
