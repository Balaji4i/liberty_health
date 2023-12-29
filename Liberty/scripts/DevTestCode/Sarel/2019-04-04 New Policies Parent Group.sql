    SELECT grac.id                   		   AS grac_id
          ,grac.code                 		   AS group_code
          ,grac.descr                		   AS group_name
          ,grac.display_name         		   AS group_name
          ,groc.descr                		   AS group_name
          ,groc.display_name         		   AS group_name
          ,grac.start_date           		   AS effective_start_date
          ,nvl(grac.enddate,'31-JAN-3100') AS effective_end_date  
--          ,grac.parentgroup          		   AS parentgroup_code
          ,CASE WHEN     pgroc.code        IS NOT NULL THEN    pgroc.code
--                                                       ELSE    groc.code
                                                       ELSE    NULL -- groc.code
           END 	                           AS parentgroup_code
--          ,grptype.grouptype         		   AS group_type
          ,CASE WHEN     pgroc.code        IS NOT NULL THEN    'GROUP'
                                                       ELSE    'PARENT'
           END 	                           AS group_type
          ,grpclass.code            		   AS group_class
          ,prefcur.code             		   AS preferred_currency_code
          ,country.code              		   AS country_code
          ,grac.last_updated_date    		   AS last_update_datetime
          ,nvl(upper(usrs.login_name),usrs.display_name)    
                                           AS username    
      FROM pol_group_accounts_v@policies      grac
      LEFT OUTER 
      JOIN pol_group_clients_v@policies       groc
        ON grac.groc_id = groc.id
      LEFT OUTER 
      JOIN pol_group_clients_v@policies       pgroc
        ON groc.groc_id = pgroc.id
--      LEFT OUTER 
--      JOIN fcod_grouptype@policies            grptype
--        ON grac.grouptype_id = grptype.id
      LEFT OUTER 
      JOIN fcod_groupclass@policies           grpclass
        ON grac.groupclass_id = grpclass.id
      LEFT OUTER
      JOIN fcod_prefcur@policies              prefcur
        ON grac.prefcur_id = prefcur.id
      LEFT OUTER
      JOIN fcod_country@policies              country
        ON grac.country_id = country.id
      LEFT OUTER
      JOIN ohi_users_v@policies               usrs
        ON usrs.id = grac.last_updated_by
--     WHERE groc.code LIKE 'ADAM%'
--     WHERE pgroc.code IS NULL
     WHERE groc.code IN ('BAYLORLESOTH', 'BUTHABSCOE', 'COEMELD', 'COEPINCH', 
                         'COEPROTECT', 'COESTAFFCHASE', 'COESTAFFMED', 'COESTARL', 
                         'COEVODAFONE', 'LERIBESCOE', 'MOHALESHOEK', 'MOKHOTLONGSCOE', 
                         'QACHASNEK', 'ADAMSMITH', 'JJ BUTCHERY', 'AFGRIBUKWO')
     ORDER BY parentgroup_code ASC
             ,group_type DESC
             ,group_code ASC;

select grac.code  as "GRAC Group Code"
    ,  grac.descr as "GRAC Group Descr"
    ,  groc.code  as "GROC Group Code"
    ,  groc.descr as "GROC Group Descr"
    ,  groc2.code as "GROC Parent Group"
    ,  groc2.descr as "GROC Parent Descr"
from   pol_group_accounts_v@policies grac
    ,  pol_group_clients_v@policies groc
    ,  pol_group_clients_v@policies groc2
where grac.code like 'ADAM%'
and  grac.groc_id = groc.id
and  groc.groc_id = groc2.id;

select * from pol_group_clients_v@policies;
select * from pol_group_accounts_v@policies;
select * from fcod_grouptype@policies;

