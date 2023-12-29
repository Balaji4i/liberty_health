package com.core.binding;

import oracle.jbo.ApplicationModule;
import oracle.jbo.Transaction;
import oracle.jbo.uicli.binding.JUApplication;

public class CoreJUApplicaion
  extends JUApplication
{
  public void setTransactionModified()
  {
    ApplicationModule vApplicationModule = (ApplicationModule)getDataProvider();
    Transaction vTransaction = vApplicationModule.getTransaction();
    if (vTransaction.isDirty()) {
      super.setTransactionModified();
    }
  }
}
