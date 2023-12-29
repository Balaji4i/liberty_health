/**
* ----------------------------------------------------------------------
* Change Request: Add Broker Correspondence Option (LS-1427)
*
* Description  : Insert a record into the table so the option becomes available to the users
* Author       : Sarel Eybers
* Date         : 2018-06-08
* Call Syntax  : Just Run (F5) this script in it's etirety
* Steps
*   1) Insert record into the Table
*                */

--  1) Create Tables

Insert into LHHCOM.COMM_HUB_TEMPLATE_TYPE 
           (COMM_HUB_TEMPLATE_TYPE_CODE, COMM_HUB_TEMPLATE_TYPE_DESC,    EFFECTIVE_START_DATE,                 EFFECTIVE_END_DATE,                   LAST_UPDATE_DATETIME, USERNAME) 
 values    ('COM000016',                 'Broker Update Contact Detail', to_date('01/JUN/2018','DD/MON/YYYY'), to_date('31/JAN/3100','DD/MON/YYYY'), SYSDATE,              'LHHCOM');
    
COMMIT;

/