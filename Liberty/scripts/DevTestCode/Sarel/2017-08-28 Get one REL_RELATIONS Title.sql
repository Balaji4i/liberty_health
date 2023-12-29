select rela.CODE as BENEF_CODE
     , (SELECT titl.code as title 
          FROM OHI_POLICIES_VIEWS_OWNER.REL_TITLES_V                            titl 
         WHERE titl.id = 
         (SELECT reti.TITL_ID 
            FROM OHI_POLICIES_VIEWS_OWNER.REL_PERSONS_TITLES_V                  reti
           WHERE reti.rela_id = rela.id AND ROWNUM = 1
         )
       ) as TITLE
     , rela.FIRST_NAME
     , rela.initials
     , rela.NAME 
  from OHI_POLICIES_VIEWS_OWNER.REL_RELATIONS_V                                 rela;
--  WHERE rela.id = 12252;