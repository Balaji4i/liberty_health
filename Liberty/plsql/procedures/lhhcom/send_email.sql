create or replace PROCEDURE        LHHCOM.SEND_EMAIL(
                                       p_from      VARCHAR2    DEFAULT get_system_parameter('LB_HEALTH_COMMS','COMMS_COMMUNICATE','EMAIL_COMMS'),
                                       p_to        VARCHAR2    DEFAULT get_system_parameter('LB_HEALTH_COMMS','COMMS_COMMUNICATE','EMAIL_COMMS'),
                                       p_subject   VARCHAR2    DEFAULT 'Notification from Commissions Self-Build',
                                       p_message   VARCHAR2,
                                       p_mime_type VARCHAR2    DEFAULT 'text/html',
                                       p_reply_to  VARCHAR2    DEFAULT get_system_parameter('LB_HEALTH_COMMS','COMMS_COMMUNICATE','EMAIL_COMMS')
                                       ) AS   
    /**
    * <pre>
    * ----------------------------------------------------------------------
    * Project:     : Commission Self Build SEND_EMAIL
    *
    *                Description  : Procedure to send emails to the commissions team - email stored in get_system_parameter('LB_HEALTH_COMMS','COMMS_COMMUNICATE','EMAIL_COMMS')
    *                File Name    : Liberty\plsql\procedures\lhhcom\SEND_EMAIL.sql
    *
    *                Amendments   :
    *                Date        User     Change Version      Change Description
    *                ========    ======== ==============      =================================================
    *                2019/07/22  T.Percy   1.0                Initial Version for sending of emails to notify commissions team of important processes.
   **/
    l_db_name     global_name.global_name%TYPE;
    l_send        BOOLEAN DEFAULT FALSE;

BEGIN
    
    
    SELECT global_name 
      INTO l_db_name 
      FROM global_name;


  IF l_db_name LIKE '%DEV%' THEN -- dev

     l_send := FALSE;

  ELSIF l_db_name LIKE '%UAT%' THEN-- uat

      l_send := FALSE;

  ELSIF  l_db_name LIKE '%PREP%' THEN--preprod

     l_send := FALSE;

  ELSIF  l_db_name LIKE '%TST%' THEN--test

    l_send := FALSE;

  ELSIF  l_db_name LIKE '%PRD%' THEN --test

     l_send := TRUE;

  END IF;  


  begin
    
    IF l_send THEN
  
            utl_mail.send(sender     => p_from,
                          recipients => p_to,
                        --  cc         => p_cc,
                        --  bcc        => p_bcc,
                          subject    => p_subject,
                          message    => p_message,
                          mime_type  => p_mime_type,
                          priority   => 1,
                          replyto    => p_reply_to);
    END IF;
 end;                         
END SEND_EMAIL;
/