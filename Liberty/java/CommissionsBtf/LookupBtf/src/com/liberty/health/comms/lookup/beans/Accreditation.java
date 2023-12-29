package com.liberty.health.comms.lookup.beans;

import com.core.generic.CoreActions;

import javax.faces.application.FacesMessage;
import javax.faces.context.FacesContext;

public class Accreditation extends CoreActions {
    public Accreditation() {
        super();
    }

    public String checkAccredExists() {
        System.out.println("checking if a broker already has this accreditation ");
        //first check broker
        String errorMessage = (String) callOperation("checkAccreditationExists");
       
        
        if (errorMessage != null) {
            System.out.println("error message is not null "+errorMessage);
            FacesContext fc = FacesContext.getCurrentInstance();
            FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error",errorMessage.toString());
            fc.addMessage(null, message); 
        } 
        
        System.out.println("checking if a brokerage already has this accreditation ");
        //check brokerage
         errorMessage = (String) callOperation("checkCompanyAccredExists");
        
        
        
        if (errorMessage != null) {
            System.out.println("error message is not null "+errorMessage);
            FacesContext fc = FacesContext.getCurrentInstance();
            FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error",errorMessage.toString());
            fc.addMessage(null, message); 
        } 
        else {
            System.out.println("error message is null - Called Commit ");
            callOperation("Commit");
        }
        
      
        
        return null;
    }
}
