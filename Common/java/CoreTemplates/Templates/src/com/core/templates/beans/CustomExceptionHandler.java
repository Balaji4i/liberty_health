package com.core.templates.beans;

import oracle.adf.controller.ControllerContext;

public class CustomExceptionHandler {

    private ControllerContext contCtx;

    public CustomExceptionHandler() {
        contCtx = ControllerContext.getInstance();
    }

    /**
     *
     * @return
     */
    public String getStacktrace() {
        Exception e = contCtx.getCurrentViewPort().getExceptionData();
        if (e != null) {
            StackTraceElement[] s = e.getStackTrace();
            StringBuffer str = new StringBuffer();
            for (StackTraceElement element : s) {
                str.append(element).append("\n");
            }
            return str.toString();
        }
        return null;
    }

    public String backButtonAction() {
        return "back";
    }
}
