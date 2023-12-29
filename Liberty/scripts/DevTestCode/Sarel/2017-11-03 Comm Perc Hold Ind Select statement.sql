select poep_id
      ,get_comm_percentage(p_poep => poep_id) as COMM_PERC
      ,get_comm_perc_reason(p_poep => poep_id) as COMM_REASON
      ,get_hold_ind(p_poep => poep_id) as HOLD_IND
      ,get_hold_reason(p_poep => poep_id) as HOLD_REASON
  from ohi_enrollment_products;
  
select Group_code
      ,get_comm_percentage(p_group => group_code) as COMM_PERC
      ,get_comm_perc_reason(p_group => group_code) as COMM_REASON
      ,get_hold_ind(p_group => group_code) as HOLD_IND
      ,get_hold_reason(p_group => group_code) as HOLD_REASON
  from OHI_GROUPS;
