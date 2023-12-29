package com.core.templates.beans;

import java.io.Serializable;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import javax.annotation.PostConstruct;

import javax.el.ELContext;
import javax.el.ExpressionFactory;
import javax.el.ValueExpression;

import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;

import oracle.adf.view.rich.component.rich.fragment.RichPageTemplate;
import oracle.adf.view.rich.component.rich.fragment.RichRegion;
import oracle.adf.view.rich.component.rich.layout.RichPanelDashboard;
import oracle.adf.view.rich.datatransfer.DataFlavor;
import oracle.adf.view.rich.dnd.DnDAction;
import oracle.adf.view.rich.event.DropEvent;

import org.apache.myfaces.trinidad.change.ComponentChange;
import org.apache.myfaces.trinidad.change.ReorderChildrenComponentChange;
import org.apache.myfaces.trinidad.component.UIXGroup;
import org.apache.myfaces.trinidad.component.UIXPanel;
import org.apache.myfaces.trinidad.component.UIXSwitcher;
import org.apache.myfaces.trinidad.context.RequestContext;


/**
 * Managed bean for handling dynamic tabs on the home page.
 */
public class Dashboard implements Serializable {

    private static final long serialVeID_PREFIXrsionUID = 1L;
    private static final String ID_PREFIX = "region_";
    boolean regionsInitialized = false;
    //used for user preferences persistance, discriminator: ParentComponentId
    private String parentComponentId = "ALL";

    private SideBarItem[] ALL_ITEMS;
    private SideBarItem[] NO_ITEMS = { };

    private List<SideBarItem> _sideBarItems;
    private transient RichPanelDashboard _dashboard;
    private transient UIXPanel _sideBarContainer;
    private transient UIXSwitcher _switcher;
    private transient Object _maximizedPanelKey;
    private List<RichRegion> regions;

    /**
     * Default constructor.
     */
    public Dashboard() {
    }

    @PostConstruct
    private void initialize() {

        //Method should be called once per task flow instance
        if (regionsInitialized)
            return;

        //Initialize regions
        initRegions();
        _sideBarItems = new ArrayList<SideBarItem>();
        Collection<RichRegion> regions = getRegionsInInitialOrder();

        ALL_ITEMS = new SideBarItem[regions.size()];
        int index = 0;
        for (RichRegion region : regions) {
            SideBarItem item =
                new SideBarItem((String) region.getAttributes().get("title"), ID_PREFIX + region.getId());
            _sideBarItems.add(item);
            ALL_ITEMS[index] = item;
            index++;
        }
        regionsInitialized = true;
    }

    /**
     *
     */
    private Collection getRegionsInInitialOrder() {
        Map regionsMap = new TreeMap();
        for (RichRegion region : regions) {
            double initialOrderIndex = getInitialRegionIndex(region.getId());
            regionsMap.put(initialOrderIndex, region);
        }
        return regionsMap.values();
    }

