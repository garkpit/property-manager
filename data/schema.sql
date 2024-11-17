

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



CREATE OR REPLACE FUNCTION "public"."get_my_orgids"() RETURNS TABLE("orgid" "uuid")
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    ou.orgid
  FROM
    public.orgs_users AS ou
  WHERE
    ou.userid = auth.uid();
END;
$$;


ALTER FUNCTION "public"."get_my_orgids"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_my_orgs"() RETURNS TABLE("id" "uuid", "title" "text", "created_at" timestamp with time zone, "metadata" "jsonb", "user_role" "text")
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    orgs.id,
    orgs.title,
    orgs.created_at,
    orgs.metadata,
    orgs_users.user_role
  FROM
    orgs
    JOIN orgs_users ON orgs.id = orgs_users.orgid
  WHERE
    orgs_users.userid = auth.uid();
END;
$$;


ALTER FUNCTION "public"."get_my_orgs"() OWNER TO "postgres";


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



CREATE OR REPLACE FUNCTION "public"."get_user_orgids"("p_userid" "uuid") RETURNS TABLE("orgid" "uuid")
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    ou.orgid
  FROM
    public.orgs_users AS ou
  WHERE
    ou.userid = p_userid;
END;
$$;


ALTER FUNCTION "public"."get_user_orgids"("p_userid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  INSERT INTO public.profiles (id, email)
  VALUES (NEW.id, NEW.email);
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


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
    "sender" "uuid",
    "sender_type" "text",
    "subject" "text",
    "message" "text",
    "metadata" "jsonb",
    "sender_deleted_at" timestamp with time zone
);


ALTER TABLE "public"."messages" OWNER TO "postgres";


COMMENT ON TABLE "public"."messages" IS 'Messages between users';



CREATE TABLE IF NOT EXISTS "public"."messages_recipients" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "recipient" "uuid",
    "deleted_at" timestamp with time zone,
    "read_at" timestamp with time zone,
    "messageid" "uuid"
);


ALTER TABLE "public"."messages_recipients" OWNER TO "postgres";


COMMENT ON TABLE "public"."messages_recipients" IS 'Recipent of a message';



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



CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "email" "text" NOT NULL,
    "metadata" "jsonb",
    "firstname" "text",
    "lastname" "text",
    "bio" "text"
);


ALTER TABLE "public"."profiles" OWNER TO "postgres";


COMMENT ON TABLE "public"."profiles" IS 'User profiles';



CREATE TABLE IF NOT EXISTS "public"."properties" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "transaction_type" "text",
    "property_type" "text",
    "property_subtype" "text",
    "address" "text",
    "address2" "text",
    "city" "text",
    "region" "text",
    "postal" "text",
    "country" "text",
    "lat" numeric,
    "lng" numeric,
    "status" "text",
    "list_price" numeric,
    "list_date" timestamp with time zone,
    "closing_price" numeric,
    "closing_date" timestamp with time zone,
    "beds" numeric,
    "baths" numeric,
    "living_area" numeric,
    "land_area" numeric,
    "year_built" numeric,
    "hoa_fees" numeric,
    "notes" "text",
    "metadata" "jsonb",
    "orgid" "uuid" NOT NULL,
    "userid" "uuid" NOT NULL
);


ALTER TABLE "public"."properties" OWNER TO "postgres";


COMMENT ON TABLE "public"."properties" IS 'Properties for sale or rent';



ALTER TABLE ONLY "public"."contacts"
    ADD CONSTRAINT "contacts_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."messages_recipients"
    ADD CONSTRAINT "messages_recipients_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."orgs_invites"
    ADD CONSTRAINT "orgs_invites_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."orgs"
    ADD CONSTRAINT "orgs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."orgs_users"
    ADD CONSTRAINT "orgs_users_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profile_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."properties"
    ADD CONSTRAINT "properties_pkey" PRIMARY KEY ("id");



CREATE INDEX "orgs_users_orgid_idx" ON "public"."orgs_users" USING "btree" ("orgid");



CREATE INDEX "orgs_users_userid_idx" ON "public"."orgs_users" USING "btree" ("userid");



