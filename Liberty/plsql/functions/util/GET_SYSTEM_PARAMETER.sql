create or replace FUNCTION      UTIL.GET_SYSTEM_PARAMETER (P_SYSTEM_NAME IN VARCHAR2, 
                                                 P_PARAMETER_SECTION IN VARCHAR2, 
                                                 P_PARAMETER_KEY IN VARCHAR2) 
                                                 RETURN VARCHAR2 AS 
  
  lv_parameter_value     SYSTEM_PARAMETER.PARAMETER_VALUE%TYPE := null;
  
  cursor c_param_value is
    select parameter_value
      from util.system_parameter 
     where system_name =  P_SYSTEM_NAME
       and parameter_section = P_PARAMETER_SECTION
       and parameter_key = P_PARAMETER_KEY;
       
BEGIN
   
   OPEN c_param_value;
    FETCH c_param_value into lv_parameter_value;
   CLOSE c_param_value;
   
   RETURN lv_parameter_value; 
END GET_SYSTEM_PARAMETER;
/