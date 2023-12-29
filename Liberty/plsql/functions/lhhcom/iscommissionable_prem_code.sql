CREATE or REPLACE FUNCTION iscommissionable_prem_code
                           (p_code           IN  VARCHAR2
                           ,p_date           IN  DATE     DEFAULT SYSDATE
                           ,p_country        IN  VARCHAR2 DEFAULT NULL)
                           RETURN                VARCHAR2

/**
* <pre>
* ----------------------------------------------------------------------
* Project:     : Commission Self Build
*
*                Description  : Functions used to check if a Premium Code is Commissionable or Not
*                File Name    : Liberty\plsql\functions\lhhcom\iscommissionable_prem_code.sql
*                Author       : Sarel Eybers
*                Requirements : Access to account SCHEMA
*                Call Syntax  : F5 to Compile Function
*
*                Amendments   :
*                Date        User     Change Description
*                ========    ======== =================================================
*                2018/12/12  Sarel    Created (LS-2207)
* </pre>         */

IS

  v_count          NUMBER(2);
  
BEGIN
  v_count := NULL;
  -- Check Code, Date and Country for 'N'
  BEGIN
    SELECT count(*)
      INTO v_count
      FROM globaltemp_json_workspace j
     WHERE     j.interface = 'commissionsht'
           AND TRIM(j.data.CODE.code) = TRIM(p_code)
           AND p_date BETWEEN TO_DATE(NVL(j.data.startDate, '2000-01-01'), 'YYYY-MM-DD')
                           AND TO_DATE(NVL(j.data.endDate, '3100-01-31'), 'YYYY-MM-DD')
           AND j.data.COUNTRY.code IS NOT NULL
           AND TRIM(j.data.COUNTRY.code) = TRIM(p_country)
           AND j.data.COMCALC.code = 'N';
    IF v_count > 1 THEN
      RETURN 'No' || v_count;
    ELSIF v_count = 1 THEN
      RETURN 'No';
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END;
  -- Check Code, Date and Country for 'Y'
  BEGIN
    SELECT count(*)
      INTO v_count
      FROM globaltemp_json_workspace j
     WHERE     j.interface = 'commissionsht'
           AND TRIM(j.data.CODE.code) = TRIM(p_code)
           AND p_date BETWEEN TO_DATE(NVL(j.data.startDate, '2000-01-01'), 'YYYY-MM-DD')
                           AND TO_DATE(NVL(j.data.endDate, '3100-01-31'), 'YYYY-MM-DD')
           AND j.data.COUNTRY.code IS NOT NULL
           AND TRIM(j.data.COUNTRY.code) = TRIM(p_country)
           AND j.data.COMCALC.code = 'Y';
    IF v_count > 1 THEN
      RETURN 'Yes' || v_count;
    ELSIF v_count = 1 THEN
      RETURN 'Yes';
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END;
  -- Check Code and Date for 'N'
  BEGIN
    SELECT count(*)
      INTO v_count
      FROM globaltemp_json_workspace j
     WHERE     j.interface = 'commissionsht'
           AND TRIM(j.data.CODE.code) = TRIM(p_code)
           AND p_date BETWEEN TO_DATE(NVL(j.data.startDate, '2000-01-01'), 'YYYY-MM-DD')
                           AND TO_DATE(NVL(j.data.endDate, '3100-01-31'), 'YYYY-MM-DD')
           AND j.data.COUNTRY.code IS NULL
           AND j.data.COMCALC.code = 'N';
    IF v_count > 1 THEN
      RETURN 'No' || v_count;
    ELSIF v_count = 1 THEN
      RETURN 'No';
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END;
  -- Check Code and Date for 'Y'
  BEGIN
    SELECT count(*)
      INTO v_count
      FROM globaltemp_json_workspace j
     WHERE     j.interface = 'commissionsht'
           AND TRIM(j.data.CODE.code) = TRIM(p_code)
           AND p_date BETWEEN TO_DATE(NVL(j.data.startDate, '2000-01-01'), 'YYYY-MM-DD')
                           AND TO_DATE(NVL(j.data.endDate, '3100-01-31'), 'YYYY-MM-DD')
           AND j.data.COUNTRY.code IS NULL
           AND j.data.COMCALC.code = 'Y';
    IF v_count > 1 THEN
      RETURN 'Yes' || v_count;
    ELSIF v_count = 1 THEN
      RETURN 'Yes';
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END;
  RETURN 'Missing';
END iscommissionable_prem_code;

/

/* Ad Hoc Code
-- Run to check a code
SET SERVEROUTPUT ON;
DECLARE
BEGIN
  lhhcom.refresh_pay_comms;
  dbms_output.put_line('Is FUNL/UG/today commissionable? ' || lhhcom.iscommissionable_prem_code('FUNL', SYSDATE, 'UG'));
  dbms_output.put_line('Is FUNL/UG/2015  commissionable? ' || lhhcom.iscommissionable_prem_code('FUNL', to_date('2015/06/30', 'YYYY/MM/DD'), 'UG'));
  dbms_output.put_line('Is FUNL/NG/today commissionable? ' || lhhcom.iscommissionable_prem_code('FUNL', SYSDATE, 'NG'));
  dbms_output.put_line('Is LSCD/LS/today commissionable? ' || lhhcom.iscommissionable_prem_code('LSCD', SYSDATE, 'LS'));
  dbms_output.put_line('Is ACQ /UG/today commissionable? ' || lhhcom.iscommissionable_prem_code('ACQ ', SYSDATE, 'UG'));
  dbms_output.put_line('Is ACQ /NG/today commissionable? ' || lhhcom.iscommissionable_prem_code('ACQ ', SYSDATE, 'NG'));
  dbms_output.put_line('Is ACQ /  /today commissionable? ' || lhhcom.iscommissionable_prem_code('ACQ'));
  dbms_output.put_line('Is SUPL/UG/today commissionable? ' || lhhcom.iscommissionable_prem_code('SUPL', SYSDATE, 'UG'));
  dbms_output.put_line('Is SUPL/UG/2015  commissionable? ' || lhhcom.iscommissionable_prem_code('SUPL', to_date('2015/06/30', 'YYYY/MM/DD'), 'UG'));
  dbms_output.put_line('Is SUPL/LS/today commissionable? ' || lhhcom.iscommissionable_prem_code('SUPL', SYSDATE, 'LS'));
  dbms_output.put_line('Is SUPL/LS/2015  commissionable? ' || lhhcom.iscommissionable_prem_code('SUPL', to_date('2015/06/30', 'YYYY/MM/DD'), 'LS'));
END;

-- */