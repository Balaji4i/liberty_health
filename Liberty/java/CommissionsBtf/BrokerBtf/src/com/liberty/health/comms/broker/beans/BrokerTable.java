package com.liberty.health.comms.broker.beans;

import com.core.generic.CoreActions;

import oracle.adf.view.rich.event.PopupCanceledEvent;
import oracle.adf.view.rich.event.PopupFetchEvent;

public class BrokerTable extends CoreActions {
    public BrokerTable() {
        super();
    }

    public void brokerTableTypePopUpDialogListener(PopupFetchEvent popupFetchEvent) {
        callOperation("CreateInsert");
    }

    public void BrokerTableTypePopUpCancelListener(PopupCanceledEvent popupCanceledEvent) {
        callOperation("Rollback");
    }
}
