import { supabase } from "../_shared/supabase_client.ts";
import type { User } from "@supabase/supabase-js";
interface Payload {
    title: string;
}
export const org_create = async (
    payload: Payload,
    user: User | null,
): Promise<{ data: unknown; error: unknown | null }> => {
    console.log("org_create payload", payload);
    console.log("org_create user", user);
    try {
        if (!user) {
            return { data: null, error: "User not found" };
        }
        // Get the title from the request body
        const title = payload.title;

        // Insert new org
        const { data: orgData, error: orgError } = await supabase
            .from("orgs")
            .insert({ title })
            .select()
            .single();

        if (orgError) {
            return { data: null, error: orgError };
        }

        // Insert new orgs_users row
        const { data: orgUserData, error: orgUserError } = await supabase
            .from("orgs_users")
            .insert({
                orgid: orgData.id,
                userid: user.id,
                user_role: "Owner",
            })
            .select()
            .single();

        if (orgUserError) {
            return { data: null, error: orgUserError };
        }

        // Your org creation logic here
        return { data: orgUserData, error: null };
    } catch (err) {
        return { data: null, error: err };
    }
};
