 select * from LHAFLIVE.GRPCON where GC_DT_CONTRACT between 20170100 and 20171231 or GC_DT_TO between 20170100 and 20171231 and GC_STATUS = 'A';