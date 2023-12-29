package com.core.generic;

import com.core.utils.ADFUtils;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import javax.el.ExpressionFactory;
import javax.el.ValueExpression;
import javax.faces.application.Application;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;
import oracle.adf.model.BindingContext;
import oracle.adf.model.DataControlFrame;
import oracle.adf.model.OperationBinding;
import oracle.adf.model.binding.DCBindingContainer;
import oracle.adf.model.binding.DCIteratorBinding;
import oracle.adf.share.logging.ADFLogger;
import oracle.adf.view.rich.component.rich.input.RichInputListOfValues;
import oracle.adf.view.rich.event.DialogEvent;
import oracle.adf.view.rich.event.DialogEvent.Outcome;
import oracle.adf.view.rich.event.PopupCanceledEvent;
import oracle.adf.view.rich.event.PopupFetchEvent;
import oracle.adf.view.rich.event.ReturnPopupEvent;
import oracle.adf.view.rich.model.ListOfValuesModel;
import oracle.adf.view.rich.model.TableModel;
import oracle.adfinternal.view.faces.model.binding.FacesCtrlHierNodeBinding;
import oracle.adfinternal.view.faces.model.binding.FacesCtrlLOVBinding;
import oracle.binding.BindingContainer;
import oracle.jbo.AttributeDef;
import oracle.jbo.JboException;
import oracle.jbo.Key;
import oracle.jbo.Row;
import oracle.jbo.RowSet;
import oracle.jbo.StructureDef;
import oracle.jbo.VariableValueManager;
import oracle.jbo.ViewCriteria;
import oracle.jbo.ViewCriteriaManager;
import oracle.jbo.ViewObject;
import oracle.jbo.uicli.binding.JUCtrlHierBinding;
import org.apache.myfaces.trinidad.model.CollectionModel;
import org.apache.myfaces.trinidad.model.RowKeySet;

public class CoreActions
{
  protected static ADFLogger _logger = ADFLogger.createADFLogger(CoreActions.class);
  private String createInsertAction = "CreateInsert";
  private String deleteAction = "Delete";
  private String commitAction = "Commit";
  private String rollbackAction = "Rollback";
  private String btfMode;
  
  public void callCreateInsert(ActionEvent actionEvent)
  {
    doCreateInsert();
  }
  
  public void callCreateInsert()
  {
    doCreateInsert();
  }
  
  public void callCreateInsertDetail(ActionEvent actionEvent)
  {
    doCreateInsertDetail(actionEvent);
  }
  
  public void callCreateInsertPopUp(PopupFetchEvent popupFetchEvent)
  {
    if (popupFetchEvent.getLaunchSourceClientId().endsWith("cbpNNew")) {
      doCreateInsert();
    }
  }
  
  public void callDelete(DialogEvent dialogEvent)
  {
    doDelete();
  }
  
  public void callRollback(DialogEvent dialogEvent)
  {
    doRollback();
  }
  
  public void callDeleteCommit(DialogEvent dialogEvent)
  {
    doDeleteCommit();
  }
  
  public void callDeleteDetail(DialogEvent dialogEvent)
  {
    doDeleteDetail(dialogEvent);
  }
  
  public void callCommit(ActionEvent actionEvent)
  {
    doCommit();
  }
  
  public void callCommit()
  {
    doCommit();
  }
  
  public void callCommitPopUp(DialogEvent dialogEvent)
  {
    doCommit();
  }
  
  public void callRollback(ActionEvent actionEvent)
  {
    doRollback();
  }
  
  public void callRollback()
  {
    doRollback();
  }
  
  public void callRollbackPopUp(PopupCanceledEvent popupCanceledEvent)
  {
    doRollback();
  }
  
