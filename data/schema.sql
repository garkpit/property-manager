

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "public";


ALTER SCHEMA "public" OWNER TO "pg_database_owner";


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE OR REPLACE FUNCTION "public"."accept_invite"("invite_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_org_id uuid;
    v_user_id uuid;
    v_email text;
    v_role text;
BEGIN
    -- Get the current user's ID and email
    v_user_id := auth.uid();
    v_email := auth.email();
    -- Look up the corresponding orgs_invites record
    SELECT
        orgid,
        email,
        user_role INTO v_org_id,
        v_email,
        v_role
    FROM
        public.orgs_invites
    WHERE
        id = invite_id;
    -- If invite not found, return an error
    IF v_org_id IS NULL THEN
        RAISE EXCEPTION 'Invite not found';
    END IF;
    -- Verify that the email address of the current user matches the email field of the given orgs_invites record
    IF v_email != auth.email() THEN
        RAISE EXCEPTION 'Email mismatch';
    END IF;
    -- Create an entry in the orgs_users table
    INSERT INTO public.orgs_users(orgid, userid, user_role)
        VALUES (v_org_id, v_user_id, v_role);
    -- Delete the invite record
    DELETE FROM public.orgs_invites
    WHERE id = invite_id;
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error accepting invite: %', SQLERRM;
END;

$$;


ALTER FUNCTION "public"."accept_invite"("invite_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."accept_invite"("invite_id" "uuid") IS 'Accpets an org invite, creating a user entry in the orgs_users table and deleting the orgs_invite record. This function should only be accessible to highly privileged roles.';



CREATE OR REPLACE FUNCTION "public"."get_org_role"("org_id" "uuid") RETURNS "text"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    role TEXT;
BEGIN
    SELECT user_role INTO role
    FROM orgs_users
    WHERE orgid = org_id AND userid = auth.uid();

    RETURN role;
END;
$$;


ALTER FUNCTION "public"."get_org_role"("org_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_org_role_for_user"("org_id" "uuid", "user_id" "uuid") RETURNS "text"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    ROLE TEXT;
BEGIN
    SELECT
        user_role INTO ROLE
    FROM
        orgs_users
    WHERE
        orgid = org_id
        AND userid = user_id;
    RETURN ROLE;
END;
$$;


ALTER FUNCTION "public"."get_org_role_for_user"("org_id" "uuid", "user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_org_users"("org_id" "uuid") RETURNS TABLE("id" "uuid", "created_at" timestamp with time zone, "user_role" "text", "email" character varying, "last_sign_in_at" timestamp with time zone, "raw_user_meta_data" "jsonb")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        orgs_users.id,
        orgs_users.created_at,
        orgs_users.user_role,
        auth.users.email,
        auth.users.last_sign_in_at,
        auth.users.raw_user_meta_data
    FROM
        orgs_users
        JOIN auth.users ON orgs_users.userid = auth.users.id
    WHERE
        orgs_users.orgid = org_id;
END;
$$;


ALTER FUNCTION "public"."get_org_users"("org_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_org_users"("org_id" "uuid") IS 'Gets a list of all users in an organization. This function should only be accessible to highly privileged roles.';



CREATE OR REPLACE FUNCTION "public"."is_backup_running"() RETURNS boolean
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 
    FROM pg_ls_dir('.')
    WHERE pg_ls_dir = 'backup_label'
  );
END;
$$;


ALTER FUNCTION "public"."is_backup_running"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."reject_invite"("invite_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- Delete the invite record
    DELETE FROM public.orgs_invites
    WHERE id = invite_id;
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error deleting invite: %', SQLERRM;
END;

$$;


ALTER FUNCTION "public"."reject_invite"("invite_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."reject_invite"("invite_id" "uuid") IS 'Deletes an org invite. This function should only be accessible to highly privileged roles.';


SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."contacts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "firstname" "text",
    "lastname" "text",
    "email" "text",
    "phone" "text",
    "authid" "uuid",
    "contact_type" "text",
    "notes" "text",
    "orgid" "uuid" NOT NULL
);


ALTER TABLE "public"."contacts" OWNER TO "postgres";


COMMENT ON TABLE "public"."contacts" IS 'List of Contacts (people)';



CREATE TABLE IF NOT EXISTS "public"."messages" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "read_at" timestamp with time zone,
    "sender" "uuid",
    "sender_type" "text",
    "recipient" "uuid",
    "recipient_type" "text",
    "subject" "text",
    "message" "text",
    "metadata" "jsonb",
    "sender_deleted_at" timestamp with time zone,
    "recipient_deleted_at" timestamp with time zone
);


ALTER TABLE "public"."messages" OWNER TO "postgres";


COMMENT ON TABLE "public"."messages" IS 'Messages between users';



CREATE TABLE IF NOT EXISTS "public"."orgs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "title" "text" NOT NULL,
    "metadata" "jsonb"
);


ALTER TABLE "public"."orgs" OWNER TO "postgres";


COMMENT ON TABLE "public"."orgs" IS 'Organizations';



CREATE TABLE IF NOT EXISTS "public"."orgs_invites" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "orgid" "uuid" NOT NULL,
    "owner" "uuid" NOT NULL,
    "email" "text" NOT NULL,
    "user_role" "text" NOT NULL,
    "expires_at" timestamp with time zone DEFAULT ("now"() + '7 days'::interval) NOT NULL,
    "metadata" "jsonb"
);


ALTER TABLE "public"."orgs_invites" OWNER TO "postgres";


COMMENT ON TABLE "public"."orgs_invites" IS 'pending invitations to join an org';



CREATE TABLE IF NOT EXISTS "public"."orgs_users" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "orgid" "uuid" NOT NULL,
    "userid" "uuid" NOT NULL,
    "user_role" "text" NOT NULL
);


ALTER TABLE "public"."orgs_users" OWNER TO "postgres";


COMMENT ON TABLE "public"."orgs_users" IS 'Users belong to Orgs';



ALTER TABLE ONLY "public"."contacts"
    ADD CONSTRAINT "contacts_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."orgs_invites"
    ADD CONSTRAINT "orgs_invites_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."orgs"
    ADD CONSTRAINT "orgs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."orgs_users"
    ADD CONSTRAINT "orgs_users_pkey" PRIMARY KEY ("id");



CREATE INDEX "orgs_users_orgid_idx" ON "public"."orgs_users" USING "btree" ("orgid");



CREATE INDEX "orgs_users_userid_idx" ON "public"."orgs_users" USING "btree" ("userid");



ALTER TABLE ONLY "public"."contacts"
    ADD CONSTRAINT "contacts_authid_fkey" FOREIGN KEY ("authid") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."contacts"
    ADD CONSTRAINT "contacts_orgid_fkey" FOREIGN KEY ("orgid") REFERENCES "public"."orgs"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_recipient_fkey" FOREIGN KEY ("recipient") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."orgs_invites"
    ADD CONSTRAINT "orgs_invites_orgid_fkey" FOREIGN KEY ("orgid") REFERENCES "public"."orgs"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."orgs_invites"
    ADD CONSTRAINT "orgs_invites_orgid_fkey1" FOREIGN KEY ("orgid") REFERENCES "public"."orgs"("id");



ALTER TABLE ONLY "public"."orgs_invites"
    ADD CONSTRAINT "orgs_invites_owner_fkey" FOREIGN KEY ("owner") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."orgs_invites"
    ADD CONSTRAINT "orgs_invites_owner_fkey1" FOREIGN KEY ("owner") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."orgs_users"
    ADD CONSTRAINT "orgs_users_orgid_fkey" FOREIGN KEY ("orgid") REFERENCES "public"."orgs"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."orgs_users"
    ADD CONSTRAINT "orgs_users_userid_fkey" FOREIGN KEY ("userid") REFERENCES "auth"."users"("id");



CREATE POLICY "Delete - must be recipient (or sender if not yet read)" ON "public"."messages" FOR DELETE USING ((("auth"."uid"() = "recipient") OR (("auth"."uid"() = "sender") AND ("read_at" IS NULL))));



CREATE POLICY "Insert - user must be sender" ON "public"."messages" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "sender"));



