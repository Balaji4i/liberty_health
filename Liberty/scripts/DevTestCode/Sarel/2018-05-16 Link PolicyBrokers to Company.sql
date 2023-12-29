  select 
         cpr.country_code              cprCntry
--        ,CPR.group_code                cprGroup
--        ,poli.grac_id                  poliGRAC
        ,grac.group_code               gracGroup
--        ,cpr.product_code              cprProd
        ,prod.product_code             prodProd
--        ,poep.enpr_id                  poepENPR
        ,poep.poep_id                  poepPoep
--        ,prod.enpr_id                  prodENPR
--        ,CPR.policy_code               cprPolicy
--        ,poli.poli_id                  poliPOLI
        ,poli.policy_code              poliPolicy
--        ,poen.poen_id                  poenId
--        ,inse.inse_id                  inseId
        ,inse.inse_code                inseCode
        ,pobr.broker_id_no             pobrBroker
        ,pobr.company_id_no            pobrCompany
--        ,CPR.person_code               cprPerson
        ,cpr.contribution_date         cprSubsDate
    from COMMS_PAYMENTS_RECEIVED       cpr
    inner  
    join (
          select 
                 trim(policy_code)     policy_cde
                ,max(poli_id)          max_poli
            from OHI_POLICIES
--           where last_update_datetime  <= cpr.contribution_date
           group by trim(policy_code)
         )                             maxpoli
      on maxpoli.policy_cde            = trim(cpr.policy_code)
    inner  
    join OHI_POLICIES                  poli
      on trim(poli.policy_code)        = maxpoli.policy_cde
     and poli.poli_id                  = maxpoli.max_poli
    left outer 
    join OHI_GROUPS                    grac
      on grac.grac_id                  = poli.grac_id
    left outer 
    join OHI_POLICY_ENROLLMENTS        poen
      on poen.poli_id                  = poli.poli_id
    inner  
    join OHI_INSURED_ENTITIES          inse
      on inse.inse_id                  = poen.inse_id
     and trim(inse.INSE_CODE)          = trim(cpr.person_code)
    left outer 
    join OHI_ENROLLMENT_PRODUCTS       poep
      on poep.poen_id                  = poen.poen_id
    left outer 
    join OHI_PRODUCTS                  prod
      on prod.product_code             = cpr.product_code
    left outer 
    join OHI_POLICY_BROKERS            pobr
      on pobr.poli_id                  = poli.poli_id
   where cpr.policy_code = '5074444'
--   where cpr.group_code = 'M2M';
   order by cpr.policy_code;

select * from OHI_POLICIES where poli_id in (15974, 34064, 33922);
select * from OHI_POLICIES_VIEWS_OWNER.POL_POLICIES_V where id in (15974, 34064, 33922);
select * from OHI_POLICIES_VIEWS_OWNER.POL_POLICIES_V where code = '5074444';

