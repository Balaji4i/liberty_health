package com.core.utils;

public class SqlParameter
{
  private String inOutInd;
  private Object value;
  private int dataType;
  private String paramName;
  
  public SqlParameter(String paramName, String inOutInd, Object value, int dataType)
  {
    setInOutInd(inOutInd);
    setValue(value);
    setDataType(dataType);
    setParamName(paramName);
  }
  
  public void setInOutInd(String inOutInd)
  {
    this.inOutInd = inOutInd;
  }
  
  public String getInOutInd()
  {
    return this.inOutInd;
  }
  
  public void setValue(Object value)
  {
    this.value = value;
  }
  
  public Object getValue()
  {
    return this.value;
  }
  
  public void setDataType(int dataType)
  {
    this.dataType = dataType;
  }
  
  public int getDataType()
  {
    return this.dataType;
  }
  
  public void setParamName(String paramName)
  {
    this.paramName = paramName;
  }
  
  public String getParamName()
  {
    return this.paramName;
  }
}
