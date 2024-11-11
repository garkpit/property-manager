import { supabase } from "../_shared/supabase_client.ts";
import type { User } from "@supabase/supabase-js";
interface Payload {
    id: string;
}
export const org_delete = async (
    payload: Payload,
    user: User | null,
): Promise<{ data: unknown; error: unknown | null }> => {
    console.log("org_delete payload", payload);
    console.log("org_delete user", user);
    try {
        if (!user) {
            return { data: null, error: "User not found" };
        }
        // Get the title from the request body
        const id = payload.id;

        // Insert new org
        const { data: userRoleData, error: userRoleError } = await supabase
            .from("orgs_users")
            .select("user_role")
            .eq("orgid", id)
            .eq("userid", user.id)
            .single();
        console.log("userRoleData", userRoleData);
        console.log("userRoleError", userRoleError);
        if (userRoleError) {
            return { data: null, error: userRoleError };
        }
        if (userRoleData.user_role !== "Owner") {
            return {
                data: null,
                error: "User is not an owner of the organization",
            };
        }

        // Insert new orgs_users row
        const { data: deleteData, error: deleteError } = await supabase
            .from("orgs")
            .delete()
            .eq("id", id)
            .select()
            .single();

        if (deleteError) {
            return { data: null, error: deleteError };
        }

        return { data: deleteData, error: null };
    } catch (err) {
        return { data: null, error: err };
    }
};
