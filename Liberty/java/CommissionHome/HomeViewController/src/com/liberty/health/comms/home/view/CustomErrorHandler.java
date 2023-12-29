package com.liberty.health.comms.home.view;

import oracle.adf.model.binding.DCBindingContainer;
import oracle.adf.model.binding.DCErrorHandlerImpl;  
import java.sql.SQLIntegrityConstraintViolationException;
  
import java.sql.SQLException;

import javax.faces.application.FacesMessage;
import javax.faces.context.FacesContext;

import oracle.adf.model.BindingContext;  
import oracle.adf.model.RegionBinding;
  
import oracle.adf.model.binding.DCBindingContainer;  
  
import oracle.adf.model.binding.DCErrorHandlerImpl;

import oracle.adf.model.binding.DCErrorMessage;

import oracle.adf.view.rich.util.FacesMessageUtils;

import oracle.jbo.DMLConstraintException;
import oracle.jbo.JboException;  


public class CustomErrorHandler extends DCErrorHandlerImpl {
    public CustomErrorHandler() {
        super(true);
    }
    

    @Override
    public void reportException(DCBindingContainer dCBindingContainer,
                                Exception exception) {

        if (exception instanceof JboException) {
            //By default all exception which are coming from Model layer all are instance of JboException
            //here just i am try to skip the exception to report to super class which is DCErrorHandlerInpl
            //we can write our own logic
            // if the exception came of model then it always go through this if condition
        //   System.out.println("JBO VALUE message IS "+exception.getMessage());
        //    System.out.println("JBO VALUE cause IS "+exception.getCause());
           FacesContext.getCurrentInstance().addMessage("Message",new FacesMessage(FacesMessage.SEVERITY_ERROR,exception.getMessage(),null));
           
          super.reportException(dCBindingContainer, exception);
        } else {
         //   System.out.println("****** in jbo exception - 2");
            super.reportException(dCBindingContainer, exception);
        }

    }

    private void disableAppendCodes(Exception ex) {
        if (ex instanceof JboException) {
            JboException jboEx = (JboException)ex;
            jboEx.setAppendCodes(false);
            Object[] detailExceptions = jboEx.getDetails();
            if ((detailExceptions != null) && (detailExceptions.length > 0)) {
                for (int z = 0, numEx = detailExceptions.length; z < numEx;
                     z++) {
                    disableAppendCodes((Exception)detailExceptions[z]);
                }
            }
        }
    }

    @Override
    public DCErrorMessage getDetailedDisplayMessage(BindingContext bindingContext,
                                                    RegionBinding regionBinding,
                                                    Exception exception) {
        System.out.println("****** in dc error message");
        return super.getDetailedDisplayMessage(bindingContext, regionBinding,
                                               exception);
    }

    @Override
    public String getDisplayMessage(BindingContext bindingContext,
                                    Exception exception) {
        System.out.println("****** in get display message");
        return super.getDisplayMessage(bindingContext, exception);
    }

    @Override
    protected boolean skipException(Exception exception) {
        System.out.println("****** in skip exception"); 
        return super.skipException(exception);
    }

}