select DISTINCT c.company_id_no, o.company_id_no from (
        SELECT
               poli.id                                           AS poli_id
              ,CASE WHEN     agnt.code        IS NOT NULL 
                         AND brok.code        IS NOT NULL   THEN    poba.id
                    WHEN     agnt.code        IS NOT NULL  
                         AND brok.code        IS NULL       THEN    poba.id
                    WHEN     agnt.code        IS NULL      
                         AND brok.code        IS NOT NULL   THEN    poba.id
                    WHEN     agnt.code        IS NULL 
                         AND brok.code        IS NULL 
                         AND grag.agent       IS NOT NULL   THEN    grag.id 
                    WHEN     agnt.code        IS NULL 
                         AND brok.code        IS NULL
                         AND grag.agent       IS NULL 
                         AND grbr.broker      IS NOT NULL   THEN    grbr.id 
                    WHEN     agnt.code        IS NULL 
                         AND brok.code        IS NULL
                         AND grag.agent       IS NULL 
                         AND grbr.broker      IS NULL       THEN    pogr.id 
               END	    	                                       AS pobr_id
              ,CASE WHEN     trim(agnt.code)  IS NOT NULL   THEN    trim(agnt.code) 
                                                            ELSE    trim(grag.agent)
               END 	                                             AS broker_id_no
  			      ,CASE WHEN     trim(brok.code)  IS NOT NULL   THEN    trim(brok.code) 
                                                            ELSE    trim(grbr.broker)     
               END	                                             AS company_id_no				
       			  ,CASE WHEN     trim(agnt.code)   IS NOT NULL  THEN    poba.start_date
                    WHEN     trim(grag.agent)  IS NOT NULL
                         AND pogr.start_date < grag.start_date THEN grag.start_date
                    WHEN     trim(grag.agent)  IS NOT NULL  THEN    nvl(pogr.start_date,grag.start_date)
                    WHEN     trim(brok.code)   IS NOT NULL  THEN    poba.start_date
                    WHEN     trim(grbr.broker) IS NOT NULL
                         AND pogr.start_date < grbr.start_date THEN grbr.start_date
                                                            ELSE    nvl(pogr.start_date, grbr.start_date)
               END				                                       AS effective_start_date	
       			  ,CASE WHEN     trim(agnt.code)   IS NOT NULL  THEN    nvl(poba.end_date,'31-JAN-3100')
                    WHEN     trim(grag.agent)  IS NOT NULL
                         AND pogr.end_date < grag.end_date  THEN    nvl(grag.end_date,'31-JAN-3100')
                    WHEN     trim(grag.agent)  IS NOT NULL  THEN    nvl(nvl(pogr.end_date, grag.end_date),'31-JAN-3100')
                    WHEN     trim(brok.code)   IS NOT NULL  THEN    nvl(poba.end_date,'31-JAN-3100')
                    WHEN     trim(grbr.broker) IS NOT NULL
                         AND pogr.end_date > grbr.end_date  THEN    nvl(grbr.end_date,'31-JAN-3100')
                                                            ELSE    nvl(nvl(pogr.end_date, grbr.end_date),'31-JAN-3100')
               END                                               AS effective_end_date
              ,poli.last_updated_date                 		       AS last_update_datetime
              ,nvl(upper(usrs.login_name),usrs.display_name)     AS username
  			  FROM pol_policies_v@policies                              poli
          LEFT OUTER 
          JOIN pol_policy_broker_agents_v@policies                  poba   -- (both)
            ON     poli.id = poba.poli_id
          LEFT OUTER 
          JOIN pol_brokers_v@policies                               brok
            ON     poba.brkr_id = brok.id 
  		    LEFT OUTER 
          JOIN pol_agents_v@policies                                agnt
            ON     poba.agnt_id = agnt.id 
          LEFT OUTER 
          JOIN pol_policy_group_accounts_v@policies                 pogr
            ON     poli.id = pogr.poli_id 
               AND poba.id IS NULL
  		    LEFT OUTER 
          JOIN grac_agent@policies                                  grag
            ON     grag.grac_id = pogr.grac_id 
               AND poba.id IS NULL
               AND (   pogr.start_date 
                       BETWEEN grag.start_date AND nvl(grag.end_date,'31-JAN-3100')
                    OR (   pogr.start_date 
                           NOT BETWEEN grag.start_date AND nvl(grag.end_date,'31-JAN-3100')
                       AND grag.start_date 
                           BETWEEN pogr.start_date AND nvl(pogr.end_date,'31-JAN-3100')))
          LEFT OUTER 
          JOIN grac_broker@policies                                 grbr
            ON     grbr.grac_id = pogr.grac_id 
               AND poba.id IS NULL
               AND (   pogr.start_date 
                       BETWEEN grbr.start_date AND nvl(grbr.end_date,'31-JAN-3100')
                    OR (   pogr.start_date 
                           NOT BETWEEN grbr.start_date AND nvl(grbr.end_date,'31-JAN-3100')
                       AND grbr.start_date 
                           BETWEEN pogr.start_date AND nvl(pogr.end_date,'31-JAN-3100')))
          JOIN ohi_users_v@policies                                 usrs
            ON     usrs.id = poli.last_updated_by
         WHERE     poli.version = (SELECT MAX(version)
                                     FROM pol_policies_v@policies 
                                    WHERE     code = poli.code 
                                          AND status = 'APPROVED')) o
