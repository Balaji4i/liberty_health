CREATE or REPLACE FUNCTION get_comm_percent
                           (p_date           IN  DATE     DEFAULT SYSDATE
                           ,p_company        IN  NUMBER   DEFAULT NULL
                           ,p_broker         IN  NUMBER   DEFAULT NULL
                           ,p_group          IN  VARCHAR2 DEFAULT NULL
                           ,p_product        IN  VARCHAR2 DEFAULT NULL
                           ,p_policy         IN  VARCHAR2 DEFAULT NULL
                           ,p_person         IN  VARCHAR2 DEFAULT NULL
                           ,p_poep           IN  VARCHAR2 DEFAULT NULL)
                           RETURN                ohi_comm_perc.comm_perc%type

IS

  v_percentage     ohi_comm_perc.comm_perc%type;
  v_description    ohi_comm_perc.comm_desc%type;
  v_return_msg     VARCHAR2(200);
  
BEGIN
  commissions_pkg.get_percentage (p_date => p_date
                                 ,p_company => p_company
                                 ,p_broker => p_broker
                                 ,p_group => p_group
                                 ,p_product => p_product
                                 ,p_policy => p_policy
                                 ,p_person => p_person
                                 ,p_poep => p_poep
                                 ,p_percentage => v_percentage
                                 ,p_description => v_description
                                 ,p_return_msg => v_return_msg);
  RETURN v_percentage;
END get_comm_percent;
/