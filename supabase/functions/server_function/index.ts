import "jsr:@supabase/functions-js/edge-runtime.d.ts";
// import type { User } from "@supabase/supabase-js";
import { corsHeaders } from "../_shared/cors.ts";
import { getUser } from "../_shared/get_user.ts";

import { org_delete } from "../actions/org_delete.ts";
import { org_upsert } from "../actions/org_upsert.ts";

const actions = {
    org_delete,
    org_upsert,
} as const;

type ActionKey = keyof typeof actions;

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
        const body = await req.json();

        if (typeof body.action !== "string" || !(body.action in actions)) {
            throw new Error("Missing or invalid action parameter");
        }
        if (typeof body.payload !== "object") {
            throw new Error("Missing or invalid payload parameter");
        }

        // const { data, error } = await executeAction(action, payload, user);
        const { data, error } = await actions[body.action as ActionKey](
            body.payload,
            user,
        );

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
