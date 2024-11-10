-- Function to delete an organization and all related data
CREATE OR REPLACE FUNCTION delete_org_user(orgs_users_id uuid)
    RETURNS VOID
    AS $$
BEGIN
    -- Delete the organization and let cascading constraints handle related data
    DELETE FROM orgs_users
    WHERE id = orgs_users_id;
    -- If the deletion was successful, commit the transaction
    IF FOUND THEN
        RAISE NOTICE 'orgs_users with id % has been deleted along with all related data.', orgs_users_id;
    ELSE
        RAISE EXCEPTION 'orgs_users with id % not found.', orgs_users_id;
    END IF;
END;
$$
LANGUAGE plpgsql
SECURITY DEFINER;

-- Revoke execute permissions from anon and authenticated roles
REVOKE EXECUTE ON FUNCTION delete_org_user(UUID) FROM anon, authenticated;

-- Grant execute permissions to a specific role (e.g., admin_role)
-- Uncomment and modify the following line if you want to grant access to a specific role
-- GRANT EXECUTE ON FUNCTION delete_org(UUID) TO admin_role;
-- Add a comment to the function
COMMENT ON FUNCTION delete_org_user(UUID) IS 'Deletes an orgs_users record and all its related data. This function should only be accessible to highly privileged roles.';