ALTER TABLE ONLY "public"."contacts"
    ADD CONSTRAINT "contacts_authid_fkey" FOREIGN KEY ("authid") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."contacts"
    ADD CONSTRAINT "contacts_orgid_fkey" FOREIGN KEY ("orgid") REFERENCES "public"."orgs"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."messages_recipients"
    ADD CONSTRAINT "messages_recipients_messageid_fkey" FOREIGN KEY ("messageid") REFERENCES "public"."messages"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."messages_recipients"
    ADD CONSTRAINT "messages_recipients_recipient_fkey" FOREIGN KEY ("recipient") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."messages_recipients"
    ADD CONSTRAINT "messages_recipients_recipient_fkey1" FOREIGN KEY ("recipient") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_sender_fkey" FOREIGN KEY ("sender") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."orgs_invites"
    ADD CONSTRAINT "orgs_invites_orgid_fkey" FOREIGN KEY ("orgid") REFERENCES "public"."orgs"("id");



ALTER TABLE ONLY "public"."orgs_invites"
    ADD CONSTRAINT "orgs_invites_owner_fkey2" FOREIGN KEY ("owner") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."orgs_users"
    ADD CONSTRAINT "orgs_users_orgid_fkey" FOREIGN KEY ("orgid") REFERENCES "public"."orgs"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."orgs_users"
    ADD CONSTRAINT "orgs_users_userid_fkey" FOREIGN KEY ("userid") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profile_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."properties"
    ADD CONSTRAINT "properties_orgid_fkey" FOREIGN KEY ("orgid") REFERENCES "public"."orgs"("id");



ALTER TABLE ONLY "public"."properties"
    ADD CONSTRAINT "properties_userid_fkey" FOREIGN KEY ("userid") REFERENCES "public"."profiles"("id");



CREATE POLICY "Insert - user must be sender" ON "public"."messages" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "sender"));



CREATE POLICY "Profiles are created automatically by trigger" ON "public"."profiles" FOR INSERT WITH CHECK (false);



CREATE POLICY "TEMPORARY - open viewing" ON "public"."orgs" FOR SELECT USING (true);



CREATE POLICY "User must belong to org" ON "public"."contacts" TO "authenticated" USING ((( SELECT "public"."get_org_role"("contacts"."orgid") AS "get_org_role") IS NOT NULL)) WITH CHECK ((( SELECT "public"."get_org_role"("contacts"."orgid") AS "get_org_role") IS NOT NULL));



CREATE POLICY "anyone can view" ON "public"."properties" FOR SELECT USING (true);



ALTER TABLE "public"."contacts" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "deletion not allowed" ON "public"."properties" FOR DELETE USING (false);



CREATE POLICY "insert: userid and orgid required" ON "public"."properties" FOR INSERT WITH CHECK ((("userid" = "auth"."uid"()) AND ("orgid" IN ( SELECT "orgs_users"."orgid"
   FROM "public"."orgs_users"
  WHERE ("orgs_users"."userid" = "auth"."uid"())))));



ALTER TABLE "public"."messages" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."messages_recipients" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "must be sender to delete" ON "public"."messages" FOR DELETE USING (("sender" = ( SELECT "auth"."uid"() AS "uid")));



CREATE POLICY "must be sender to update" ON "public"."messages" FOR UPDATE USING (("sender" = ( SELECT "auth"."uid"() AS "uid"))) WITH CHECK (("sender" = ( SELECT "auth"."uid"() AS "uid")));



CREATE POLICY "org owners can create invites" ON "public"."orgs_invites" FOR INSERT TO "authenticated" WITH CHECK (((( SELECT "public"."get_org_role"("orgs_invites"."orgid") AS "get_org_role") = 'Owner'::"text") AND ("owner" = ( SELECT "auth"."uid"() AS "uid"))));



CREATE POLICY "org owners can updated policies they created" ON "public"."orgs_invites" FOR UPDATE TO "authenticated" USING (((( SELECT "public"."get_org_role"("orgs_invites"."orgid") AS "get_org_role") = 'Owner'::"text") AND ("owner" = ( SELECT "auth"."uid"() AS "uid")))) WITH CHECK (((( SELECT "public"."get_org_role"("orgs_invites"."orgid") AS "get_org_role") = 'Owner'::"text") AND ("owner" = ( SELECT "auth"."uid"() AS "uid"))));



CREATE POLICY "org role must be Owner or Manager" ON "public"."properties" FOR UPDATE USING (("public"."get_org_role_for_user"("orgid", "userid") = ANY (ARRAY['Owner'::"text", 'Manager'::"text"]))) WITH CHECK (("public"."get_org_role_for_user"("orgid", "userid") = ANY (ARRAY['Owner'::"text", 'Manager'::"text"])));



