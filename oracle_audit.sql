==================================================
-- Audit setup


-- Switched to queued-write.
BEGIN
  DBMS_AUDIT_MGMT.set_audit_trail_property(
    audit_trail_type           => DBMS_AUDIT_MGMT.audit_trail_unified,
    audit_trail_property       => DBMS_AUDIT_MGMT.audit_trail_write_mode, 
    audit_trail_property_value => DBMS_AUDIT_MGMT.audit_trail_queued_write
  );
END;
/

--Flash to disk

BEGIN
  DBMS_AUDIT_MGMT.flush_unified_audit_trail(
    flush_type => DBMS_AUDIT_MGMT.flush_current_instance,
    container  => DBMS_AUDIT_MGMT.container_current);
END;
/


-- !!!! Purge all audit records. Use with care!

BEGIN
  DBMS_AUDIT_MGMT.clean_audit_trail(
   audit_trail_type        => DBMS_AUDIT_MGMT.audit_trail_unified,
   use_last_arch_timestamp => FALSE);
END;
/



-- Set the last archive timestamp.

BEGIN
  DBMS_AUDIT_MGMT.set_last_archive_timestamp(
    audit_trail_type     => DBMS_AUDIT_MGMT.audit_trail_unified,
    last_archive_time    => SYSTIMESTAMP-7,
    --rac_instance_number  =>  1,
    container            => DBMS_AUDIT_MGMT.container_current
  );
END;
/


-- Check the new setting.

SELECT audit_trail,
       last_archive_ts
FROM   dba_audit_mgmt_last_arch_ts;

SELECT COUNT(*) FROM unified_audit_trail;


-- Purge audit records with last archive log set:

BEGIN
  DBMS_AUDIT_MGMT.clean_audit_trail(
   audit_trail_type        => DBMS_AUDIT_MGMT.audit_trail_unified,
   use_last_arch_timestamp => TRUE);
END;
/


========================================================
-- Manage audit policies


CREATE AUDIT POLICY test_audit_policy
  ACTIONS DROP TABLE,CREATE TABLE
  WHEN    'SYS_CONTEXT(''USERENV'', ''SESSION_USER'') = ''DAN'''
  EVALUATE PER SESSION
  CONTAINER = CURRENT;


AUDIT POLICY test_audit_policy;

SET LINESIZE 200
COLUMN audit_option FORMAT A15
COLUMN condition_eval_opt FORMAT A10
COLUMN audit_condition FORMAT A50

SELECT audit_option,
       condition_eval_opt,
       audit_condition
FROM   audit_unified_policies
WHERE  policy_name = 'TEST_AUDIT_POLICY';


SELECT event_timestamp,
       dbusername,
       action_name,
       object_schema,
       object_name
FROM   unified_audit_trail
WHERE  dbusername = 'DAN'
ORDER BY event_timestamp;


NOAUDIT POLICY test_audit_policy;

DROP AUDIT POLICY test_audit_policy;