CREATE POLICY "Select - user is sender or recipient" ON "public"."messages" FOR SELECT USING ((("auth"."uid"() = "sender") OR ("auth"."uid"() = "recipient")));



CREATE POLICY "Update - user must be sender or receipient" ON "public"."messages" FOR UPDATE USING ((("auth"."uid"() = "sender") OR ("auth"."uid"() = "recipient"))) WITH CHECK ((("auth"."uid"() = "sender") OR ("auth"."uid"() = "recipient")));



CREATE POLICY "User must belong to org" ON "public"."contacts" TO "authenticated" USING ((( SELECT "public"."get_org_role"("contacts"."orgid") AS "get_org_role") IS NOT NULL)) WITH CHECK ((( SELECT "public"."get_org_role"("contacts"."orgid") AS "get_org_role") IS NOT NULL));



ALTER TABLE "public"."contacts" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."messages" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "org owners can create invites" ON "public"."orgs_invites" FOR INSERT TO "authenticated" WITH CHECK (((( SELECT "public"."get_org_role"("orgs_invites"."orgid") AS "get_org_role") = 'Owner'::"text") AND ("owner" = ( SELECT "auth"."uid"() AS "uid"))));



CREATE POLICY "org owners can updated policies they created" ON "public"."orgs_invites" FOR UPDATE TO "authenticated" USING (((( SELECT "public"."get_org_role"("orgs_invites"."orgid") AS "get_org_role") = 'Owner'::"text") AND ("owner" = ( SELECT "auth"."uid"() AS "uid")))) WITH CHECK (((( SELECT "public"."get_org_role"("orgs_invites"."orgid") AS "get_org_role") = 'Owner'::"text") AND ("owner" = ( SELECT "auth"."uid"() AS "uid"))));



