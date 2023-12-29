create or replace FUNCTION check_resigned_status(p_broker_id_no IN NUMBER, p_company_id_no IN NUMBER, p_date IN DATE) RETURN NUMBER IS
 v_num number := NULL;
 
 CURSOR c_check_brokerage_status IS
 SELECT company_table_type_id_no  --27
   FROM (SELECT DISTINCT bf.company_id_no, btt.company_table_type_id_no, bf.effective_start_date,       
                RANK() over (PARTITION BY bf.company_id_no ORDER BY bf.effective_start_date DESC) rank_no        
           FROM company_function bf, company_table bt, company_table_type btt              
          WHERE bf.company_table_id_no = bt.company_table_id_no              
            AND bf.company_table_id_no = 2            
		    AND btt.company_table_type_id_no = 27
			AND bf.company_id_no = p_company_id_no
            AND bf.company_table_type_id_no = btt.company_table_type_id_no              
            AND p_date BETWEEN bf.effective_start_date AND bf.effective_end_date)
  WHERE NVL(rank_no,1) = 1;  

  CURSOR c_check_broker_status IS
  SELECT broker_table_type_id_no --6
    FROM (SELECT DISTINCT bf.broker_id_no, btt.broker_table_type_id_no, bf.effective_start_date,       
                 RANK() over (PARTITION BY bf.broker_id_no ORDER BY bf.effective_start_date DESC) rank_no        
            FROM broker_function bf, broker_table bt, broker_table_type btt              
           WHERE bf.broker_table_id_no = bt.broker_table_id_no              
             AND bf.broker_table_id_no = 2    
             AND btt.broker_table_type_id_no = 6
             AND bf.broker_id_no = p_broker_id_no			 
             AND bf.broker_table_type_id_no = btt.broker_table_type_id_no              
             AND p_date BETWEEN bf.effective_start_date AND bf.effective_end_date)
   WHERE NVL(rank_no,1) = 1; 
 
 BEGIN
    
    OPEN c_check_broker_status;
      FETCH c_check_broker_status INTO v_num;
    CLOSE c_check_broker_status;
	
    OPEN c_check_brokerage_status;
      FETCH c_check_brokerage_status INTO v_num;
    CLOSE c_check_brokerage_status;
    
	IF V_NUM IS NOT NULL 	THEN
	   RETURN 0;
	ELSE
	   RETURN NULL;
	END IF;

EXCEPTION
   WHEN OTHERS THEN
     RETURN NULL;
 END;