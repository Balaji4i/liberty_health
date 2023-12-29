package com.core.model.services.classes;

import com.core.utils.SqlParameter;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import oracle.jbo.domain.Number;
import oracle.jbo.server.DBTransaction;

public class CoreBatchApplicationModuleImpl
  extends CoreApplicationModuleImpl
{
  private String jobType;
  private String boxName;
  private String jobName;
  private String description;
  private String systemName;
  private String owner;
  private String outPath;
  private String queueName;
  private String profile;
  private String command;
  private String commandParam;
  private String autoHold;
  private String autoDelete;
  private String dateConditions;
  private String daysOfWeek;
  private String startMins;
  private String startTimes;
  private String condition;
  private String additional;
  private String runJac;
  private String sidName;
  private Number priority;
  private Number jobLoad;
  
  public CoreBatchApplicationModuleImpl()
  {
    resetParameters();
  }
  
  public void resetParameters()
  {
    this.jobType = "c";
    this.boxName = null;
    this.jobName = null;
    this.description = null;
    this.systemName = null;
    this.owner = null;
    this.outPath = null;
    this.queueName = null;
    this.profile = null;
    this.command = null;
    this.commandParam = null;
    this.autoHold = "n";
    this.autoDelete = "y";
    this.dateConditions = "n";
    this.daysOfWeek = null;
    this.startMins = null;
    this.startTimes = null;
    this.condition = null;
    this.additional = null;
    this.runJac = "y";
    this.sidName = null;
    this.priority = new Number(50);
    this.jobLoad = new Number(5);
  }
  
  public ArrayList<Object> submitAutosysBatch()
  {
    ArrayList<SqlParameter> parameters = new ArrayList();
    
    parameters.add(new SqlParameter("pv_jobtype", "in", this.jobType, 12));
    parameters.add(new SqlParameter("pv_box_name", "in", this.boxName, 12));
    parameters.add(new SqlParameter("pv_job_name", "in", this.jobName, 12));
    parameters.add(new SqlParameter("pv_description", "in", this.description, 12));
    parameters.add(new SqlParameter("pv_system_name", "in", this.systemName, 12));
    parameters.add(new SqlParameter("pv_owner", "in", this.owner, 12));
    parameters.add(new SqlParameter("pv_out_path", "in", this.outPath, 12));
    parameters.add(new SqlParameter("pv_queue_name", "in", this.queueName, 12));
    parameters.add(new SqlParameter("pv_profile", "in", this.profile, 12));
    parameters.add(new SqlParameter("pv_command", "in", this.command, 12));
    parameters.add(new SqlParameter("pv_command_param", "in", this.commandParam, 12));
    parameters.add(new SqlParameter("pv_auto_hold", "in", this.autoHold, 12));
    parameters.add(new SqlParameter("pv_auto_delete", "in", this.autoDelete, 12));
    parameters.add(new SqlParameter("pv_date_conditions", "in", this.dateConditions, 12));
    parameters.add(new SqlParameter("pv_days_of_week", "in", this.daysOfWeek, 12));
    parameters.add(new SqlParameter("pv_start_mins", "in", this.startMins, 12));
    parameters.add(new SqlParameter("pv_start_times", "in", this.startTimes, 12));
    parameters.add(new SqlParameter("pv_condition", "in", this.condition, 12));
    parameters.add(new SqlParameter("pv_additional", "in", this.additional, 12));
    parameters.add(new SqlParameter("pv_run_jac", "in", this.runJac, 12));
    parameters.add(new SqlParameter("pv_sid_name", "in", this.sidName, 12));
    parameters.add(new SqlParameter("pn_priority", "in", this.priority, 4));
    parameters.add(new SqlParameter("pn_jobload", "in", this.jobLoad, 4));
    
    return callStoredObject("submit_autosys_batch", parameters, false);
  }
  
  public void setJobType(String jobType)
  {
    this.jobType = jobType;
  }
  
  public String getJobType()
  {
    return this.jobType;
  }
  
  public void setBoxName(String boxName)
  {
    this.boxName = boxName;
  }
  
  public String getBoxName()
  {
    return this.boxName;
  }
  
  public void setJobName(String jobName, Boolean unique)
  {
    String uniqueStr = "n";
    if (unique.booleanValue()) {
      uniqueStr = "y";
    }
    String sql = "select get_autosys_job_name('" + jobName + "','j', '" + uniqueStr + "') from dual";
    Statement stat = getDBTransaction().createStatement(1);
    try
    {
      ResultSet rs = stat.executeQuery(sql);
      if (rs.next()) {
        jobName = rs.getString(1);
      }
      rs.close();
    }
    catch (SQLException e)
    {
      e.printStackTrace();
    }
    this.jobName = jobName;
  }
  
  public String getJobName()
  {
    return this.jobName;
  }
  
  public void setDescription(String description)
  {
    this.description = description;
  }
  
  public String getDescription()
  {
    return this.description;
  }
  
  public void setSystemName(String systemName)
  {
    this.systemName = systemName;
  }
  
  public String getSystemName()
  {
    return this.systemName;
  }
  
  public void setOwner(String owner)
  {
    this.owner = owner;
  }
  
  public String getOwner()
  {
    return this.owner;
  }
  
  public void setOutPath(String outPath)
  {
    this.outPath = outPath;
  }
  
  public String getOutPath()
  {
    return this.outPath;
  }
  
  public void setQueueName(String queueName)
  {
    this.queueName = queueName;
  }
  
  public String getQueueName()
  {
    return this.queueName;
  }
  
  public void setProfile(String profile)
  {
    this.profile = profile;
  }
  
  public String getProfile()
  {
    return this.profile;
  }
  
  public void setCommand(String command)
  {
    this.command = command;
  }
  
  public String getCommand()
  {
    return this.command;
  }
  
  public void setCommandParam(String commandParam)
  {
    this.commandParam = commandParam;
  }
  
  public String getCommandParam()
  {
    return this.commandParam;
  }
  
  public void setAutoHold(String autoHold)
  {
    this.autoHold = autoHold;
  }
  
  public String getAutoHold()
  {
    return this.autoHold;
  }
  
  public void setAutoDelete(String autoDelete)
  {
    this.autoDelete = autoDelete;
  }
  
  public String getAutoDelete()
  {
    return this.autoDelete;
  }
  
  public void setDateConditions(String dateConditions)
  {
    this.dateConditions = dateConditions;
  }
  
  public String getDateConditions()
  {
    return this.dateConditions;
  }
  
  public void setDaysOfWeek(String daysOfWeek)
  {
    this.daysOfWeek = daysOfWeek;
  }
  
  public String getDaysOfWeek()
  {
    return this.daysOfWeek;
  }
  
  public void setStartMins(String startMins)
  {
    this.startMins = startMins;
  }
  
  public String getStartMins()
  {
    return this.startMins;
  }
  
  public void setStartTimes(String startTimes)
  {
    this.startTimes = startTimes;
  }
  
  public String getStartTimes()
  {
    return this.startTimes;
  }
  
  public void setCondition(String condition)
  {
    this.condition = condition;
  }
  
  public String getCondition()
  {
    return this.condition;
  }
  
  public void setAdditional(String additional)
  {
    this.additional = additional;
  }
  
  public String getAdditional()
  {
    return this.additional;
  }
  
  public void setRunJac(String runJac)
  {
    this.runJac = runJac;
  }
  
  public String getRunJac()
  {
    return this.runJac;
  }
  
  public void setSidName(String sidName)
  {
    this.sidName = sidName;
  }
  
  public String getSidName()
  {
    return this.sidName;
  }
  
  public void setPriority(Number priority)
  {
    this.priority = priority;
  }
  
  public Number getPriority()
  {
    return this.priority;
  }
  
  public void setJobLoad(Number jobLoad)
  {
    this.jobLoad = jobLoad;
  }
  
  public Number getJobLoad()
  {
    return this.jobLoad;
  }
}
