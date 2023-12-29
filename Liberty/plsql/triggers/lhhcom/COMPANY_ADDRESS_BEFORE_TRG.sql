create or replace TRIGGER "LHHCOM"."COMPANY_ADDRESS_BEFORE_TRG"  
BEFORE
INSERT OR UPDATE ON COMPANY_ADDRESS
FOR EACH ROW
  BEGIN
  
  IF INSERTING THEN
    insert into DNLD_COMPANY_ADDRESS (company_id_no, country_code, address_type_code, effective_start_date, stamp_datetime, stamp_ind, batch_no, last_update_datetime, username)
                     values (:NEW.company_id_no, :NEW.country_code, :NEW.address_type_code, :NEW.effective_start_date, CURRENT_TIMESTAMP, 'I',0,sysdate,user);
 END IF;
EXCEPTION
   WHEN dup_val_on_index THEN
     NULL; 
END;
/