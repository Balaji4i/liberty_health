
package com.core.templates.beans;


import com.core.generic.CoreActions;
import com.core.utils.JSFUtils;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;

import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;

import javax.servlet.http.HttpServletRequest;

import oracle.adf.controller.TaskFlowId;
import oracle.adf.model.BindingContext;
import oracle.adf.share.ADFContext;
import oracle.adf.view.rich.component.rich.nav.RichCommandNavigationItem;
import oracle.adf.view.rich.component.rich.nav.RichNavigationPane;
import oracle.adf.view.rich.event.ItemEvent;

import oracle.binding.BindingContainer;

import oracle.ui.pattern.dynamicShell.Tab;
import oracle.ui.pattern.dynamicShell.TabContext;

import org.apache.myfaces.trinidad.render.ExtendedRenderKitService;
import org.apache.myfaces.trinidad.util.Service;


public abstract class CoreHomeBean extends CoreActions {

    private Boolean taskFlowViewable;
    private TabContext tabContext = null;

    public CoreHomeBean() {
        super();
        // IMPORTANT nav pane in super class must be instantiated
        TabContext tc = getTabContext();
         
        if (tc != null) {
            tc.setTabsNavigationPane(new RichNavigationPane());
        }

        if (Level.INFO.equals(_logger.getLevel())) {
            ADFContext adfContext = ADFContext.getCurrent();

            if (adfContext.getSecurityContext().isAnyoneEnabled()) {
                _logger.info("Principal = " + adfContext.getSecurityContext().getUserPrincipal());
                _logger.info("Roles = " + adfContext.getSecurityContext().getUserRoles().length);
            }

            for (String role : adfContext.getSecurityContext().getUserRoles()) {
                _logger.info("Role = " + role);
            }
        }
    }

    public void setTabContext(TabContext tabContext) {
        this.tabContext = tabContext;
    }

    public TabContext getTabContext() {
        if (tabContext == null) {
            tabContext = TabContext.getCurrentInstance();
        }
        return tabContext;
    }

    protected abstract String getMainAreaTaskFlowId();

    // TODO Add javadoc comments
    public void handleCloseTabItem(ItemEvent itemEvent) {
        if (itemEvent.getType().equals(ItemEvent.Type.remove)) {
            closeTab(itemEvent.getSource());
        }
    }

    /**
     * Used to close the a specific tab
     **/
    public void closeActivity(ActionEvent e) {
        closeTab(e.getSource());
    }

    /**
     * Used to close the current tab
     **/
    public void closeCurrentActivity() {
        TabContext tc = getTabContext();

        if (tc != null) {
            tc.removeCurrentTab();
        }
    }

    // TODO Add javadoc comments
    public Tab getSelectedTab() {
        TabContext tc = getTabContext();

        if (tc != null) {
            int index = tc.getSelectedTabIndex();
            if (index != -1)
                return tc.getTabs().get(index);
        }
        return null;
    }
    // TODO Add javadoc comments
    public void makeTabDirty(ActionEvent actionEvent) {
        TabContext tc = getTabContext();

        if (tc != null) {
            Tab tab = getSelectedTab();
            tab.setDirty(true);
        } else {
            _logger.warning("TabContext is null");
        }
    }

    //TODO add javadoc
    public void homeCoreAction(ActionEvent ev) {
        String title = "Welcome";
        boolean exists = isCreated(title);

        TabContext tc = TabContext.getCurrentInstance();
        if (tc == null) {
            exists = false;
        }

        _logger.info(">> isCreated: " + exists);
        if (!exists) {
            startActivity(title, getMainAreaTaskFlowId(), true, null);
        }
    }
    //TODO add javadoc
    public void homeAction(String title) {
        boolean exists = isCreated(title);

        TabContext tc = TabContext.getCurrentInstance();
        if (tc == null) {
            exists = false;
        }

        _logger.info(">> isCreated: " + exists);
        if (!exists) {
            startActivity(title, getMainAreaTaskFlowId(), true, null);
        }
    }

