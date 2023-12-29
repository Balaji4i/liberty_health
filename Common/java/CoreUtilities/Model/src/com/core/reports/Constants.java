package com.core.reports;

public class Constants
{
  public static String LDAP_SERVER_NAME = "servername:389";
  public static String LDAP_NAME = "OIDSYNC";
  public static String LDAP_USERNAME = "LIBERTY\\" + LDAP_NAME;
  public static String LDAP_PASSWORD = "odi_Myn@u";
  public static String LDAP_DC_STRING = "DC=liberty,DC=com";
  public static String LDAP_AUTHENTICATION = "simple";
  public static String LDAP_PARTIAL_DN = "CN=%s,OU=Groups,OU=LIBERTY,OU=SSO,DC=liberty,DC=com";
}
