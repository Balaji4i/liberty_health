package com.core.utils;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@Retention(RetentionPolicy.RUNTIME)
public @interface CoreLogging
{
  String teamLeader();
  
  String lastModified();
}
