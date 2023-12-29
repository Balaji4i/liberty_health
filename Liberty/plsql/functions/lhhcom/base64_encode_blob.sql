create or replace FUNCTION base64_encode_blob (p BLOB) RETURN BLOB IS
   l_raw    RAW(24573);
   l_base64 RAW(32767);
   l_result BLOB;
   l_offset NUMBER := 1;
  -- l_amount NUMBER := 24573;
  l_amount NUMBER := 23808;
BEGIN
   DBMS_LOB.createtemporary(l_result, FALSE);
   DBMS_LOB.open(l_result, DBMS_LOB.lob_readwrite);
   LOOP
      DBMS_LOB.read(p, l_amount, l_offset, l_raw);
      l_offset := l_offset + l_amount;
      l_base64 := utl_encode.base64_encode(l_raw);
      DBMS_LOB.writeappend(l_result, utl_raw.length(l_base64), l_base64);
   END LOOP;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN l_result;
END;