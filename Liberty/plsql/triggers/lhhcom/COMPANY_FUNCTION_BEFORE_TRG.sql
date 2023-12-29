create or replace TRIGGER "LHHCOM"."COMPANY_FUNCTION_BEFORE_TRG"  
BEFORE
INSERT OR UPDATE ON COMPANY_FUNCTION
FOR EACH ROW
  BEGIN
  
  IF INSERTING THEN
    insert into DNLD_COMPANY (interf_system_id_no, company_id_no, stamp_datetime, stamp_ind, batch_no, last_update_datetime, username)
                     values (1, :NEW.company_id_no, trunc(sysdate), 'I',0,sysdate,user);
  END IF;
  
EXCEPTION
   WHEN dup_val_on_index THEN
     UPDATE DNLD_COMPANY
	    SET batch_no = 0
	  WHERE company_id_no = :NEW.company_id_no
      AND interf_system_id_no = 1
	    AND stamp_datetime = trunc(sysdate); 
END;
/
