create or replace TRIGGER "LHHCOM"."BROKER_BEFORE_TRG"  
BEFORE
INSERT OR UPDATE ON broker
FOR EACH ROW
  BEGIN
  
  IF INSERTING THEN
    insert into DNLD_BROKER (broker_id_no, stamp_datetime, stamp_ind, batch_no, last_update_datetime, username)
                     values (:NEW.broker_id_no, CURRENT_TIMESTAMP, 'I',0,sysdate,user);
 END IF;
EXCEPTION
   WHEN dup_val_on_index THEN
     NULL; 
END;
/