    /**
     *
     */
    private void initRegions() {
        //Sorted map
        Map regionMap = new TreeMap();
        FacesContext fc = FacesContext.getCurrentInstance();
        ELContext elContext = fc.getELContext();
        ExpressionFactory elFactory = fc.getApplication().getExpressionFactory();
        ValueExpression valExpression = elFactory.createValueExpression(elContext, "#{dasboardTemplate}", Object.class);
        RichPageTemplate template = (RichPageTemplate) valExpression.getValue(elContext);
        if (template.findComponent("regionsId") == null)
            throw new IllegalStateException("Panel Dashboard Exception : The regions that would be included inside the component should be wrapped inside an af:group component having the id equal to regionsId.");

        UIXGroup group = (UIXGroup) template.findComponent("regionsId");
    //    Map userPrefMap = getAM().getUserPreferences(parentComponentId);

        int minusIndex = -1;
        for (int i = 0; i < group.getChildCount(); i++) {
            if (!(group.getChildren().get(i) instanceof RichRegion))
                throw new IllegalStateException("Panel Dashboard Exception : The regions parent should be an af:group component. No intermediate components allowed.");

            RichRegion region = (RichRegion) group.getChildren().get(i);

            //checking the region.id format. It should be : r0, r1, r2 etc..
            if (!region.getId().startsWith("r")) {
                String regionIndexStr = region.getId().substring(1, region.getId().length());
                try {
                    Double.parseDouble(regionIndexStr);
                } catch (NumberFormatException nfe) {
                    throw new IllegalStateException("Panel Dashboard Exception : The id of the regions must be of formatted like r0, r1.");
                }
                //throw new IllegalStateException("the regions parent should be the af:group. No intermediate components allowed. ");
            }

            if (region.isRendered()) {
//                if (userPrefMap.isEmpty()) { //no customization for the user
//                    regionMap.put(new Integer(i), region);
//                } else if (userPrefMap.containsKey(ID_PREFIX + region.getId())) {
//                    Integer componentIdIndex = (Integer) userPrefMap.get(ID_PREFIX + region.getId());
//                    regionMap.put(componentIdIndex, region);
//                } else {
//                    region.setRendered(false);
//                    regionMap.put(new Integer(minusIndex--), region);
//                }
            }
        }

        //Retreive the regions list in the sorted manner.
        Iterator itSortedRegions = regionMap.keySet().iterator();
        List regionList = new ArrayList();
        while (itSortedRegions.hasNext()) {
            Integer componentIdIndex = (Integer) itSortedRegions.next();
            regionList.add(regionMap.get(componentIdIndex));
        }
        setRegions(regionList);
    }

    /**
     * Returns the dashboard.
     * @return the dashboard
     */
    public RichPanelDashboard getDashboard() {
        return _dashboard;
    }

    /**
     * Specifies the dashboard.
     * @param dashboard the dashboard
     */
    public void setDashboard(RichPanelDashboard dashboard) {
        _dashboard = dashboard;
    }

    /**
     * Returns the container for the side bar iterator.
     * @return the container for the side bar iterator
     */
    public UIXPanel getSideBarContainer() {
        return _sideBarContainer;
    }

    /**
     * Specifies the container for the side bar iterator.
     * @param sideBarContainer the container for the side bar iterator
     */
    public void setSideBarContainer(UIXPanel sideBarContainer) {
        _sideBarContainer = sideBarContainer;
    }

    /**
     * Returns the switcher.
     * @return the switcher
     */
    public UIXSwitcher getSwitcher() {
        return _switcher;
    }

    /**
     * Specifies the switcher.
     * @param switcher the switcher
     */
    public void setSwitcher(UIXSwitcher switcher) {
        _switcher = switcher;
    }

    /**
     * Fetches the list of panel data objects.
     * @return a list of PanelData objects
     */
    public List<SideBarItem> getSideBarDataItems() {
        return _sideBarItems;
    }

    /**
     *
     * @return
     */
    public String getMaximizedTitle() {
        Iterator<SideBarItem> i = _sideBarItems.iterator();
        while (i.hasNext()) {
            SideBarItem data = i.next();
            if (_maximizedPanelKey.equals(data.getItemId())) {
                return data.getTitle();
            }
        }
        return null;
    }

    /**
     *
     * @return
     */
    public String getMaximizedKey() {
        if (_maximizedPanelKey == null) {
            return "empty"; //to avoid a FileNotFoundException
        }

        return _maximizedPanelKey.toString();
    }

    /**
     *
     * @return
     */
    public RichRegion getMaximizedRegion() {
        if (_maximizedPanelKey == null)
            //Return the first region allways. this is done for evalution phase only. Otherwise, exceptions are logged into the console window. However, has no effect on the dashboard behaviour
            if (getRegions().size() > 0)
                return getRegions().get(0);
            else
                return null;
        Iterator<SideBarItem> i = _sideBarItems.iterator();
        int index = 0;
        while (i.hasNext()) {
            SideBarItem data = i.next();
            if (_maximizedPanelKey.equals(data.getItemId())) {
                try {
                    return this.getRegion(data.getItemId().split("_")[1]);
                } catch (Exception e) {
                    throw new IllegalStateException("Panel Dashboard Exception : No region exists with the Id equal to : " +
                                                    _maximizedPanelKey + ".");
                }
            }
            index++;
        }
        throw new IllegalStateException("Panel Dashboard Exception : No region exists with the Id equal to : " +
                                        _maximizedPanelKey + ".");
    }

