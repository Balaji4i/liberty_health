create or replace FUNCTION CLOB_FROM_BLOB_FNC(p_blob BLOB) RETURN CLOB 
  IS
      v_clob         clob;
      v_dest_offsset integer := 1;
      v_src_offsset  integer := 1;
      v_lang_context integer := dbms_lob.default_lang_ctx;
      v_warning      integer;

   BEGIN
      IF p_blob IS NULL then
         RETURN NULL;
      end if;

      DBMS_LOB.CREATETEMPORARY(lob_loc => v_clob,cache   => false);

      DBMS_LOB.CONVERTTOCLOB(dest_lob     => v_clob
                            ,src_blob     => p_blob
                            ,amount       => DBMS_LOB.LOBMAXSIZE
                            ,dest_offset  => v_dest_offsset
                            ,src_offset   => v_src_offsset
                            ,blob_csid    => DBMS_LOB.DEFAULT_CSID
                            ,lang_context => v_lang_context
                            ,warning      => v_warning);

      RETURN v_clob;

   END CLOB_FROM_BLOB_FNC;