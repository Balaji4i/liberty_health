package com.core.model.vo.classes;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.util.ArrayList;

import oracle.adf.share.logging.ADFLogger;

import oracle.jbo.AttributeList;
import oracle.jbo.JboException;
import oracle.jbo.Key;
import oracle.jbo.NameValuePairs;
import oracle.jbo.Row;
import oracle.jbo.ViewCriteria;
import oracle.jbo.ViewCriteriaManager;
import oracle.jbo.server.ApplicationModuleImpl;
import oracle.jbo.server.QueryCollection;
import oracle.jbo.server.TransactionEvent;
import oracle.jbo.server.ViewObjectImpl;
import oracle.jbo.server.ViewRowImpl;
import oracle.jbo.server.ViewRowSetImpl;

public class CoreViewObjectImpl extends ViewObjectImpl {
    protected static ADFLogger _logger = ADFLogger.createADFLogger(CoreViewObjectImpl.class);
    private boolean logEnabled;
    Key currentRowKey;
    int firstRowInRange;
    int currentRowIndexInRange;
    private int maxRows = 0;
    private boolean filterQuery = false;

    public void beforeRollback(TransactionEvent TransactionEvent) {
        if (isExecuted()) {
            Row currentRow = getCurrentRow();
            //      if ((!((ApplicationModuleImpl)getApplicationModule()).getRowStatus(currentRow).equals("New")) &&
            //        (currentRow != null))
            //      {
            //        this.currentRowKey = currentRow.getKey();
            //        this.firstRowInRange = getRangeStart();
            //        int rangeIndexOfCurrentRow = getRangeIndexOf(currentRow);
            //        this.currentRowIndexInRange = rangeIndexOfCurrentRow;
            //      }
        }
        super.beforeRollback(TransactionEvent);
    }

    public void afterRollback(TransactionEvent TransactionEvent) {
        super.afterRollback(TransactionEvent);
        if (this.currentRowKey != null) {
            Key k = new Key(this.currentRowKey.getAttributeValues());
            Row[] found = null;
            boolean fired = false;
            executeQuery();
            try {
                found = findByKey(k, 1);
            } catch (Exception e) {
                fired = true;
                e.printStackTrace();
            }
            if ((fired) || ((found != null) && (found.length == 1))) {
                Row r = getRow(k);
                if (r != null) {
                    setCurrentRow(r);
                    if (this.currentRowIndexInRange >= 0) {
                        scrollRangeTo(r, this.currentRowIndexInRange);
                    }
                }
            }
        }
        this.currentRowKey = null;
    }

    protected void create() {
        super.create();
        setManageRowsByKey(true);
    }

    protected void bindParametersForCollection(QueryCollection qc, Object[] params,
                                               PreparedStatement stmt) throws SQLException {
        if (this.logEnabled) {
            logQueryStatementAndBindParameters(qc, params);
        }
        super.bindParametersForCollection(qc, params, stmt);
    }

    private void logQueryStatementAndBindParameters(QueryCollection qc, Object[] params) {
        String vrsiName = null;
        if (qc != null) {
            ViewRowSetImpl vrsi = qc.getRowSetImpl();
            vrsiName = vrsi.isDefaultRS() ? "<Default>" : vrsi.getName();
        }
        String voName = getName();
        String voDefName = getDefFullName();
        if (qc != null) {
            _logger.info("----[Exec query for VO=" + voName + ", RS=" + vrsiName + "]----");
        } else {
            _logger.info("----[Exec COUNT query for VO=" + voName + "]----");
        }
        _logger.info("VODef =" + voDefName);
        ViewCriteria[] appliedCriterias = getApplyViewCriterias(ViewCriteria.CRITERIA_MODE_QUERY);
        if ((appliedCriterias != null) && (appliedCriterias.length > 0)) {
            StringBuilder sb = new StringBuilder();
            int criteriaCount = 0;
            for (ViewCriteria vc : appliedCriterias) {
                if (criteriaCount++ > 0) {
                    sb.append(",");
                }
                sb.append(vc.getName());
            }
            _logger.info("Applied Database VCs = (" + sb + ")");
        }
        appliedCriterias = getApplyViewCriterias(ViewCriteria.CRITERIA_MODE_CACHE);
        if ((appliedCriterias != null) && (appliedCriterias.length > 0)) {
            StringBuilder sb = new StringBuilder();
            int criteriaCount = 0;
            for (ViewCriteria vc : appliedCriterias) {
                if (criteriaCount++ > 0) {
                    sb.append(",");
                }
                sb.append(vc.getName());
            }
            _logger.info("Applied In-Memory VCs = (" + sb + ")");
        }
        appliedCriterias = getApplyViewCriterias(ViewCriteria.CRITERIA_MODE_QUERY | ViewCriteria.CRITERIA_MODE_CACHE);
        if ((appliedCriterias != null) && (appliedCriterias.length > 0)) {
            StringBuilder sb = new StringBuilder();
            int criteriaCount = 0;
            for (ViewCriteria vc : appliedCriterias) {
                if (criteriaCount++ > 0) {
                    sb.append(",");
                }
                sb.append(vc.getName());
            }
            _logger.info("Applied 'Both' VCs = (" + sb + ")");
        }
        _logger.info("\t\t" + getQuery());
        if ((params != null) && (getBindingStyle() == 2)) {
            StringBuilder binds = new StringBuilder("BindVars:(");
            int paramNum = 0;
            for (Object param : params) {
                paramNum++;
                Object[] nameValue = (Object[]) param;
                String name = (String) nameValue[0];
                Object value = nameValue[1];
                if (paramNum > 1) {
                    binds.append(",");
                }
                binds.append(name).append("=").append(value);
            }
            binds.append(")");
            _logger.info(binds.toString());
        }
    }