ALTER TABLE "public"."orgs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."orgs_invites" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."orgs_users" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "owner or invitee can delete an invite" ON "public"."orgs_invites" FOR DELETE TO "authenticated" USING ((("owner" = ( SELECT "auth"."uid"() AS "uid")) OR ("email" = ( SELECT "auth"."email"() AS "uid"))));



CREATE POLICY "owner or invitee can view invite" ON "public"."orgs_invites" FOR SELECT TO "authenticated" USING ((("owner" = ( SELECT "auth"."uid"() AS "uid")) OR ("email" = ( SELECT "auth"."email"() AS "email"))));



CREATE POLICY "users can view orgs they belong to" ON "public"."orgs" FOR SELECT USING (("id" IN ( SELECT "orgs_users"."orgid"
   FROM "public"."orgs_users"
  WHERE ("orgs_users"."userid" = ( SELECT "auth"."uid"() AS "uid")))));



CREATE POLICY "users can view their own records" ON "public"."orgs_users" FOR SELECT USING (("userid" = "auth"."uid"()));



GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT ALL ON FUNCTION "public"."accept_invite"("invite_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_org_role"("org_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_org_role"("org_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_org_role"("org_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_org_role_for_user"("org_id" "uuid", "user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_org_role_for_user"("org_id" "uuid", "user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_org_role_for_user"("org_id" "uuid", "user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_org_users"("org_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_backup_running"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_backup_running"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_backup_running"() TO "service_role";



GRANT ALL ON FUNCTION "public"."reject_invite"("invite_id" "uuid") TO "service_role";



GRANT ALL ON TABLE "public"."contacts" TO "anon";
GRANT ALL ON TABLE "public"."contacts" TO "authenticated";
GRANT ALL ON TABLE "public"."contacts" TO "service_role";



GRANT ALL ON TABLE "public"."messages" TO "anon";
GRANT ALL ON TABLE "public"."messages" TO "authenticated";
GRANT ALL ON TABLE "public"."messages" TO "service_role";



GRANT ALL ON TABLE "public"."orgs" TO "anon";
GRANT ALL ON TABLE "public"."orgs" TO "authenticated";
GRANT ALL ON TABLE "public"."orgs" TO "service_role";



GRANT ALL ON TABLE "public"."orgs_invites" TO "anon";
GRANT ALL ON TABLE "public"."orgs_invites" TO "authenticated";
GRANT ALL ON TABLE "public"."orgs_invites" TO "service_role";



GRANT ALL ON TABLE "public"."orgs_users" TO "anon";
GRANT ALL ON TABLE "public"."orgs_users" TO "authenticated";
GRANT ALL ON TABLE "public"."orgs_users" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";






RESET ALL;