SELECT poli.id                                AS poli_id
      ,CASE WHEN agnt.code IS NOT NULL AND brok.code IS NOT NULL               THEN poba.id
            WHEN agnt.code IS NOT NULL  AND brok.code IS NULL       THEN poba.id
            WHEN agnt.code IS NULL      AND brok.code IS NOT NULL   THEN poba.id
            WHEN agnt.code IS NULL AND brok.code IS NULL 
                                   AND grag.agent IS NOT NULL                             THEN grag.id 
            WHEN agnt.code IS NULL AND brok.code IS NULL
                                   AND grag.agent IS NULL AND grbr.broker IS NOT NULL     THEN grbr.id END
	    	 AS pobr_id                                               -- broker_agents (both and both group table IDs)
			,CASE WHEN trim(agnt.code) IS NOT NULL  THEN trim(agnt.code) 
                                              ELSE trim(grag.agent)      END 
	    	AS broker_id_no
			,CASE WHEN trim(brok.code) IS NOT NULL THEN trim(brok.code) 
                                               ELSE trim(grbr.broker)     END	
            AS company_id_no				
			,CASE WHEN trim(agnt.code)  IS NOT NULL THEN poba.start_date
                                               WHEN trim(grag.agent)  IS NOT NULL THEN grag.start_date
                                               WHEN trim(brok.code) IS NOT NULL THEN poba.start_date
                                               ELSE grbr.start_date END	
			AS effective_start_date	
			,CASE WHEN trim(agnt.code)  IS NOT NULL THEN nvl(poba.end_date,'31-JAN-3100')
                                               WHEN trim(grag.agent)  IS NOT NULL THEN nvl(grag.end_date,'31-JAN-3100')
                                               WHEN trim(brok.code) IS NOT NULL THEN nvl(poba.end_date,'31-JAN-3100')
                                               ELSE nvl(grbr.end_date,'31-JAN-3100') END
            AS effective_end_date
            ,poli.last_updated_date                 
		  AS last_update_datetime
            ,nvl(upper(usrs.login_name),usrs.display_name)    
          AS username
            ,poli.version
            ,poli.status
		  --  ,trim(brok.code)                        AS poba_broker    
          --  ,trim(agnt.code)                        AS poba_agent
          --  ,poba.start_date                        AS poba_start_date   -- (both)
          --  ,nvl(poba.end_date,'31-JAN-3100')       AS poba_end_date     -- (both)
          --  ,grbr.id                                AS grbr_id           -- grac-broker
          --  ,grag.id                                AS grag_id           -- grac-agent
          --  ,trim(grbr.broker)                      AS grbr_broker
          --  ,trim(grag.agent)                       AS grag_agent        
          --  ,grbr.start_date                        AS grbr_start_date   -- Broker only
          --  ,nvl(grbr.end_date,'31-JAN-3100')       AS grbr_end_date     -- Broker only
          --  ,grag.start_date                        AS grag_start_date   -- Agent only
          --  ,nvl(grag.end_date,'31-JAN-3100')       AS grag_end_date     -- Agent only	
          --  ,pogr.id                                AS pogr_id           -- Policy_Group id
          --  ,pogr.start_date                        AS pogr_start_date   -- Policy_Group 
          --  ,nvl(pogr.end_date,'31-JAN_3100')       AS pogr_end_date     -- Policy_Group
		  -- ,grbr.grac_id                            AS gracb_id         -- Broker only
          -- ,grag.grac_id                            AS graca_id         -- Agent only
          -- ,brok.id                                 AS brok_id
			FROM pol_policies_v@policies                              poli
           LEFT OUTER 
             JOIN pol_policy_broker_agents_v@policies                poba   -- (both)
               ON poli.id = poba.poli_id
			   
          LEFT OUTER 
             JOIN pol_brokers_v@policies                             brok
               ON poba.brkr_id = brok.id 

		  LEFT OUTER 
             JOIN pol_agents_v@policies                              agnt
               ON poba.agnt_id = agnt.id 
           
	-- NEW TABLE DATES MUST BE INCLUDED
          LEFT OUTER 
              JOIN pol_policy_group_accounts_v@policies              pogr
                ON poli.id = pogr.poli_id 
		
		  LEFT OUTER 
             JOIN grac_agent@policies                                grag
               ON grag.grac_id = pogr.grac_id AND poba.id IS NULL
			   
           LEFT OUTER 
             JOIN grac_broker@policies                               grbr
               ON grbr.grac_id = pogr.grac_id AND poba.id IS NULL
			         
           JOIN ohi_users_v@policies                                 usrs
            ON usrs.id = poli.last_updated_by
      
        	    WHERE poli.version = (SELECT MAX(version)
                            FROM pol_policies_v@policies 
                          WHERE code = poli.code 
                            AND status = 'APPROVED')

               AND (pogr.id = (SELECT MAX(id) 
                                     FROM pol_policy_group_accounts_v@policies
                                     WHERE pogr.poli_id = poli_id) 
                                     AND (brok.code IS NOT NULL OR agnt.code IS NOT NULL)) 
               AND (trim(brok.code) IS NOT NULL 
                 OR trim(agnt.code) IS NOT NULL 
						     OR trim(grag.agent) IS NOT NULL 
						     OR trim(grbr.broker) IS NOT NULL)  
						   AND (trim(pogr.poli_id) IS NOT NULL and trim(pogr.grac_id) IS NOT NULL)  
						   AND pogr.start_date IS NOT NULL 
                           AND (grag.start_date IS NULL OR grbr.start_date IS NULL
                           OR (grag.start_date IS NOT NULL AND grbr.start_date IS NOT NULL 
                            AND grag.start_date = grbr.start_date AND (grag.end_date = grbr.end_date) 
                                                   OR (grag.end_date IS NULL AND grbr.end_date IS NULL)))
          AND poli.id in (15974, 34064, 33922);
          
select * from pol_brokers_v@policies;

select * from pol_policy_broker_agents_v@policies;

select * from pol_policy_group_accounts_v@policies where poli_id in (4925, 5426, 15974, 34064, 33922);

