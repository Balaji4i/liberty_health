create or replace PROCEDURE READ_IN_ZIPFLE_PRC(p_filename IN VARCHAR2, p_directory IN VARCHAR2, p_outblob OUT BLOB)  
    IS  
    
    v_lob              BLOB;    
    v_bfile            BFILE;  
      
    v_src_offset       NUMBER :=1;  
    v_dest_offset      NUMBER :=1;   
      
    BEGIN  
    DBMS_LOB.CREATETEMPORARY(v_lob,FALSE,DBMS_LOB.SESSION);  
    v_bfile := BFILENAME(p_directory,p_filename);   
    
    DBMS_LOB.FILEOPEN(v_bfile,DBMS_LOB.FILE_READONLY);  
    
    DBMS_LOB.LOADBLOBFROMFILE(dest_lob    => v_lob,  
                              src_bfile   => v_bfile,  
                              amount      => DBMS_LOB.GETLENGTH(v_bfile),  
                              dest_offset => v_dest_offset,  
                              src_offset  => v_src_offset  
                             );  
      
    DBMS_LOB.FILECLOSE(v_bfile);  
    
    p_outblob := v_lob;  
    
    END READ_IN_ZIPFLE_PRC;