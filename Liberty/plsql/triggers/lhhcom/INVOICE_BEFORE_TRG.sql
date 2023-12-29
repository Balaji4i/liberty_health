create or replace TRIGGER "LHHCOM"."INVOICE_BEFORE_TRG"  
BEFORE
INSERT OR UPDATE ON invoice
FOR EACH ROW
  BEGIN
  
  IF INSERTING AND :NEW.RELEASE_DATE IS NOT NULL THEN
    insert into DNLD_INVOICE (invoice_no,stamp_datetime,stamp_ind,batch_no,last_update_datetime,username)
                     values (:NEW.invoice_no, CURRENT_TIMESTAMP, 'I',0,sysdate,user);
 END IF;
 
  IF UPDATING AND :NEW.RELEASE_DATE IS NOT NULL AND :NEW.PAYMENT_REJECT_DATE IS NULL AND :NEW.PAYMENT_DATE IS NULL  THEN
    insert into DNLD_INVOICE (invoice_no,stamp_datetime,stamp_ind,batch_no,last_update_datetime,username)
                     values (:NEW.invoice_no, CURRENT_TIMESTAMP, 'I',0,sysdate,user);
 END IF;
EXCEPTION
   WHEN dup_val_on_index THEN
     NULL; 
END;
/
