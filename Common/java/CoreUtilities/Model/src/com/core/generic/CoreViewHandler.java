package com.core.generic;

import com.sun.faces.application.view.MultiViewHandler;

import java.util.Locale;

import javax.faces.context.FacesContext;

import javax.servlet.http.HttpSession;

public class CoreViewHandler extends MultiViewHandler {
    public Locale calculateLocale(FacesContext context) {
        HttpSession session = (HttpSession) context.getExternalContext()
            .getSession(false);
        if (session != null) {
            //Return the locale saved by the managed bean earlier
            Locale locale = (Locale) session.getAttribute("locale");
            if (locale != null) {
                return locale;
            }
        }
       return super.calculateLocale(context);
    }
}