    protected void startActivity(String title, String taskid, boolean isNew, Map<String, Object> parameters) {
        startActivity(null, title, taskid, isNew, parameters);
    }
    //TODO add javadoc
    protected void startActivity(TabContext tc, String title, String taskid, boolean isNew,
                                 Map<String, Object> parameters) {
        if (tc == null) {
            tc = getTabContext();
        }

        _logger.info("tabContext: " + tc);
        _logger.info("taskId: " + taskid);

        try {
            if ((taskid != null) &&
                ((taskid.toUpperCase().startsWith("HTTP://")) || (taskid.toUpperCase().startsWith("HTTPS://")))) {
                launchURL(taskid);
            } else {
                Integer noOfTabs =  tc.getNumberOfTabs();
   
                if (isNew) {
                    _logger.info("> addTab: " + taskid);
                    tc.addTab(title, taskid, parameters);
                    _logger.info("Tab Added!!!");
                } else {
                    _logger.info("> addOrSelectTab: " + taskid);
                    tc.addOrSelectTab(title, taskid, parameters);
                    _logger.info("Tab Added or Selected!!!");
                }
            }
        } catch (NullPointerException e) {
            _logger.warning("NullPointerException thrown from TabContext class - not critical");
            _logger.warning("tabcontext: " + tc);
        } catch (TabContext.TabOverflowException e) {
            e.printStackTrace();
            e.handleDefault();
        } catch (Exception ex) {
            _logger.severe(ex);
            ex.printStackTrace();
        }
    }
    //TODO add javadoc
    public boolean isCreated(String title) {
        boolean exists = false;
        try {
            TabContext tc = getTabContext();

            if (tc != null) {
                List<Tab> list = tc.getTabs();
                for (Tab tab : list) {
                    if (tab != null) {
                        if (tab.getTitle() != null) {
                            if (tab.getTitle().equals(title)) {
                                exists = true;
                                tab.setActive(true);
                                break;
                            }
                        }
                    }
                }
            }
        } catch (Exception ex) {
            _logger.severe(ex);
        }
        return exists;
    }

    /**
     * Example method to call a single instance task flow. Note the boolean
     * to create another tab instance is set to false. The taskflow ID is used
     * to track whether to create a new tab or select an existing one.
     */
    public void launchDynamicActivity(String flow, String title, Map<String, Object> parameters) {
        if (flow != null) {
            _logger.info("Flow & title = " + flow + "  " + title);
            _logger.info("Is new = " + !isCreated(title));
            startActivity(title, flow, !isCreated(title), parameters);
        }
    }

    public void launchDynamicActivityNOT(String flow, String title, Map<String, Object> parameters) {
        __launchDynamicActivity(flow, title, parameters, !isCreated(title));
    }

    public void launchDynamicActivity(String flow, String title, Map<String, Object> parameters, boolean isNew) {
        __launchDynamicActivity(flow, title, parameters, isNew);
    }

    private void __launchDynamicActivity(String flow, String title, Map<String, Object> parameters, boolean isNew) {
        if (flow != null) {
            _logger.info("Flow & title = " + flow + "  " + title);
            _logger.info("Is new = " + isNew);

            startActivity(title, flow, isNew, parameters);
        }
    }


    /**
     * Launch a brower window and go to a specific URL
     *
     * @param url - URL to open
     */
    private void launchURL(String url) {
        FacesContext fc = FacesContext.getCurrentInstance();
        ExtendedRenderKitService service =
            (ExtendedRenderKitService) Service.getRenderKitService(fc, ExtendedRenderKitService.class);
        service.addScript(fc, "window.open('" + url + "', '_blank')");
    }


    public BindingContainer getBindings() {
        return BindingContext.getCurrent().getCurrentBindingsEntry();
    }

    // TODO Add javadoc comments
    public TaskFlowId getDynamicTaskFlowId() {
        return TaskFlowId.parse(getMainAreaTaskFlowId());
    }


    /**
     * Get the name of the application server hosting the application
     *
     * @return the server's name, eg. pitwadfd1
     */
    public String getApplicationServerName() {
        FacesContext fctx = FacesContext.getCurrentInstance();
        HttpServletRequest request = (HttpServletRequest) fctx.getExternalContext().getRequest();
        _logger.info("Server name: " + request.getServerName());
        _logger.info("Server port: " + request.getServerPort());
        return request.getServerName();
    }

    public Boolean getTaskFlowViewable() {
        return isTaskFlowViewable();
    }

