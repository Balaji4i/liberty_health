create or replace FUNCTION get_hold_ind
                           (p_date           IN  DATE     DEFAULT SYSDATE
                           ,p_company        IN  NUMBER   DEFAULT NULL
                           ,p_broker         IN  NUMBER   DEFAULT NULL
                           ,p_group          IN  VARCHAR2 DEFAULT NULL
                           ,p_product        IN  VARCHAR2 DEFAULT NULL
                           ,p_policy         IN  VARCHAR2 DEFAULT NULL
                           ,p_person         IN  VARCHAR2 DEFAULT NULL
                           ,p_poep           IN  VARCHAR2 DEFAULT NULL)
                           RETURN                ohi_hold_ind.hold_ind%type

IS

  v_hold_ind       ohi_hold_ind.hold_ind%type;
  v_description    ohi_hold_ind.hold_reason%type;
  v_return_msg     VARCHAR2(200);
  
BEGIN
  commissions_pkg.get_hold_ind (p_date => p_date
                                 ,p_company => p_company
                                 ,p_broker => p_broker
                                 ,p_group => p_group
                                 ,p_product => p_product
                                 ,p_policy => p_policy
                                 ,p_person => p_person
                                 ,p_poep => p_poep
                                 ,p_hold_ind => v_hold_ind
                                 ,p_hold_reason => v_description
                                 ,p_return_msg => v_return_msg);
  RETURN v_hold_ind;

END get_hold_ind;
/