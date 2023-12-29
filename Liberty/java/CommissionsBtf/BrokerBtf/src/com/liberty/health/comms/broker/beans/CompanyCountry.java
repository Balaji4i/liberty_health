package com.liberty.health.comms.broker.beans;

import com.core.generic.CoreActions;

import oracle.adf.view.rich.event.DialogEvent;
import oracle.adf.view.rich.event.PopupCanceledEvent;
import oracle.adf.view.rich.event.PopupFetchEvent;

public class CompanyCountry extends CoreActions {
    public CompanyCountry() {
        super();
    }

    public void popFetchActionListener(PopupFetchEvent popupFetchEvent) {
        callOperation("CreateWithParams");
    }

    public void popUpCancelActionListener(PopupCanceledEvent popupCanceledEvent) {
        callOperation("Rollback");
    }

    public void dialogListener(DialogEvent dialogEvent) {
        if (dialogEvent.getOutcome() == dialogEvent.getOutcome().ok) {
            callOperation("Commit");
        }
    }
}