    /**
     * Changes the shown dashboard items to match the desired state.
     * (_maximizedPanelKey must be null)
     * @param e the ActionEvent associated with the action
     */
    public void showPresetItems(ActionEvent e) {
        UIComponent eventComponent = e.getComponent();
        Object desiredMode = _getAssociatedModeKey(eventComponent);
        SideBarItem[] desiredItems = null;
        if ("all".equals(desiredMode)) {
            desiredItems = ALL_ITEMS;
        } else if ("none".equals(desiredMode)) {
            desiredItems = NO_ITEMS;
        } else {
            throw new IllegalStateException("Panel Dashboard Exception : Unknown preset items mode : " + desiredMode +
                                            ".");
        }

        FacesContext context = FacesContext.getCurrentInstance();

        //Remove any undesired items:
        int deleteIndex = 0;
        List<UIComponent> children = _dashboard.getChildren();
        for (UIComponent child : children) {
            boolean childIsDesired = false;
            for (int i = 0; i < desiredItems.length; i++) {
                if (desiredItems[i].getItemId().equals(child.getId())) {
                    childIsDesired = true;
                    break;
                }
            }
            if (!childIsDesired && child.isRendered()) {
                //Set rendered to false and increment since we want to count the ones we are switching too as part of the index (so the correct one will be deleted in the browser):
                child.setRendered(false);
                _dashboard.prepareOptimizedEncodingOfDeletedChild(context, deleteIndex++);
            }
            if (child.isRendered()) {
                //Only count rendered children since that's all that the panelDashboard can see:
                deleteIndex++;
            }
        }

        //Add any missing items:
        int insertIndex = 0;
        for (UIComponent child : children) {
            for (int i = 0; i < desiredItems.length; i++) {
                if (desiredItems[i].getItemId().equals(child.getId())) {
                    if (!child.isRendered()) {
                        child.setRendered(true);
                        _dashboard.prepareOptimizedEncodingOfInsertedChild(context, insertIndex);
                    }
                    break;
                }
            }
            if (child.isRendered()) {
                //Only count rendered children since that's all that the panelDashboard can see:
                insertIndex++;
            }
        }

        //Redraw the side bar so that we can draw update the colors of the opened items and the insertion indexes of the links:
        RequestContext rc = RequestContext.getCurrentInstance();
        rc.addPartialTarget(_sideBarContainer);

        notifyUserPreferenceChange();
    }

    /**
     * Handler for component movements into the side bar from the dashboard.
     * @param e the DropEvent for the movement
     * @return the DnDAction that determines whether to redraw the drop target
     */
    public DnDAction handleSideBarDrop(DropEvent e) {
        UIComponent movedComponent = e.getTransferable().getData(DataFlavor.UICOMPONENT_FLAVOR);
        UIComponent movedParent = movedComponent.getParent();

        //Ensure that the drag source is one of the items from the dashboard:
        if (movedParent.equals(_dashboard)) {
            _minimize(movedComponent);
        }
        //the client is already updated, so no need to redraw it again
        return DnDAction.NONE;
    }

