package com.core.reports;

import java.io.PrintStream;
import java.util.ArrayList;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;
import java.util.Vector;
import javax.naming.NamingEnumeration;
import javax.naming.directory.Attribute;
import javax.naming.directory.Attributes;
import javax.naming.directory.DirContext;
import javax.naming.directory.InitialDirContext;
import javax.naming.directory.SearchControls;
import javax.naming.directory.SearchResult;
import oracle.adf.share.ADFContext;
import oracle.adf.share.logging.ADFLogger;
import oracle.adf.share.security.SecurityContext;

public class ActiveDirectoryReader
{
  protected static ADFLogger _logger = ADFLogger.createADFLogger(ActiveDirectoryReader.class);
  private DirContext dirContext = null;
  private String context = "";
  
  public static String replaceAll(String target, String from, String to)
  {
    int start = target.indexOf(from);
    if (start == -1) {
      return target;
    }
    int lf = from.length();
    char[] targetChars = target.toCharArray();
    StringBuffer buffer = new StringBuffer();
    int copyFrom = 0;
    while (start != -1)
    {
      buffer.append(targetChars, copyFrom, start - copyFrom);
      buffer.append(to);
      copyFrom = start + lf;
      start = target.indexOf(from, copyFrom);
    }
    buffer.append(targetChars, copyFrom, targetChars.length - copyFrom);
    return buffer.toString();
  }
  
  public ActiveDirectoryReader()
  {
    initializeAD(Constants.LDAP_DC_STRING);
  }
  
  public ActiveDirectoryReader(String context)
  {
    initializeAD(context);
  }
  
  private void initializeAD(String context)
  {
    this.context = context;
    getActiveDirectoryContext();
  }
  
  private void getActiveDirectoryContext()
  {
    Hashtable environment = new Hashtable();
    
    environment.put("java.naming.factory.initial", "com.sun.jndi.ldap.LdapCtxFactory");
    environment.put("java.naming.provider.url", "ldap://" + Constants.LDAP_SERVER_NAME);
    
    environment.put("java.naming.security.authentication", Constants.LDAP_AUTHENTICATION);
    environment.put("java.naming.security.principal", Constants.LDAP_USERNAME);
    environment.put("java.naming.security.credentials", Constants.LDAP_PASSWORD);
    try
    {
      this.dirContext = new InitialDirContext(environment);
    }
    catch (Exception ex)
    {
      ex.printStackTrace();
    }
  }
  
  public String getFullNameBySamAccountName(String networkUsername)
    throws Exception
  {
    return getFullNameBySamAccountName(networkUsername, this.context);
  }
  
  public String getFullNameBySamAccountName(String networkUsername, String context)
    throws Exception
  {
    String dn = getDnBySamAccountName(networkUsername, context);
    String fullname = dn;
    if (dn == null)
    {
      _logger.info("WARNING: Cound not find: \"" + networkUsername + "\" in ActiveDirectory");
      fullname = networkUsername;
    }
    else if (dn.contains(","))
    {
      String[] dnSplit = dn.split(",");
      fullname = replaceAll(dnSplit[0], "CN=", "");
    }
    return fullname;
  }
  
  public String getDnBySamAccountName(String networkUsername)
    throws Exception
  {
    return getDnBySamAccountName(networkUsername, this.context);
  }
  
  public String getDnBySamAccountName(String networkUsername, String context)
    throws Exception
  {
    try
    {
      SearchControls controls = new SearchControls();
      controls.setSearchScope(2);
      
      String searchString = "(&(objectClass=person)(!(objectClass=computer))(sAMAccountName=" + networkUsername + "))";
      
      NamingEnumeration enumer = this.dirContext.search(context, searchString, controls);
      if (enumer != null) {
        return ((SearchResult)enumer.next()).getName();
      }
    }
    catch (NullPointerException e)
    {
      e.printStackTrace();
    }
    catch (Exception e)
    {
      System.err.println(e);
    }
    return null;
  }
  
  public Vector getGroupList(String dn)
    throws Exception
  {
    return getGroupList(dn, this.context);
  }
  
  public Vector getGroupList(String dn, String context)
    throws Exception
  {
    Vector ret = new Vector();
    if (dn != null)
    {
      Attributes attrs = this.dirContext.getAttributes(dn);
      
      Attribute groupMembers = attrs.get("memberOf");
      if (groupMembers != null) {
        for (int i = 0; i < groupMembers.size(); i++) {
          ret.add(groupMembers.get(i).toString());
        }
      }
    }
    return ret;
  }
  
  public List getPrintersByNetworkId(String userId)
    throws Exception
  {
    List printers = new ArrayList();
    String fullName = getDnBySamAccountName(userId, this.context);
    Vector vector = getGroupList(fullName + "," + this.context);
    
    Iterator iterator = vector.iterator();
    while (iterator.hasNext())
    {
      String group = (String)iterator.next();
      if (group.toLowerCase().contains("OU=printers".toLowerCase()))
      {
        String printerName = group;
        if (group.contains(","))
        {
          String[] dnSplit = group.split(",");
          printerName = replaceAll(dnSplit[0], "CN=", "");
        }
        printers.add(printerName);
      }
    }
    return printers;
  }
  
  public boolean userInRole(String role)
  {
    role = String.format(Constants.LDAP_PARTIAL_DN, new Object[] { role });
    ArrayList<String> path = new ArrayList();
    for (String r : ADFContext.getCurrent().getSecurityContext().getUserRoles())
    {
      r = String.format(Constants.LDAP_PARTIAL_DN, new Object[] { r });
      if (r.equals(role)) {
        _logger.info("The user is connected to " + role + " directly");
      }
      path.add(r);
      if (userInRole(r, path, role))
      {
        _logger.info("The user is connected to " + role + " via the following path");
        for (String p : path) {
          _logger.info(p);
        }
        return true;
      }
      path.remove(path.size() - 1);
    }
    return false;
  }
  
  private boolean userInRole(String dn, ArrayList<String> path, String roleToCheck)
  {
    try
    {
      List<String> v = getGroupList(dn);
      for (String i : v)
      {
        path.add(i);
        if (i.equals(roleToCheck)) {
          return true;
        }
        if (userInRole(i, path, roleToCheck)) {
          return true;
        }
        path.remove(i);
      }
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
    return false;
  }
}
