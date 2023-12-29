create or replace TRIGGER "LHHCOM"."COMPANY_COUNTRY_BEFORE_TRG"  
BEFORE
INSERT OR UPDATE ON COMPANY_COUNTRY
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    insert into DNLD_COMPANY (interf_system_id_no, company_id_no, stamp_datetime, stamp_ind, batch_no, last_update_datetime, username)
                      values (1, :NEW.company_id_no, trunc(sysdate), 'I',0,sysdate,user);
  END IF;
  IF UPDATING THEN
    IF :NEW.company_id_no = :OLD.company_id_no THEN
      insert into DNLD_COMPANY (interf_system_id_no, company_id_no, stamp_datetime, stamp_ind, batch_no, last_update_datetime, username)
                        values (1, :NEW.company_id_no, trunc(sysdate), 'U',0,sysdate,user);
    ELSE
      BEGIN
        insert into DNLD_COMPANY (interf_system_id_no, company_id_no, stamp_datetime, stamp_ind, batch_no, last_update_datetime, username)
                          values (1, :OLD.company_id_no, trunc(sysdate), 'U',0,sysdate,user);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          NULL;
      END;
      insert into DNLD_COMPANY (interf_system_id_no, company_id_no, stamp_datetime, stamp_ind, batch_no, last_update_datetime, username)
                        values (1, :NEW.company_id_no, trunc(sysdate), 'U',0,sysdate,user);
    END IF;
  END IF;
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    NULL;
END;
/
