CREATE OR REPLACE TRIGGER lhhcom.COMMS_PARTIAL_UPD_TRG
BEFORE UPDATE ON lhhcom.comms_on_partial_receipt
FOR EACH ROW
BEGIN
  IF :new.comms_partial_pk IS NULL THEN
     SELECT comms_partial_receipt_seq.nextval INTO :new.comms_partial_pk FROM DUAL;
     :new.last_update_date := SYSDATE;
  END IF;
END;
/