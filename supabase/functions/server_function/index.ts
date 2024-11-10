import { corsHeaders } from "../_shared/cors.ts";
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { supabase } from "../_shared/supabase_client.ts";
import { getUser } from "../_shared/get_user.ts";

Deno.serve(async (req) => {
    // This is needed if you're planning to invoke your function from a browser.
    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: corsHeaders });
    }

    try {
        // Get the Authorization header from the request
        const authHeader = req.headers.get("Authorization");
        if (!authHeader) {
            throw new Error("Missing Authorization header");
        }

        const { user, authError } = await getUser(req);
        if (authError) {
            throw new Error(authError.message);
        }
        console.log("user", user);

        // call functions here...

        const data = {};
        const error = null;

        return new Response(
            JSON.stringify({ data, error }),
            {
                headers: { ...corsHeaders, "Content-Type": "application/json" },
                status: 200,
            },
        );
    } catch (err) {
        console.error("Function error in try/catch block:", err);
        let message = "unknown error";
        if (err instanceof Error) {
            message = err.message;
        }
        return new Response(
            JSON.stringify({ data: null, error: message }),
            {
                headers: { ...corsHeaders, "Content-Type": "application/json" },
                status: message === "Unauthorized" ? 401 : 500,
            },
        );
    }
});
