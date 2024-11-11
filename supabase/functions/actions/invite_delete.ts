import { supabase } from "../_shared/supabase_client.ts";
import type { User } from "@supabase/supabase-js";
import { getUserRole } from "../_shared/get_user_role.ts";
// import type { Invite } from "$lib/services/inviteService.svelte.ts";
interface Payload {
    id: string | null;
}
export const invite_delete = async (
    payload: Payload,
    user: User | null,
): Promise<{ data: unknown; error: unknown | null }> => {
    console.log("invite_delete payload", payload);
    console.log("invite_delete user", user);
    try {
        const id = payload.id;
        if (!id) {
            return { data: null, error: "id not found" };
        }

        // check to make sure the user is the owner of the orgs_invites row
        const { data: inviteOwnerData, error: inviteOwnerError } =
            await supabase
                .from("orgs_invites")
                .select("owner")
                .eq("id", id)
                .single();

        if (inviteOwnerError) {
            return { data: null, error: inviteOwnerError.message };
        }
        if (!user) {
            return { data: null, error: "User not found" };
        }
        if (inviteOwnerData.owner !== user.id) {
            return {
                data: null,
                error: "User is not the owner of this invite",
            };
        }
        // Insert new orgs_users row
        const { data: deleteData, error: deleteError } = await supabase
            .from("orgs_invites")
            .delete()
            .eq("id", id)
            .select();

        if (deleteError) {
            return { data: null, error: deleteError.message };
        } else {
            return { data: deleteData, error: null };
        }
    } catch (err) {
        return { data: null, error: err };
    }
};
