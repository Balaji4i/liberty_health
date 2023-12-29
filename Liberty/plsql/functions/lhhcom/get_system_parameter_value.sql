CREATE OR REPLACE FUNCTION LHHCOM.get_system_parameter_value
(
 P_SYSTEM_NAME       IN VARCHAR2,
 P_PARAMETER_SECTION IN VARCHAR2,
 P_PARAMETER_KEY     IN VARCHAR2
 ) RETURN VARCHAR2 IS
   
   l_parameter_value system_parameter.parameter_value%TYPE;
   
 BEGIN
 
   SELECT parameter_value
     INTO l_parameter_value
     FROM util.system_parameter
    WHERE system_name       = p_system_name
      AND parameter_section = p_parameter_section
      AND parameter_key     = p_parameter_key;
      
   RETURN l_parameter_value;
   
 EXCEPTION
   WHEN OTHERS THEN
   
     RETURN NULL;
   
 END get_system_parameter_value;