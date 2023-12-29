SELECT ocp.company_id_no
      ,comp.company_name)
      ,ocp.comm_perc
      ,ocp.comm_desc
      ,ocp.effective_start_date
      ,ocp.effective_end_date
      ,trunc(ocp.last_update_datetime) reject_date
      ,ocp.reject_username  
  FROM ohi_comm_perc            ocp
      ,company                  comp  
 WHERE ocp.company_id_no = comp.company_id_no  
   AND auth_username     IS NULL
   AND reject_username   IS NOT NULL
   AND ocp.company_id_no IS NOT NULL;
   
select o.group_code, group_name, o.comm_perc, o.comm_desc, o.effective_start_date, o.effective_end_date, trunc(o.last_update_datetime) reject_Date, o.reject_username    
from ohi_comm_perc o , ohi_groups c    
where o.group_code = c.group_code    
  and auth_username is null    
  and product_code is null 
    and reject_username is not null   
  and o.group_code is not null
   
CompanyCommPercOutstandingApprovalRoView;

SELECT
  *
FROM
  USER_SYS_PRIVS;
  
SELECT ocpa.company_id_no
      ,ocpa.transaction_datetime
      ,ocpa.transaction_desc
      ,ocpa.comm_perc          AS New_Value
      ,ocp.comm_perc           AS Current_Comm
  FROM ohi_comm_perc_audit     ocpa
  LEFT OUTER
  JOIN ohi_comm_perc           ocp
    ON (ocp.company_id_no = ocpa.company_id_no
   AND  ocp.broker_id_no  IS NULL
   AND  ocp.group_code    IS NULL
   AND  ocp.product_code  IS NULL
   AND  ocp.policy_code   IS NULL
   AND  ocp.inse_code     IS NULL
   AND  ocp.poep_id       IS NULL)
 WHERE ocpa.company_id_no IS NOT NULL
   AND ocpa.broker_id_no  IS NULL
   AND ocpa.group_code    IS NULL
   AND ocpa.product_code  IS NULL
   AND ocpa.policy_code   IS NULL
   AND ocpa.inse_code     IS NULL
   AND ocpa.poep_id       IS NULL
   AND ocpa.transaction_datetime BETWEEN to_date('01-JAN-2017', 'DD-MON-YYYY') AND to_date('01-DEC-2017', 'DD-MON-YYYY')
 ORDER BY ocpa.company_id_no
         ,ocpa.transaction_datetime;
   