    /**
     * Handler for the re-ordering drop event on the panelDashboard. Change the component order in the component tree and update the side bar with new insertion indexes.
     * This is also the handler for dropping in a minimized side bar item into the dashboard. In that case, the associated panelDashboard child should then be restored.
     * @param e the DropEvent for the dashboard child reordering
     * @return the DnDAction that determines whether to redraw the drop target
     */
    public DnDAction move(DropEvent e) {
        UIComponent dropComponent = e.getDropComponent();
        UIComponent movedComponent = e.getTransferable().getData(DataFlavor.UICOMPONENT_FLAVOR);
        UIComponent movedParent = movedComponent.getParent();

        //Ensure that we are handling the re-order of a direct child of the panelDashboard:
        if (movedParent.equals(dropComponent) && dropComponent.equals(_dashboard)) {
            //Move the already rendered child and redraw the side bar since the insert indexes have changed:
            _moveDashboardChild(e.getDropSiteIndex(), movedComponent.getId());
        } else {
            //This isn't a re-order but rather the user dropped a minimized side bar item into the dashboard, in which case that item should be restored at the specified drop location.
            String panelKey = _getAssociatedPanelKey(movedComponent);
            if (panelKey != null) {
                UIComponent panelBoxToShow = _dashboard.findComponent(panelKey);
                //Make this panelBox rendered:
                panelBoxToShow.setRendered(true);
                int insertIndex = e.getDropSiteIndex();
                //Move the already rendered child and redraw the side bar since the insert indexes have changed and because the side bar minimized states are out of date:
                _moveDashboardChild(insertIndex, panelKey);
                //Let the dashboard know that only the one child should be encoded during the render phase:
                _dashboard.prepareOptimizedEncodingOfInsertedChild(FacesContext.getCurrentInstance(), insertIndex);
            }
        }
        return DnDAction.NONE; //the client is already updated, so no need to redraw it again
    }

    /**
     *
     * @param dropIndex
     * @param movedId
     */
    private void _moveDashboardChild(int dropIndex, String movedId) {
        //Build the new list of IDs, placing the moved component at the drop index.
        List<String> reorderedIdList = new ArrayList<String>(_dashboard.getChildCount());
        int index = 0;
        boolean added = false;

        for (UIComponent currChild : _dashboard.getChildren()) {
            if (currChild.isRendered()) {
                if (index == dropIndex) {
                    reorderedIdList.add(movedId);
                    added = true;
                }
                String currId = currChild.getId();
                if (currId.equals(movedId) && index < dropIndex) {
                    //component is moved later, need to shift the index by 1
                    dropIndex++;
                }
                if (!currId.equals(movedId)) {
                    reorderedIdList.add(currId);
                }
                index++;
            }
        }
        if (!added) {
            //Added to the very end:
            reorderedIdList.add(movedId);
        }
        //Apply the change to the component tree immediately:
        ComponentChange change = new ReorderChildrenComponentChange(reorderedIdList);
        change.changeComponent(_dashboard);

        //Add the side bar as a partial target since we need to redraw the state of the side bar items since their insert indexes are changed and possibly
        //because the side bar minimized states areout of date:
        RequestContext rc = RequestContext.getCurrentInstance();
        rc.addPartialTarget(_sideBarContainer);
        notifyUserPreferenceChange();
    }

    public void sideBarShow(ActionEvent e) {
        if (_maximizedPanelKey == null) {
            //Show non-maximized:
            UIComponent eventComponent = e.getComponent();
            String panelKey = _getAssociatedPanelKey(eventComponent);
            UIComponent panelBoxToShow = _dashboard.findComponent(panelKey);
            //Make this panelBox rendered:
            panelBoxToShow.setRendered(true);
            //Since the dashboard is already shown, let's perform an optimized render so the whole dashboard doesn't have to be re-encoded:
            int insertIndex = 0;
            List<UIComponent> children = _dashboard.getChildren();
            for (UIComponent child : children) {
                if (child.equals(panelBoxToShow)) {
                    //Let the dashboard know that only the one child should be encoded during the render phase:
                    _dashboard.prepareOptimizedEncodingOfInsertedChild(FacesContext.getCurrentInstance(), insertIndex);
                    break;
                }
                if (child.isRendered()) {
                    //Only count rendered children since that's all that the panelDashboard can see:
                    insertIndex++;
                }
            }
            //Add the side bar as a partial target since we need to redraw the state of the side bar item that corresponds to the inserted item:
            RequestContext rc = RequestContext.getCurrentInstance();
            rc.addPartialTarget(_sideBarContainer);
            notifyUserPreferenceChange();
        } else {
            //Show maximized:
            sideBarMaximize(e);
        }
    }

