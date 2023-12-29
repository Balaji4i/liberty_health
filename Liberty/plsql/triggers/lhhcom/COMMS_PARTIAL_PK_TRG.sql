    CREATE OR REPLACE TRIGGER lhhcom.COMMS_PARTIAL_PK_TRG
BEFORE INSERT ON lhhcom.comms_on_partial_receipt
FOR EACH ROW
DECLARE 
  
  E_EXCEP   EXCEPTION;
  D_EXCEP   EXCEPTION;
  CURSOR c1 IS
  SELECT effective_start_date, effective_end_date
    FROM COMMS_ON_PARTIAL_RECEIPT
   WHERE company_id_no = :new.company_id_no
     AND group_code    = :new.group_code
     AND country_code  = :new.country_code;

BEGIN
   
   
   FOR I IN C1 LOOP
        IF (:NEW.effective_start_date BETWEEN I.effective_start_date AND I.effective_end_date ) OR
           (:NEW.effective_end_date BETWEEN I.effective_start_date AND I.effective_end_date ) THEN
           RAISE E_EXCEP;
        END IF;
   END LOOP;

   IF :new.effective_end_date < :new.effective_start_date THEN
      RAISE D_EXCEP;
   END IF;

  IF :new.comms_partial_pk IS NULL THEN
     SELECT comms_partial_receipt_seq.nextval INTO :new.comms_partial_pk FROM DUAL;
     :new.creation_date := SYSDATE;
     :new.active_yn     := 'N';
  END IF;
EXCEPTION
  WHEN E_EXCEP THEN
        RAISE_APPLICATION_ERROR(-20991, 'Cannot INSERT record,brokerage, country, group combination already exists for date range');
  WHEN D_EXCEP THEN
        RAISE_APPLICATION_ERROR(-20992, 'Cannot INSERT record - End date must be on or after the start date');
   WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20111, 'Unhandled Exception - error '||SQLERRM);
END;
/