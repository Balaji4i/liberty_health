DECLARE
BEGIN
MERGE INTO lhhcom.ohi_comm_perc                       ocp 
  USING (
         select 
                company_id_no
               ,ROUND(company_comm_perc, 2) company_comm_perc
               ,company_comm_desc
               ,effective_start_date
               ,effective_end_date
           from company_comm_perc -- WHERE company_id_no = 10000061
        )                                               ccp
  ON    (ocp.company_id_no = ccp.company_id_no 
    AND  ocp.broker_id_no IS NULL
    AND  ocp.product_code IS NULL
    AND  ocp.poep_id IS NULL
    AND  ocp.inse_code IS NULL
    AND  ocp.policy_code IS NULL
    AND  ocp.group_code IS NULL
    AND  ocp.effective_start_date = ccp.effective_start_date
        )
  WHEN MATCHED THEN UPDATE SET
       ocp.comm_perc = ccp.company_comm_perc
      ,ocp.comm_desc = ccp.company_comm_desc
      ,ocp.effective_end_date = ccp.effective_end_date
   WHERE effective_end_date != ccp.effective_end_date
      OR  comm_perc != ccp.company_comm_perc
      OR  comm_perc != ccp.company_comm_perc
  WHEN NOT MATCHED THEN
  INSERT (ocp.company_id_no, ocp.comm_perc, ocp.comm_desc, ocp.effective_start_date, ocp.effective_end_date, ocp.created_username)
  VALUES (ccp.company_id_no, ccp.company_comm_perc, ccp.company_comm_desc, ccp.effective_start_date, ccp.effective_end_date, USER);
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Error: ' ||  sqlerrm);
END;