    protected ViewRowImpl createRowFromResultSet(Object object, ResultSet resultSet) {
        ViewRowImpl ret = super.createRowFromResultSet(object, resultSet);
        if ((ret != null) && (this.logEnabled)) {
            _logger.info("----[VO " + getName() + " fetched " + ret.getKey() + "]");
        }
        return ret;
    }

    protected void enableLogging() {
        this.logEnabled = true;
    }

    public AttributeList copyRow(Row currentRow, ArrayList<String> attrsToCopy) {
        AttributeList attributeList = new NameValuePairs();
        ArrayList<String> attFound = new ArrayList();
        if (currentRow != null) {
            for (String attToCopy : attrsToCopy) {
                for (String allAttrs : currentRow.getAttributeNames()) {
                    if (attToCopy.equalsIgnoreCase(allAttrs)) {
                        attFound.add(attToCopy);
                    }
                }
            }
            for (String att : attFound) {
                attributeList.setAttribute(att, currentRow.getAttribute(att));
            }
        } else {
            throw new JboException("Input Row is null. nothing will be copied.");
        }
        return attributeList;
    }

    public void requeryAndReturnToCurrentRow() {
        CoreViewRowImpl currentRow = (CoreViewRowImpl) getCurrentRow();
        ApplicationModuleImpl am = (ApplicationModuleImpl) getApplicationModule();
        if (currentRow != null) {
            Key currentRowKey = currentRow.getKey();
            int rangePosOfCurrentRow = getRangeIndexOf(currentRow);
            int rangeStartBeforeQuery = getRangeStart();

            executeQuery();

            setRangeStart(rangeStartBeforeQuery);
            findAndSetCurrentRowByKey(currentRowKey, rangePosOfCurrentRow);
        }
    }

    public void setViewCriteriaAutoExecute(Boolean autoExecute, String viewCriteria) {
        ViewCriteriaManager vcm = getViewCriteriaManager();
        ViewCriteria vc = vcm.getViewCriteria(viewCriteria);
        vc.resetCriteria();
        vc.setProperty("autoExecute", autoExecute);
        vc.saveState();
    }

    protected void executeQueryForCollection(Object object, Object[] object2, int i) {
        if ((isFilterQuery()) && (getEstimatedRowCount() > this.maxRows)) {
            if ((object2 != null) || (i > 0)) {
                throw new JboException("Please refine filter, as the query is returning too many rows", "PITWARN",
                                       null);
            }
        } else {
            super.executeQueryForCollection(object, object2, i);
        }
    }

    private void setFilterQuery(boolean filterQuery) {
        this.filterQuery = filterQuery;
    }

    private boolean isFilterQuery() {
        return this.filterQuery;
    }

    private void setMaxRows(int maxRows) {
        this.maxRows = maxRows;
    }

    private int getMaxRows() {
        return this.maxRows;
    }

    public void enableQueryLimit(boolean filterQuery, int maxRows) {
        setMaxRows(maxRows);
        setFilterQuery(filterQuery);
    }

    public void refreshCurrentRow() {
        Row currRow = getCurrentRow();
        if (currRow != null) {
            currRow.refresh(0xA | 0x0);
        }
    }
}