select * from grac_broker@policies;-- where grac_id in (4958);


    SELECT    
           poli.code                                       AS poli_code
          ,poli.id                                         AS poli_id
          ,CASE WHEN     agnt.code IS NOT NULL 
                     AND brok.code IS NOT NULL        THEN poba.id
                WHEN     agnt.code IS NOT NULL  
                     AND brok.code IS NULL            THEN poba.id
                WHEN     agnt.code IS NULL   
                     AND brok.code IS NOT NULL        THEN poba.id
                WHEN     agnt.code IS NULL 
                     AND brok.code IS NULL 
                     AND grag.agent IS NOT NULL       THEN grag.id 
                WHEN     agnt.code IS NULL
                     AND brok.code IS NULL
                     AND grag.agent IS NULL 
                     AND grbr.broker IS NOT NULL      THEN grbr.id
           END                                             AS pobr_id
    			,CASE WHEN     trim(agnt.code) IS NOT NULL  THEN trim(agnt.code) 
                                                      ELSE trim(grag.agent)
           END                                    	     	 AS broker_id_no
    			,CASE WHEN     trim(brok.code) IS NOT NULL  THEN trim(brok.code) 
                                                      ELSE trim(grbr.broker)     
           END	                                           AS company_id_no				
    			,CASE WHEN     trim(agnt.code) IS NOT NULL  THEN poba.start_date
                WHEN     trim(grag.agent) IS NOT NULL THEN grag.start_date
                WHEN     trim(brok.code) IS NOT NULL  THEN poba.start_date
                                                      ELSE grbr.start_date 
           END                                      			 AS effective_start_date	
    			,CASE WHEN     trim(agnt.code)IS NOT NULL   THEN nvl(poba.end_date,'31-JAN-3100')
                WHEN     trim(grag.agent) IS NOT NULL THEN nvl(grag.end_date,'31-JAN-3100')
                WHEN     trim(brok.code) IS NOT NULL  THEN nvl(poba.end_date,'31-JAN-3100')
                                                      ELSE nvl(grbr.end_date,'31-JAN-3100') 
           END                                             AS effective_end_date
          ,trim(brok.code)                                 AS poba_broker    
          ,pogr.grac_id                                    AS grac_id    
          ,trim(grbr.broker)                               AS grbr_broker
			FROM pol_policies_v@policies                            poli
      LEFT OUTER 
      JOIN pol_policy_broker_agents_v@policies                poba
        ON     poli.id = poba.poli_id
      LEFT OUTER 
      JOIN pol_brokers_v@policies                             brok
        ON     poba.brkr_id = brok.id 
		  LEFT OUTER 
      JOIN pol_agents_v@policies                              agnt
        ON     poba.agnt_id = agnt.id 
      LEFT OUTER 
      JOIN pol_policy_group_accounts_v@policies               pogr
        ON     poli.id = pogr.poli_id
           AND brok.code IS NULL AND agnt.code IS NULL
		
		  LEFT OUTER 
             JOIN grac_agent@policies                                grag
               ON grag.grac_id = pogr.grac_id AND poba.id IS NULL
			   
           LEFT OUTER 
             JOIN grac_broker@policies                               grbr
               ON grbr.grac_id = pogr.grac_id AND poba.id IS NULL
			         
           JOIN ohi_users_v@policies                                 usrs
            ON usrs.id = poli.last_updated_by
        	    WHERE poli.version = (SELECT MAX(version)
                                      FROM pol_policies_v@policies 
                                     WHERE code = poli.code 
                                       AND status = 'APPROVED')
/*               AND (pogr.id = (SELECT MAX(id) 
                                FROM pol_policy_group_accounts_v@policies
                               WHERE pogr.poli_id = poli_id) 
                                  OR brok.code IS NOT NULL 
                                  OR agnt.code IS NOT NULL)
*/               AND (trim(brok.code) IS NOT NULL 
                 OR trim(agnt.code) IS NOT NULL 
						     OR trim(grag.agent) IS NOT NULL 
						     OR trim(grbr.broker) IS NOT NULL)  
/*						   AND (trim(pogr.poli_id) IS NOT NULL and trim(pogr.grac_id) IS NOT NULL)  
						   AND pogr.start_date IS NOT NULL 
                           AND (grag.start_date IS NULL OR grbr.start_date IS NULL
                           OR (grag.start_date IS NOT NULL AND grbr.start_date IS NOT NULL 
                            AND grag.start_date = grbr.start_date AND (grag.end_date = grbr.end_date) 
                                                   OR (grag.end_date IS NULL AND grbr.end_date IS NULL)))
*/
-- and BROK.ID IS NOT NULL and GRBR.ID IS NOT NULL;
 and poli.code in ('5050391', '5310423', '6106048', '6014976')
                                                   order by poli.code;