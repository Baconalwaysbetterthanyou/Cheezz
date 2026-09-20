-- Clean up existing trigger & function if re-running script
DROP TRIGGER IF EXISTS audit_daily_vitals_trigger ON daily_vitals;
DROP FUNCTION IF EXISTS log_daily_vitals_audit();

-- Safely create roles only if they do not exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'app_user') THEN
        CREATE ROLE app_user;
    END IF;

    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'auditor') THEN
        CREATE ROLE auditor;
    END IF;
END
$$;

-- Permissions for app_user
GRANT USAGE ON SCHEMA public TO app_user;
GRANT SELECT, INSERT, UPDATE ON daily_vitals, exercise_sessions, food_log TO app_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_user;

-- Permissions for auditor
GRANT USAGE ON SCHEMA public TO auditor;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO auditor;

-- Audit Function & Trigger (SECURITY DEFINER allows app_user to write to audit_log)
CREATE OR REPLACE FUNCTION log_daily_vitals_audit()
RETURNS TRIGGER 
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO audit_log (db_user, table_name, action)
    VALUES (session_user, 'daily_vitals', TG_OP);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER audit_daily_vitals_trigger
AFTER INSERT OR UPDATE OR DELETE ON daily_vitals
FOR EACH ROW
EXECUTE FUNCTION log_daily_vitals_audit();
