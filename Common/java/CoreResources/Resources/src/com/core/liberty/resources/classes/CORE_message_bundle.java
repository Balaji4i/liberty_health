package com.core.liberty.resources.classes;

import java.util.ListResourceBundle;

public class CORE_message_bundle extends ListResourceBundle {

    private static final Object[][] sMessageStrings = new String[][] { 
           { "25013", "Record Already Exists for this effective Start Date - Duplicate Record" },
           { "20991", "Brokerage, Group, Country combination already exists for this date range" },
           { "20992", "Please ensure that the effective end date is equal to or after the effective start date" },
           { "ADDRESS_TYPE_PK","Address Type Already Exists"},
           { "ADDRESS_DESC_UNQ","Please enter a unique Address Description"} ,  
           { "COMPANY_ADDRESS_PK","Please change the effective start date as a record already exists for this date Range"},
           { "BROKER_FUNCTION_PK","You cannot enter this information, as it overlaps with another record"}
    };

    public CORE_message_bundle() {
        super();
    }


    @Override
    protected Object[][] getContents() {
        return sMessageStrings;
    }
}
