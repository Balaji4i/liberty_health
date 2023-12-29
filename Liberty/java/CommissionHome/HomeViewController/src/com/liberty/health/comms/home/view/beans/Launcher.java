package com.liberty.health.comms.home.view.beans;

import com.core.templates.beans.CoreHomeBean;

import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import javax.faces.application.ViewHandler;
import javax.faces.component.UIViewRoot;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;
import javax.faces.event.ValueChangeEvent;

import oracle.adf.controller.TaskFlowId;
import oracle.adf.view.rich.component.rich.RichDocument;
import oracle.adf.view.rich.component.rich.data.RichTree;
import oracle.adf.view.rich.component.rich.output.RichOutputText;
import oracle.adf.view.rich.event.DialogEvent;
import oracle.adf.view.rich.event.PopupFetchEvent;

import oracle.jbo.Row;
import oracle.jbo.uicli.binding.JUCtrlHierNodeBinding;

import org.apache.myfaces.trinidad.event.DisclosureEvent;
import org.apache.myfaces.trinidad.model.RowKeySet;


public class Launcher extends CoreHomeBean {

    private String taskFlowId = "/WEB-INF/flows/welcome-btf.xml#welcome-btf";
    private String errorFlowId = "/WEB-INF/flows/welcome-btf.xml#welcome-btf";
    private RichOutputText versionNumber;
    private RichDocument document;
    private RichTree menuTree;
    private List list;
    private String localCode = "en_ZA"; //Locale.getDefault().toString();
    private String skin = "fusionFx";
    private RichTree watchListTree;
    private Integer menuWebAppNo;
    private Integer parentWebNo;

    /**
     * Default constructor
     */
    public Launcher() {
        super();
        //        //initially opening the welcome page in a new tab
        //        String title = "Welcome";
        //        boolean exists = isCreated(title);
        //        if (!exists) {
        //            startActivity(title, taskFlowId, true, null);
        //        }
        homeCoreAction(null);
    }

    protected String getMainAreaTaskFlowId() {
        return taskFlowId;
    }


    public TaskFlowId getDynamicTaskFlowId() {
        return TaskFlowId.parse(taskFlowId);
    }

    public void setVersionNumber(RichOutputText versionNumber) {
        this.versionNumber = versionNumber;
    }

    public RichOutputText getVersionNumber() {
        if (versionNumber == null)
            versionNumber = new RichOutputText();
        versionNumber.setValue("NEEDS TO BE CONFIGURED"); //super.getApplicationVersion());
        return versionNumber;
    }

    public void setDocument(RichDocument document) {
        this.document = document;
    }

    public RichDocument getDocument() {
        if (document == null)
            document = new RichDocument();
        document.setTitle("NEEDS TO BE CONFIGURED"); //super.getApplicationName());
        //document.setUncommittedDataWarning("on");
        return document;
    }


    public void MenuActionListener(ActionEvent actionEvent) {

        RowKeySet selection = this.getMenuTree().getSelectedRowKeys();
        Row row = null;
        for (Object facesTreeRowKey : selection) {
            this.getMenuTree().setRowKey(facesTreeRowKey);
            JUCtrlHierNodeBinding root = (JUCtrlHierNodeBinding) this.getMenuTree().getRowData();
            row = root.getRow();

        }
        String url = (String) row.getAttribute("UrlPathName");
        String title = (String) row.getAttribute("MenuItemName");
        System.out.println("url path name "+url);
        System.out.println("title "+title);
        
        
        startActivity(title, url, !isCreated(title), null);
        //launchDynamicActivity(parseTaskFlowUrl(url), title, parseTaskFlowParams(url));
    }

    public void WatchListActionListener(ActionEvent actionEvent) {
        RowKeySet selection = this.getWatchListTree().getSelectedRowKeys();
        Row row = null;

        for (Object facesTreeRowKey : selection) {
            this.getWatchListTree().setRowKey(facesTreeRowKey);
            JUCtrlHierNodeBinding root = (JUCtrlHierNodeBinding) this.getWatchListTree().getRowData();
            row = root.getRow();
        }
        String WebApplObjectNo = row.getAttribute("WebApplObjectNo").toString();
        String menuItemName = (String) row.getAttribute("MenuItemName");
        String url = (String) row.getAttribute("UrlPathName");
        String title = menuItemName;
        Map parameterMap = new HashMap();
        parameterMap.put("webApplObjectNo", WebApplObjectNo);
        parameterMap.put("menuItemName", menuItemName);

        startActivity(title, url, !isCreated(title), parameterMap);
    }

    public void setMenuTree(RichTree menuTree) {
        this.menuTree = menuTree;
    }

    public RichTree getMenuTree() {
        return menuTree;
    }