    /**
     *
     * @param e
     */
    public void minimize(ActionEvent e) {
        UIComponent eventComponent = e.getComponent();
        String panelKey = _getAssociatedPanelKey(eventComponent);
        UIComponent panelBoxToMinimize = _dashboard.findComponent(panelKey);
        _minimize(panelBoxToMinimize);
    }

    /**
     *
     * @param panelBoxToMinimize
     */
    private void _minimize(UIComponent panelBoxToMinimize) {
        //Make this panelBox non-rendered:
        panelBoxToMinimize.setRendered(false);

        //If the dashboard is showing, let's perform an optimized render so the whole dashboard doesn't have to be re-encoded.
        //If the dashboard is hidden (because the panelBox is maximized), we will not do an optimized encode since we need to draw the whole thing.
        if (_maximizedPanelKey == null) {
            int deleteIndex = 0;
            List<UIComponent> children = _dashboard.getChildren();
            for (UIComponent child : children) {
                if (child.equals(panelBoxToMinimize)) {
                    _dashboard.prepareOptimizedEncodingOfDeletedChild(FacesContext.getCurrentInstance(), deleteIndex);
                    break;
                }
                if (child.isRendered()) {
                    //Only count rendered children since that's all that the panelDashboard can see:
                    deleteIndex++;
                }
            }
        }
        RequestContext rc = RequestContext.getCurrentInstance();
        if (_maximizedPanelKey != null) {
            //Exit maximized mode:
            _maximizedPanelKey = null;
            _switcher.setFacetName("restored");
            rc.addPartialTarget(_switcher);
        }

        //Redraw the side bar so that we can update the colors of the opened items:
        rc.addPartialTarget(_sideBarContainer);
        notifyUserPreferenceChange();
    }

    /**
     *
     * @param e
     */
    public void sideBarMaximize(ActionEvent e) {
        String panelKey = _getAssociatedPanelKey(e.getComponent());
        _maximizedPanelKey = panelKey;
        UIComponent panelBoxToMaximize = _dashboard.findComponent(panelKey);
        //Make this panelBox rendered:
        panelBoxToMaximize.setRendered(true);
        _switcher.setFacetName("maximized");
        RequestContext rc = RequestContext.getCurrentInstance();
        rc.addPartialTarget(_switcher);
        //Redraw the side bar so that we can draw update the maximized icons:
        rc.addPartialTarget(_sideBarContainer);
    }

    /**
     *
     * @param e
     */
    public void maximize(ActionEvent e) {
        String panelKey = _getAssociatedPanelKey(e.getComponent());
        _maximizedPanelKey = panelKey;
        _switcher.setFacetName("maximized");
        RequestContext rc = RequestContext.getCurrentInstance();
        rc.addPartialTarget(_switcher);
        //Redraw the side bar so that we can draw update the maximized icons:
        rc.addPartialTarget(_sideBarContainer);
    }

    /**
     *
     * @param e
     */
    public void restore(ActionEvent e) {
        _maximizedPanelKey = null;
        _switcher.setFacetName("restored");
        RequestContext rc = RequestContext.getCurrentInstance();
        rc.addPartialTarget(_switcher);
        //Redraw the side bar so that we can draw update the maximized icons:
        rc.addPartialTarget(_sideBarContainer);
    }


    /**
     * retreives the list of the regions from the page
     *
     */
    public List<RichRegion> getRegions() {
        return regions;
    }

    /**
     *
     * @param regionId
     * @return
     */
    public RichRegion getRegion(String regionId) {
        List<RichRegion> regions = this.getRegions();
        Iterator<RichRegion> regionsIter = regions.iterator();
        while (regionsIter.hasNext()) {
            RichRegion region = regionsIter.next();
            if (regionId.equals(region.getId())) {
                return region;
            }
        }
        return null;
    }

