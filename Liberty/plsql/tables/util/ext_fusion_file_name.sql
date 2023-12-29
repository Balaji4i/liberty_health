CREATE TABLE ext_fusion_file_name (
  filename      CHAR(500)
)
     ORGANIZATION EXTERNAL (
      TYPE ORACLE_LOADER
      DEFAULT DIRECTORY LOGDATA
      ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        BADFILE LOGDATA:'ext_fusion_file_name.bad'
        LOGFILE LOGDATA:'ext_fusion_file_name.log'
        SKIP 0  FIELDS TERMINATED BY ','
        MISSING FIELD VALUES ARE NULL
      )
      LOCATION (LOGDATA:'ext_fusion_file_name.dat')
    )
    PARALLEL 5
REJECT LIMIT UNLIMITED;