    /**
     * Check if a taskflow is viewable based on the security.
     * Paramaters passed in as part of the taskflow URL will be removed
     * @return Boolean True if viewable, False if not viewable
     */
    public boolean isTaskFlowViewable() {
        boolean hasPermission = false;
        String taskflowUrl = null;
        Long typeNo = null;

        //Set default expression which will enable link if taskflow is viewable and when the menu type is 3
        String expression; // = "#{securityContext.taskflowViewable[node.UrlPathName] ? true : (node.ObjectTypeNo == 3 ? false : true)}";
        // expression = "#{node.ObjectTypeNo != 3 ? true : (!securityContext.taskflowViewable[node.UrlPathName])}";
        expression =
            "#{node.ObjectTypeNo == 3 ? securityContext.taskflowViewable[node.UrlPathName] : node.ObjectTypeNo == 2 ? true : false}";

        try {
            taskflowUrl = (String) JSFUtils.resolveExpression("#{node.UrlPathName}");
        } catch (Exception e) {
            taskflowUrl = null;
            _logger.severe(e);
        }
        _logger.info("TaskflowUrl = " + taskflowUrl);

        try {
            typeNo = (Long) JSFUtils.resolveExpression("#{node.ObjectTypeNo}");
        } catch (Exception e) {
            _logger.severe(e);
        }

        if (taskflowUrl == null) {
            //Set viewable as true when no taskflow URL was found
            hasPermission = false;
        } else {
            //Check if paramaters was passed as part of the taskflow URL and
            //remove them if found
            int dollerPos = taskflowUrl.indexOf("$");
            if (dollerPos > 0) {
                taskflowUrl = taskflowUrl.substring(0, dollerPos);
                //_logger.info("New taskflowUrl = " + taskflowUrl);
                //expression = "#{securityContext.taskflowViewable[\"" + taskflowUrl + "\"] ? true : (node.ObjectTypeNo == 3 ? false : true)}";

                //expression = "#{node.ObjectTypeNo != 3 ? true : (!securityContext.taskflowViewable[\""+ taskflowUrl + "\"])}";

                expression =
                    "#{node.ObjectTypeNo == 3 ? securityContext.taskflowViewable[\"" + taskflowUrl +
                    "\"] : node.ObjectTypeNo == 2 ? true : false}";
            }

            try {
                _logger.info("isTaskFlowViewable() - expression = " + expression);
                hasPermission = ((Boolean) JSFUtils.resolveExpression(expression)) || ((new Long(4)).equals(typeNo));
            } catch (Exception e) {
                hasPermission = false;
                _logger.severe(e);

                // TODO Add sending of an email with the generic mail solotion once available
            }
        }
        _logger.info("HasPermission = " + hasPermission);

        return hasPermission;
    }

    // TODO Add javadoc comments
    protected String parseTaskFlowUrl(String url) {
        if (url.contains("$")) {
            url = url.substring(0, url.indexOf("$"));
        }
        if (url.contains("?")) {
            url = url.substring(0, url.indexOf("?"));
        }

        return url;
    }

    // TODO Add javadoc comments
    protected Map<String, Object> parseTaskFlowParams(String url) {
        if ((url == null) || ((!url.contains("$")) && ((!url.contains("?"))))) {
            return null;
        }

        String params;
        if (url.contains("$")) {
            params = url.substring(url.indexOf("$") + 1);
        } else {
            params = url.substring(url.indexOf("?") + 1);
        }

        String param[];

        // Split according to traditional URL, not ,'s
        if (params.contains("&")) {
            param = params.split("&");
        } else {
            param = params.split(",");
        }


        Map<String, Object> parametersMap = new HashMap<String, Object>();

        for (int i = 0; i < param.length; i++) {
            String valuePair[] = param[i].split("=");
            parametersMap.put(valuePair[0], valuePair[1]);
        }

        return parametersMap;
    }
    // TODO Add javadoc comments
    private void closeTab(Object source) {
        TabContext tc = getTabContext();

        if (tc == null) {
            return;
        }

        if (source != null)
            if (source instanceof RichCommandNavigationItem) {

                RichCommandNavigationItem tabItem = (RichCommandNavigationItem) source;
                String tabName = tabItem.getText();

                for (int i = 0; i < tc.getTabs().size(); i++) {
                    Tab tab = tc.getTabs().get(i);
                    if (tabName.equals(tab.getTitle())) {
                        tc.removeTab(i);
                        break;
                    }
                }
            } else {
                _logger.warning("Expected a RichCommandNavigationItem component to close, instead received a " +
                                source.getClass());
            }
    }

    protected String getApplicationVersion() {
        String versionNo = "Local";
        try {
            //ChangeAwareClassLoader cl = (ChangeAwareClassLoader)getClass().getClassLoader();
            ClassLoader cl = getClass().getClassLoader();
            String classLoader = cl.toString();
            _logger.info("ClassLoader : " + classLoader);
            if (classLoader.contains("#")) {
                String[] splitCl = classLoader.split("#");
                versionNo = splitCl[1].split("@")[0];
            }
        } catch (Exception e) {
            _logger.severe(e);
        }
        return versionNo;
    }

    protected String getApplicationName() {
        String name = "Home";
        try {
            // Why is this being cast to a different class?
            //ChangeAwareClassLoader cl = (ChangeAwareClassLoader)getClass().getClassLoader();
            ClassLoader cl = getClass().getClassLoader();
            String classLoader = cl.toString();
            _logger.info("ClassLoader : " + classLoader);
            if (classLoader.contains("#")) {
                String[] splitCl = classLoader.split("#");
                String part1 = splitCl[0];
                String annotation = "annotation:";
                int index = part1.indexOf(annotation);
                name = part1.substring(index + annotation.length()).trim();
            }
        } catch (Exception e) {
            _logger.severe(e);
        }
        return name;
    }
}
