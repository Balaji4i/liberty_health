package com.core.binding;

import oracle.adf.model.bc4j.DataControlFactoryImpl;

public class CoreDataControlFactoryImpl
  extends DataControlFactoryImpl
{
  protected String getDataControlClassName()
  {
    return CoreJUApplicaion.class.getName();
  }
}
