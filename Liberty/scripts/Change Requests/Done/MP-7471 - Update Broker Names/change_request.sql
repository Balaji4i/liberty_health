/**
* ----------------------------------------------------------------------
* Change Request: MP-7471 - Update Medware Broker Names
*
* Description  : MP-7471 - Update Medware Broker Names
* Author       : Sarel Eybers
* Date         : 2019-09-01
* Call Syntax  : Just Run (F5) this script in it's etirety
*
* Steps
*   1) Display Result Before
*   2) Update 3 Rows
*   3) Display Result After
*   4) Decide to Commit or not
*                                                                         */

-- 1) Display Result Before
select ag_code, ag_name 
    from agent
    where ag_code in ('832000033   ', '832000081   ', '832000082   ');
    
-- 2) Update 3 Rows
update agent
        set ag_name = 'Jobberman LTD TA The African Talent Co'
    where ag_code = '832000033   ';
update agent
        set ag_name = 'Caduceus Business Solutions LTD'
    where ag_code = '832000081   ';
update agent
        set ag_name = 'Purebond Insurance Brokers LTD'
    where ag_code = '832000082   ';

-- 3) Display Result After
select ag_code, ag_name 
    from agent
    where ag_code in ('832000033   ', '832000081   ', '832000082   ');

-- 4) Decide to Commit or not
--commit;