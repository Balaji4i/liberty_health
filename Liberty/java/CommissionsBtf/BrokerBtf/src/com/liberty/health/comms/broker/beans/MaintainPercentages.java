package com.liberty.health.comms.broker.beans;


import com.core.generic.CoreActions;

import javax.faces.event.ActionEvent;

import oracle.adf.model.BindingContext;
import oracle.adf.model.binding.DCBindingContainer;
import oracle.adf.model.binding.DCIteratorBinding;
import oracle.adf.share.ADFContext;
import oracle.adf.view.rich.component.rich.data.RichTable;
import oracle.adf.view.rich.context.AdfFacesContext;

import oracle.binding.BindingContainer;

import oracle.jbo.Row;
import oracle.jbo.RowSetIterator;
import oracle.jbo.ViewObject;

import org.apache.myfaces.trinidad.event.SelectionEvent;

public class MaintainPercentages extends CoreActions {
    private RichTable percentageTable;
    private RichTable ohiPercTable;

    public MaintainPercentages() {
        super();
    }

    public void setPercentageTable(RichTable percentageTable) {
        this.percentageTable = percentageTable;
    }

    public RichTable getPercentageTable() {
        return percentageTable;
    }

    public void copyDownGroupValue(ActionEvent actionEvent) {
        BindingContainer bindings = BindingContext.getCurrent().getCurrentBindingsEntry();
        DCIteratorBinding row = (DCIteratorBinding) bindings.get("MaintainGroupPercentagesViewIterator");
        ViewObject voTableData = row.getViewObject();
        Row rowSelected = voTableData.getCurrentRow();
        Object commPerc = rowSelected.getAttribute("CommPerc");

        RowSetIterator rsi = row.getViewObject().createRowSetIterator(null);
        rsi.setCurrentRow(rowSelected);
        Row rowNew = voTableData.getCurrentRow();

        while (rsi.hasNext()) {
            Row setRow = rsi.next();
            setRow.setAttribute("CommPerc", commPerc);
        }
        rsi.closeRowSetIterator();
        AdfFacesContext.getCurrentInstance().addPartialTarget(this.getPercentageTable());
    }

    public void copyDownProductValue(ActionEvent actionEvent) {
        BindingContainer bindings = BindingContext.getCurrent().getCurrentBindingsEntry();
        DCIteratorBinding row = (DCIteratorBinding) bindings.get("MaintainProductPercentagesViewIterator");
        ViewObject voTableData = row.getViewObject();
        Row rowSelected = voTableData.getCurrentRow();
        Object commPerc = rowSelected.getAttribute("CommPerc");

        RowSetIterator rsi = row.getViewObject().createRowSetIterator(null);
        rsi.setCurrentRow(rowSelected);
        Row rowNew = voTableData.getCurrentRow();

        while (rsi.hasNext()) {
            Row setRow = rsi.next();
            setRow.setAttribute("CommPerc", commPerc);
        }
        rsi.closeRowSetIterator();
        AdfFacesContext.getCurrentInstance().addPartialTarget(this.getPercentageTable());
    }

    public void groupSelectionListener(SelectionEvent selectionEvent) {
        DCBindingContainer bindings = (DCBindingContainer) BindingContext.getCurrent().getCurrentBindingsEntry();
        DCIteratorBinding dcItteratorBindings = bindings.findIteratorBinding("MaintainGroupPercentagesViewIterator");
        GenericTableSelectionHandler.makeCurrent(selectionEvent);
        // Get an object representing the table and what may be selected within it
        ViewObject voTableData = dcItteratorBindings.getViewObject();
        // Get selected row
        Row rowSelected = voTableData.getCurrentRow();
    }

    public void productSelectionListener(SelectionEvent selectionEvent) {
        DCBindingContainer bindings = (DCBindingContainer) BindingContext.getCurrent().getCurrentBindingsEntry();
        DCIteratorBinding dcItteratorBindings = bindings.findIteratorBinding("MaintainProductPercentagesViewIterator");
        GenericTableSelectionHandler.makeCurrent(selectionEvent);
        // Get an object representing the table and what may be selected within it
        ViewObject voTableData = dcItteratorBindings.getViewObject();

        // Get selected row
        Row rowSelected = voTableData.getCurrentRow();
    }


    public void copyDownHoldInd(ActionEvent actionEvent) {
        BindingContainer bindings = BindingContext.getCurrent().getCurrentBindingsEntry();
        DCIteratorBinding row = (DCIteratorBinding) bindings.get("MaintainGroupPercentagesViewIterator");
        ViewObject voTableData = row.getViewObject();
        Row rowSelected = voTableData.getCurrentRow();
        Object holdInd = rowSelected.getAttribute("HoldInd");
        if (holdInd == null) {
            holdInd = "Y";
        }
        System.out.println("value of hold ind = " + holdInd);

        RowSetIterator rsi = row.getViewObject().createRowSetIterator(null);
        rsi.setCurrentRow(rowSelected);

        while (rsi.hasNext()) {
            Row setRow = rsi.next();
            setRow.setAttribute("HoldInd", holdInd);
        }
        rsi.closeRowSetIterator();
        //  AdfFacesContext.getCurrentInstance().addPartialTarget(this.getPercentageTable());
    }

    public void copyDownProductHoldInd(ActionEvent actionEvent) {
        BindingContainer bindings = BindingContext.getCurrent().getCurrentBindingsEntry();
        DCIteratorBinding row = (DCIteratorBinding) bindings.get("MaintainProductPercentagesViewIterator");
        ViewObject voTableData = row.getViewObject();
        Row rowSelected = voTableData.getCurrentRow();
        Object holdInd = rowSelected.getAttribute("HoldInd");
        System.out.println("value of hold ind = " + holdInd);
        RowSetIterator rsi = row.getViewObject().createRowSetIterator(null);
        rsi.setCurrentRow(rowSelected);
        Row rowNew = voTableData.getCurrentRow();

        while (rsi.hasNext()) {
            Row setRow = rsi.next();
            setRow.setAttribute("HoldInd", holdInd);
        }
        rsi.closeRowSetIterator();
        AdfFacesContext.getCurrentInstance().addPartialTarget(this.getPercentageTable());
    }

    public void authUsernameButtonActionListener(ActionEvent actionEvent) {
        System.out.println("****************************************************************");
        BindingContainer bindings = BindingContext.getCurrent().getCurrentBindingsEntry();
        DCIteratorBinding row = (DCIteratorBinding) bindings.get("MaintainOhiCommPercentageViewIterator");
        ViewObject voTableData = row.getViewObject();
        Row rowSelected = voTableData.getCurrentRow();
        System.out.println("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
        rowSelected.setAttribute("AutUsername", ADFContext.getCurrent().getSecurityContext().getUserName());
        System.out.println("---------------------------------------------------------------------");
/*        RowSetIterator rsi = row.getViewObject().createRowSetIterator(null);
        rsi.setCurrentRow(rowSelected);
        Row rowNew = voTableData.getCurrentRow();
        rowNew.setAttribute(arg0, arg1);*/
    System.out.println("****************************************************************");
    }

    public void setOhiPercTable(RichTable ohiPercTable) {
        this.ohiPercTable = ohiPercTable;
    }

    public RichTable getOhiPercTable() {
        return ohiPercTable;
    }
}