LEFT OUTER JOIN company c on c.company_id_no = o.company_id_no;

    SELECT    grac.id                   		  AS grac_id
             ,grac.code                 		  AS group_code
             ,grac.descr                		  AS group_name
             ,grac.start_date           		  AS effective_start_date
             ,nvl(grac.enddate,'31-JAN-3100') AS effective_end_date  
             ,CASE WHEN     pgroc.code        IS NOT NULL THEN    pgroc.code
                                                          ELSE    NULL
              END 	                          AS parentgroup_code
             ,CASE WHEN     pgroc.code        IS NOT NULL THEN    'GROUP'
                                                          ELSE    'PARENT'
              END 	                          AS group_type
             ,grpclass.code            		    AS group_class
             ,prefcur.code             		    AS preferred_currency_code
             ,country.code              		  AS country_code
             ,grac.last_updated_date    		  AS last_update_datetime
             ,nvl(upper(usrs.login_name),usrs.display_name)    
                                              AS username    
         
      FROM pol_group_accounts_v@policies                            grac
      LEFT OUTER 
      JOIN pol_group_clients_v@policies                             groc
        ON grac.groc_id = groc.id
      LEFT OUTER 
      JOIN pol_group_clients_v@policies       pgroc
        ON groc.groc_id = pgroc.id
--      LEFT OUTER 
--      JOIN fcod_grouptype@policies            grptype
--        ON grac.grouptype_id = grptype.id
        JOIN fcod_groupclass@policies                               grpclass
          ON grac.groupclass_id = grpclass.id
      LEFT OUTER
        JOIN fcod_prefcur@policies                                  prefcur
          ON grac.prefcur_id = prefcur.id
      LEFT OUTER
        JOIN fcod_country@policies                                  country
          ON grac.country_id = country.id
             JOIN ohi_users_v@policies                              usrs
          ON usrs.id = grac.last_updated_by
     WHERE groc.code IN ('BAYLORLESOTH', 'BUTHABSCOE', 'COEMELD', 'COEPINCH', 
                         'COEPROTECT', 'COESTAFFCHASE', 'COESTAFFMED', 'COESTARL', 
                         'COEVODAFONE', 'LERIBESCOE', 'MOHALESHOEK', 'MOKHOTLONGSCOE', 
                         'QACHASNEK', 'ADAMSMITH', 'JJ BUTCHERY', 'AFGRIBUKWO')
     ORDER BY parentgroup_code ASC
             ,group_type DESC
             ,group_code ASC;
