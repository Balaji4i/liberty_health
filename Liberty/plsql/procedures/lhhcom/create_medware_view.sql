CREATE OR REPLACE PROCEDURE lhhcom.create_medware_view AS

   l_db_name global_name.global_name%TYPE;
   l_db_link ALL_DB_LINKS.db_link%TYPE;

BEGIN

  SELECT global_name 
    INTO l_db_name 
    FROM global_name;


  IF l_db_name LIKE '%DEV%' THEN -- dev
  
     l_db_link := 'LHAFDEV.receipts@MEDWARE_DEV.LIBERTY.CO.ZA';
    
  ELSIF l_db_name LIKE '%UAT%' THEN-- uat
  
     l_db_link := 'LHAFUAT.receipts@MEDWARE_UAT.LIBERTY.CO.ZA';
  
  ELSIF  l_db_name LIKE '%PREP%' THEN--preprod
   
     l_db_link := 'MEDWARE_PRE.LIBERTY.CO.ZA';
  
  ELSIF  l_db_name LIKE '%TST%' THEN--test
   
     l_db_link := 'MEDWARE_TEST.LIBERTY.CO.ZA';
   
  ELSIF  l_db_name LIKE '%PRD%' THEN --test
    
    l_db_link := 'MEDWARE.LIBERTY.CO.ZA';
    
  END IF;  


   EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW lhhcom.COMM_MEDWARE_RECEIPTS_V AS
                         SELECT TO_CHAR(re_receipt_no) re_receipt_no 
                        FROM '||l_db_link;


END create_medware_view;
/