    public void setList(List list) {
        this.list = list;
    }

    public List getList() {
        return list;
    }

    public void languageValueChangeListener(ValueChangeEvent valueChangeEvent) {
        FacesContext context = FacesContext.getCurrentInstance();
        if (valueChangeEvent.getNewValue()
                            .toString()
                            .compareTo("en_ZA") == 0) {
            Locale english = new Locale("en_ZA");
            context.getViewRoot().setLocale(english);
            this.setLocalCode(Locale.getDefault().toString());
        } 
        
        if (valueChangeEvent.getNewValue()
                            .toString()
                            .compareTo("pt_PT") == 0) {
            Locale portugese = new Locale("pt");
            context.getViewRoot().setLocale(portugese);
            this.setLocalCode(valueChangeEvent.getNewValue().toString());
        }
        
        if (valueChangeEvent.getNewValue()
                            .toString()
                            .compareTo("fr_FR") == 0) {
            Locale french = new Locale("fr");
            context.getViewRoot().setLocale(french);
            this.setLocalCode(valueChangeEvent.getNewValue().toString());
        }
        callOperation("setMenuLocalCode");
        callOperation("setpLocalCode");
    }

    public void setLocalCode(String localCode) {
        this.localCode = localCode;
    }

    public String getLocalCode() {
        return localCode;
    }

    public void setSkin(String skin) {
        this.skin = skin;
    }

    public String getSkin() {
        return skin;
    }

    public void skinValueChangeListener(ValueChangeEvent valueChangeEvent) {
        FacesContext context = FacesContext.getCurrentInstance();
        this.setSkin(valueChangeEvent.getNewValue().toString());
        String viewId = context.getViewRoot().getViewId();
        ViewHandler viewHandler = context.getApplication().getViewHandler();
        UIViewRoot root = viewHandler.createView(context, viewId);
        context.setViewRoot(root);
    }

    public void setWatchListTree(RichTree watchListTree) {
        this.watchListTree = watchListTree;
    }

    public RichTree getWatchListTree() {
        return watchListTree;
    }

    public void menuItemNameDialogListener(DialogEvent dialogEvent) {
       
        if (dialogEvent.getOutcome().ok == dialogEvent.getOutcome()) {
            callOperation("Commit");
            FacesContext context = FacesContext.getCurrentInstance();
            String viewId = context.getViewRoot().getViewId();
            ViewHandler viewHandler = context.getApplication().getViewHandler();
            UIViewRoot root = viewHandler.createView(context, viewId);
            context.setViewRoot(root);
        }
        System.out.println("menuItemNameDialogListener end");
    }

    public void MenuNameChangePopUpFectchListener(PopupFetchEvent popupFetchEvent) {
        System.out.println("MenuNameChangePopUpFectchListener start");
        RowKeySet selection = this.getMenuTree().getSelectedRowKeys();
        Row row = null;
        for (Object facesTreeRowKey : selection) {
            this.getMenuTree().setRowKey(facesTreeRowKey);
            JUCtrlHierNodeBinding root = (JUCtrlHierNodeBinding) this.getMenuTree().getRowData();
            row = root.getRow();

        }
        Integer webNo = (Integer) row.getAttribute("WebApplObjectNo");
        this.setMenuWebAppNo(webNo);
        System.out.println("MenuNameChangePopUpFectchListener start 1");
        callOperation("setUpdateMenuItemViewCriteria");
        System.out.println("MenuNameChangePopUpFectchListener start");
    }

    public void MenuSettingsChangePopUpFectchListener(PopupFetchEvent popupFetchEvent) {
        RowKeySet selection = this.getMenuTree().getSelectedRowKeys();
        Row row = null;
        for (Object facesTreeRowKey : selection) {
            this.getMenuTree().setRowKey(facesTreeRowKey);
            JUCtrlHierNodeBinding root = (JUCtrlHierNodeBinding) this.getMenuTree().getRowData();
            row = root.getRow();

        }
        Integer webNo = (Integer) row.getAttribute("ParentWebApplObjectNo");
        this.setParentWebNo(webNo);
        callOperation("setByParentViewCriteria");
    }

    public void setMenuWebAppNo(Integer menuWebAppNo) {
        this.menuWebAppNo = menuWebAppNo;
    }

    public Integer getMenuWebAppNo() {
        return menuWebAppNo;
    }

    public void setParentWebNo(Integer parentWebNo) {
        this.parentWebNo = parentWebNo;
    }

    public Integer getParentWebNo() {
        return parentWebNo;
    }

    public void watchListMenuDiscloseActionListener(DisclosureEvent disclosureEvent) {
        callOperation("setpLocalCode");
    }
}

