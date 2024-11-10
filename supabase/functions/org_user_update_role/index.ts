import { createClient } from "jsr:@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!supabaseUrl || !supabaseServiceRoleKey) {
      throw new Error("Missing environment variables");
    }

    // Create Supabase client with service role key
    const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

    // Get the Authorization header from the request
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      throw new Error("Missing Authorization header");
    }

    // Verify the JWT token and get the user
    const { data: { user }, error: authError } = await supabase.auth.getUser(
      authHeader.split(" ")[1],
    );
    if (authError || !user) {
      throw new Error("Unauthorized");
    }

    // Get orgs_users_id, new_user_role from the request body
    const { orgs_users_id, new_user_role } = await req.json();

    if (!orgs_users_id) {
      throw new Error("Bad Request: orgs_users_id is required");
    }
    if (!new_user_role) {
      throw new Error("Bad Request: new_user_role is required");
    }

    // get the org for this orgs_users record
    const { data: orgData, error: orgError } = await supabase
      .from("orgs_users")
      .select("orgid")
      .eq("id", orgs_users_id)
      .single();

    if (orgError) {
      throw new Error(`Failed to get org: ${orgError.message}`);
    }
    // Check if the user is an owner of the org
    const { data: roleData, error: roleError } = await supabase
      .rpc("get_org_role_for_user", {
        org_id: orgData.orgid,
        user_id: user.id,
      });

    if (roleError) {
      throw new Error(`Failed to get user role: ${roleError.message}`);
    }

    if (roleData !== "Owner") {
      throw new Error("Forbidden: User is not an owner of the organization");
    }

    // change the user role
    const { data: updateData, error: updateError } = await supabase
      .from("orgs_users")
      .update({ user_role: new_user_role })
      .eq("id", orgs_users_id);

    if (updateData) {
      throw new Error(`Failed to update org user role: ${updateError.message}`);
    }

    return new Response(
      JSON.stringify({
        message: "User role updatedsuccessfully",
        data: updateData,
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      },
    );
  } catch (error) {
    console.error("Function error:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: error.message === "Unauthorized" ? 401 : 400,
      },
    );
  }
});