    /**
     *
     * @param component
     * @return
     */
    private String _getAssociatedPanelKey(UIComponent component) {
        Map<String, Object> attrs = component.getAttributes();
        return (String) attrs.get("associatedPanelKey"); //added to the component by the f:attribute tag
    }

    /**
     *
     * @param component
     * @return
     */
    private Object _getAssociatedModeKey(UIComponent component) {
        Map<String, Object> attrs = component.getAttributes();
        return attrs.get("mode"); //added to the component by the f:attribute tag
    }

    /**
     *
     * @param regions
     */
    private void setRegions(List regions) {
        this.regions = regions;
    }

    /**
     *
     */
    private void notifyUserPreferenceChange() {
        Iterator it = getDashboard().getChildren().iterator();
        LinkedHashMap map = new LinkedHashMap();
        while (it.hasNext()) {
            UIComponent paneBox = (UIComponent) it.next();
            map.put(paneBox.getId(), paneBox.isRendered());
        }
    //    getAM().persistUserPreferences(map, parentComponentId);
    }

    /**
     * parses the id of the region as it comes from the welcome fragment
     @param regionId : r0, r1, r1, .....rn
     */
    private double getInitialRegionIndex(String regionId) {
        String regionIndexStr = regionId.substring(1, regionId.length());
        return Double.parseDouble(regionIndexStr);
    }

    /**
     *
     * @param parentComponentId
     */
    public void setParentComponentId(String parentComponentId) {
        this.parentComponentId = parentComponentId;
    }

    /**
     *
     * @return
     */
    public String getParentComponentId() {
        return parentComponentId;
    }


    /**
     * Represents a single side bar item used for links to panelBoxes into the panelDashboard.
     */
    public class SideBarItem implements Serializable {
        public SideBarItem(String title, String itemId) {
            _title = title;
            _itemId = itemId;
        }

        /**
         * Retrieves the title of the side bar item.
         * @return the title of the side bar item
         */
        public String getTitle() {
            return _title;
        }

        /**
         * Retrieves the status for the side bar item.
         * @return the status for the side bar item
         */
        public String getStatus() {
            return _status;
        }

        /**
         * Retrieves the ID of the panelDashboard child associated with this side bar item.
         * @return the ID of the panelDashboard child associated with this side bar item
         */
        public String getItemId() {
            return _itemId;
        }

        /**
         * Retrieves whether this panelBox child is rendered in the dashboard.
         * @return true if rendered, false otherwise
         */
        public boolean isPanelBoxRendered() {
            if (_dashboard == null) {
                throw new RuntimeException("Unexpected null dashboard.");
            }
            UIComponent panelBox = _dashboard.findComponent(_itemId);
            if (panelBox == null) {
                throw new RuntimeException("Unexpected null panelBox id=" + _itemId);
            }
            return panelBox.isRendered();
        }

        /**
         * Retrieves the index within the list of rendered dashboard children at which the insert will occur.
         * Since the insertion placeholder gets added before the insertion occurs on the server,
         * you must specify the location where you are planning to insert the child so that if the user reloads the page,
         * the children will continue to remain displayed in the same order.
         * @return the client rendered index at which the item needs to appear
         */
        public int getIndexIfRendered() {
            int index = 0;
            for (UIComponent child : _dashboard.getChildren()) {
                if (_itemId.equals(child.getId())) {
                    return index;
                } else if (child.isRendered()) {
                    index++;
                }
            }
            throw new RuntimeException("Unable to determine the index if rendered for panelBox id=" + _itemId);
        }

        private String _title;
        private String _itemId;
        private String _status = "";
    }

    /**
     *
     * @return
     */
//    public UserDisplayPreferencesAMImpl getAM() {
//        UserDisplayPreferencesAMImpl am =
//            (UserDisplayPreferencesAMImpl) ADFUtils.getApplicationModuleForDataControl("UserDisplayPreferencesAM");
//        return am;
//    }
}