ALTER TABLE "public"."orgs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."orgs_invites" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."orgs_users" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "owner or invitee can delete an invite" ON "public"."orgs_invites" FOR DELETE TO "authenticated" USING ((("owner" = ( SELECT "auth"."uid"() AS "uid")) OR ("email" = ( SELECT "auth"."email"() AS "uid"))));



CREATE POLICY "owner or invitee can view invite" ON "public"."orgs_invites" FOR SELECT TO "authenticated" USING ((("owner" = ( SELECT "auth"."uid"() AS "uid")) OR ("email" = ( SELECT "auth"."email"() AS "email"))));



ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "profiles cannot be deleted" ON "public"."profiles" FOR DELETE USING (false);



ALTER TABLE "public"."properties" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "recipient can update" ON "public"."messages_recipients" FOR UPDATE USING (("recipient" = ( SELECT "auth"."uid"() AS "uid"))) WITH CHECK (("recipient" = ( SELECT "auth"."uid"() AS "uid")));



CREATE POLICY "sender can delete" ON "public"."messages_recipients" FOR SELECT USING ((( SELECT "messages"."sender"
   FROM "public"."messages"
  WHERE ("messages"."id" = "messages_recipients"."messageid")) = ( SELECT "auth"."uid"() AS "uid")));



CREATE POLICY "sender can insert" ON "public"."messages_recipients" FOR INSERT WITH CHECK ((( SELECT "messages"."sender"
   FROM "public"."messages"
  WHERE ("messages"."id" = "messages_recipients"."messageid")) = ( SELECT "auth"."uid"() AS "uid")));



CREATE POLICY "sender or recipient can select" ON "public"."messages_recipients" FOR SELECT USING (((( SELECT "messages"."sender"
   FROM "public"."messages"
  WHERE ("messages"."id" = "messages_recipients"."messageid")) = ( SELECT "auth"."uid"() AS "uid")) OR (( SELECT "auth"."uid"() AS "uid") = "recipient")));



CREATE POLICY "sender or recipients can view" ON "public"."messages" FOR SELECT USING (true);



CREATE POLICY "users can modify their own profile" ON "public"."profiles" FOR UPDATE USING (("id" = "auth"."uid"())) WITH CHECK (("id" = "auth"."uid"()));



CREATE POLICY "users can view their own profiles or those in their own orgs" ON "public"."profiles" FOR SELECT USING ((("id" = ( SELECT "auth"."uid"() AS "uid")) OR ("id" IN ( SELECT "orgs_users"."userid"
   FROM "public"."orgs_users"))));



CREATE POLICY "users can view their own records or records for orgs they belon" ON "public"."orgs_users" FOR SELECT USING ((("userid" = ( SELECT "auth"."uid"() AS "uid")) OR ("orgid" IN ( SELECT "public"."get_user_orgids"("auth"."uid"()) AS "get_user_orgids"))));



GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT ALL ON FUNCTION "public"."accept_invite"("invite_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_my_orgids"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_my_orgids"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_my_orgids"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_my_orgs"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_my_orgs"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_my_orgs"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_org_role"("org_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_org_role"("org_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_org_role"("org_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_org_role_for_user"("org_id" "uuid", "user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_org_role_for_user"("org_id" "uuid", "user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_org_role_for_user"("org_id" "uuid", "user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_org_users"("org_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_orgids"("p_userid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_orgids"("p_userid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_orgids"("p_userid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



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



GRANT ALL ON TABLE "public"."messages_recipients" TO "anon";
GRANT ALL ON TABLE "public"."messages_recipients" TO "authenticated";
GRANT ALL ON TABLE "public"."messages_recipients" TO "service_role";



GRANT ALL ON TABLE "public"."orgs" TO "anon";
GRANT ALL ON TABLE "public"."orgs" TO "authenticated";
GRANT ALL ON TABLE "public"."orgs" TO "service_role";



GRANT ALL ON TABLE "public"."orgs_invites" TO "anon";
GRANT ALL ON TABLE "public"."orgs_invites" TO "authenticated";
GRANT ALL ON TABLE "public"."orgs_invites" TO "service_role";



GRANT ALL ON TABLE "public"."orgs_users" TO "anon";
GRANT ALL ON TABLE "public"."orgs_users" TO "authenticated";
GRANT ALL ON TABLE "public"."orgs_users" TO "service_role";



GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";



GRANT ALL ON TABLE "public"."properties" TO "anon";
GRANT ALL ON TABLE "public"."properties" TO "authenticated";
GRANT ALL ON TABLE "public"."properties" TO "service_role";



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
