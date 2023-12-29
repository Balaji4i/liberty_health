package com.liberty.health.comms.home.model;

import com.core.model.services.classes.CoreApplicationModuleImpl;
import com.core.model.vo.WebApplObjectLangMenuViewImpl;
import com.core.model.vo.WebApplObjectViewImpl;


import com.liberty.health.comms.home.model.common.CommsHomeAM;

import com.liberty.health.comms.model.watchlist.vo.CommissionsWatchListRoViewImpl;

import oracle.jbo.server.ApplicationModuleImpl;
import oracle.jbo.server.ViewLinkImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Fri May 05 14:32:03 CAT 2017
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class CommsHomeAMImpl extends CoreApplicationModuleImpl implements CommsHomeAM {
    /**
     * This is the default constructor (do not remove).
     */
    public CommsHomeAMImpl() {
    }

    /**
     * Container's getter for Menu.
     * @return Menu
     */
    public WebApplObjectViewImpl getMenu() {
        return (WebApplObjectViewImpl) findViewObject("Menu");
    }

    /**
     * Container's getter for SubMenu.
     * @return SubMenu
     */
    public WebApplObjectViewImpl getSubMenu() {
        return (WebApplObjectViewImpl) findViewObject("SubMenu");
    }

    /**
     * Container's getter for FkWebApplObjectWebApplObjectParentLink1.
     * @return FkWebApplObjectWebApplObjectParentLink1
     */
    public ViewLinkImpl getFkWebApplObjectWebApplObjectParentLink1() {
        return (ViewLinkImpl) findViewLink("FkWebApplObjectWebApplObjectParentLink1");
    }
    
    
    /**
     *
     * @param localCode
     */
    public void setMenuLocalCode (String localCode) {
        this.getMenu().setlocaleCode(localCode);
        this.getMenu().executeQuery();
    }

    /**
     * Container's getter for WebApplObjectLangMenuView1.
     * @return WebApplObjectLangMenuView1
     */
    public WebApplObjectLangMenuViewImpl getUpdateMenuItemNameView() {
        return (WebApplObjectLangMenuViewImpl) findViewObject("UpdateMenuItemNameView");
    }

    /**
     * Container's getter for WebApplObjectView1.
     * @return WebApplObjectView1
     */
    public WebApplObjectViewImpl getUpdateMenuSortSeqView() {
        return (WebApplObjectViewImpl) findViewObject("UpdateMenuSortSeqView");
    }

    /**
     * Container's getter for CommissionsWatchListRoView1.
     * @return CommissionsWatchListRoView1
     */
    public CommissionsWatchListRoViewImpl getAllCommissionsWatchListView() {
        return (CommissionsWatchListRoViewImpl) findViewObject("AllCommissionsWatchListView");
    }

    /**
     * Container's getter for WebApplObjectLangMenuView1.
     * @return WebApplObjectLangMenuView1
     */
    public WebApplObjectLangMenuViewImpl getWebApplObjectLangMenuView1() {
        return (WebApplObjectLangMenuViewImpl) findViewObject("WebApplObjectLangMenuView1");
    }

    /**
     * Container's getter for FkWebApplObjectLangMenuWebApplObjectMenuLink1.
     * @return FkWebApplObjectLangMenuWebApplObjectMenuLink1
     */
    public ViewLinkImpl getFkWebApplObjectLangMenuWebApplObjectMenuLink1() {
        return (ViewLinkImpl) findViewLink("FkWebApplObjectLangMenuWebApplObjectMenuLink1");
    }
}