  private void doCreateInsert()
  {
    try
    {
      callOperation(getCreateInsertAction());
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }
  
  private void doCreateInsertDetail(ActionEvent actionEvent)
  {
    try
    {
      doCommit();
      callOperation("CreateInsertDetail");
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }
  
  private void doDeleteCommit()
  {
    try
    {
      doDelete();
      doCommit();
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }
  
  private void doDelete()
  {
    try
    {
      callOperation(getDeleteAction());
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }
  
  private void doDeleteDetail(DialogEvent dialogEvent)
  {
    try
    {
      callOperation("DeleteDetail");
      callOperation("Commit");
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }
  
  private void doCommit()
  {
    try
    {
      callOperation(getCommitAction());
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }
  
  private void doRollback()
  {
    try
    {
      callOperation(getRollbackAction());
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }
  
  public Object callOperation(String operationToDo)
  {
    Object ret = null;
    if (operationToDo != null)
    {
      DCBindingContainer bindings = ADFUtils.getDCBindingContainer();
      
      OperationBinding operation = (OperationBinding)bindings.getOperationBinding(operationToDo);
      if (operation != null) {
        ret = operation.execute();
      } else {
        _logger.info("OPERATION " + operationToDo + " IS MISSING");
      }
    }
    return ret;
  }
  
  public String getCreateMode()
  {
    DCBindingContainer bindings = ADFUtils.getDCBindingContainer();
    OperationBinding operation = (OperationBinding)bindings.getOperationBinding("getRowStatus");
    
    return (String)operation.execute();
  }
  
  public String getCreateModeDetail()
  {
    DCBindingContainer bindings = ADFUtils.getDCBindingContainer();
    OperationBinding operation = (OperationBinding)bindings.getOperationBinding("getRowStatusDetail");
    
    return (String)operation.execute();
  }
  
  public String getCellColor()
  {
    FacesContext ctx = FacesContext.getCurrentInstance();
    ExpressionFactory ef = ctx.getApplication().getExpressionFactory();
    
    ValueExpression ve = ef.createValueExpression(ctx.getELContext(), "#{row}", FacesCtrlHierNodeBinding.class);
    
    FacesCtrlHierNodeBinding node = (FacesCtrlHierNodeBinding)ve.getValue(ctx.getELContext());
    if (node == null) {
      return null;
    }
    Row row = node.getRow();
    
    BindingContainer bc = ADFUtils.getBindingContainer();
    OperationBinding ob = (OperationBinding)bc.getOperationBinding("getRowStatusColor");
    ob.getParamsMap().put("p0", row);
    String status = (String)ob.execute();
    if (((status != null) && (status.equals("Modified"))) || ((status != null) && (status.equals("New")))) {
      return "background-color:bisque;font-weight:bolder; font-style:italic;";
    }
    return null;
  }
  
  public Row cloneCurrentRow(RowSet rs)
  {
    Row currentRow = rs.getCurrentRow();
    Row newRow = rs.createRow();
    
    StructureDef def = newRow.getStructureDef();
    AttributeDef[] attrs = def.getAttributeDefs();
    
    int j = 0;
    for (int numAttrs = attrs.length; j < numAttrs; j++) {
      if (!attrs[j].isPrimaryKey())
      {
        String attrName = attrs[j].getName();
        if (!attrName.equals("LastUpdateDate")) {
          if (!attrName.equals("Username")) {
            newRow.setAttribute(j, currentRow.getAttribute(j));
          }
        }
      }
    }
    return newRow;
  }
  
  public void setCreateInsertAction(String createInsertAction)
  {
    this.createInsertAction = createInsertAction;
  }
  
  public String getCreateInsertAction()
  {
    return this.createInsertAction;
  }
  
  public void setDeleteAction(String deleteAction)
  {
    this.deleteAction = deleteAction;
  }
  
  public String getDeleteAction()
  {
    return this.deleteAction;
  }
  
  public void setCommitAction(String commitAction)
  {
    this.commitAction = commitAction;
  }
  
  public String getCommitAction()
  {
    return this.commitAction;
  }
  
  public void setRollbackAction(String rollbackAction)
  {
    this.rollbackAction = rollbackAction;
  }
  
  public String getRollbackAction()
  {
    return this.rollbackAction;
  }
  
  public BindingContainer getBindings()
  {
    return BindingContext.getCurrent().getCurrentBindingsEntry();
  }
  
  public String getEntityState()
  {
    BindingContainer bc = getBindings();
    OperationBinding ob = (OperationBinding)bc.getOperationBinding("getRowStatus");
    return (String)ob.execute();
  }
  
  public Boolean getTransactionState()
  {
    BindingContext bc = BindingContext.getCurrent();
    String currentDataControlFrame = bc.getCurrentDataControlFrame();
    Boolean txnDirty = Boolean.valueOf(false);
    txnDirty = Boolean.valueOf(bc.findDataControlFrame(currentDataControlFrame).isTransactionDirty());
    _logger.info("txnDirty: " + txnDirty);
    return txnDirty;
  }
  
  public void popupFetchListener(PopupFetchEvent popupFetchEvent)
  {
    if (popupFetchEvent.getLaunchSourceClientId().contains("cbInsert")) {
      callCreateInsert();
    }
  }
  
  public void popupCancelListener(PopupCanceledEvent popupCanceledEvent)
  {
    callRollbackPopUp(popupCanceledEvent);
  }
  
  public void okCancelDialogListener(DialogEvent dialogEvent)
  {
    if (dialogEvent.getOutcome().name().equals("ok")) {
      callCommit();
    } else if (dialogEvent.getOutcome().name().equals("cancel")) {
      callRollback();
    }
  }
  
  public void deleteOkCancelDialogListener(DialogEvent dialogEvent)
  {
    if (dialogEvent.getOutcome().name().equals("ok")) {
      callDeleteCommit(dialogEvent);
    }
  }
  
  public Object getLovPopupDescription(String descAttribute, ReturnPopupEvent returnPopupEvent)
  {
    if ((returnPopupEvent.getSource() instanceof RichInputListOfValues))
    {
      RichInputListOfValues riLov = (RichInputListOfValues)returnPopupEvent.getSource();
      ListOfValuesModel lovModel = riLov.getModel();
      CollectionModel colModel = lovModel.getTableModel().getCollectionModel();
      
      JUCtrlHierBinding treeBinding = (JUCtrlHierBinding)colModel.getWrappedData();
      
      RowKeySet rks = (RowKeySet)returnPopupEvent.getReturnValue();
      List tableRowKey = (List)rks.iterator().next();
      DCIteratorBinding dciter = treeBinding.getDCIteratorBinding();
      
      Key key = (Key)tableRowKey.get(0);
      Row rw = dciter.findRowByKeyString(key.toStringFormat(true));
      try
      {
        return rw.getAttribute(descAttribute);
      }
      catch (Exception e)
      {
        throw new JboException("Core Actions : " + e.getMessage());
      }
    }
    throw new JboException("Core Actions : Invalid component type. Expecting oracle.adf.view.rich.component.rich.input.RichInputListOfValues");
  }
  
  public void syncroniseViewObject(String lovAttributeName, String viewCriteriaName, String variableName, Object variableValue)
  {
    String[] var = { variableName };
    Object[] val = { variableValue };
    
    syncroniseViewObject(lovAttributeName, viewCriteriaName, var, val);
  }
  
  public void syncroniseViewObject(String lovAttributeName, String viewCriteriaName, String[] variableNames, Object[] variableValues)
  {
    DCBindingContainer dc = (DCBindingContainer)BindingContext.getCurrent().getCurrentBindingsEntry();
    FacesCtrlLOVBinding lov = (FacesCtrlLOVBinding)dc.get(lovAttributeName);
    ViewObject vo = lov.getListIterBinding().getViewObject();
    ViewCriteriaManager vcm = vo.getViewCriteriaManager();
    ViewCriteria vc = vcm.getViewCriteria(viewCriteriaName);
    VariableValueManager vm = vo.ensureVariableManager();
    if (variableNames.length != variableValues.length) {
      throw new JboException("Core Actions : Invalid Matching Elements. Variable Names and Variable Values must have matching elements");
    }
    for (int foo = 0; foo < variableNames.length; foo++) {
      vm.setVariableValue(variableNames[foo], variableValues[foo]);
    }
    vo.applyViewCriteria(vc);
    lov.getListIterBinding().getViewObject().executeQuery();
  }
  
  public void setBtfMode(String btfMode)
  {
    this.btfMode = btfMode;
  }
  
  public String getBtfMode()
  {
    return this.btfMode;
  }
  
  public void initEditMode()
  {
    setBtfMode("Edit");
  }
  
  public void initCreateMode()
  {
    setBtfMode("Create");
  }
}
