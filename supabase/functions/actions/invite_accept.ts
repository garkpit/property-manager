import { supabase } from "../_shared/supabase_client.ts";
import type { User } from "@supabase/supabase-js";

interface Payload {
    id: string | null;
}

export const invite_accept = async (
    payload: Payload,
    user: User | null,
): Promise<{ data: unknown; error: unknown | null }> => {
    try {
        const id = payload.id;
        if (!id) {
            return { data: null, error: "id not found" };
        }

        if (!user) {
            return { data: null, error: "User not found" };
        }

        // Check if the invite exists and get its details
        const { data: inviteData, error: inviteError } = await supabase
            .from("orgs_invites")
            .select("*")
            .eq("id", id)
            .eq("invitee", user.id)
            .single();

        if (inviteError) {
            return { data: null, error: inviteError.message };
        }

        if (!inviteData) {
            return { data: null, error: "Invite not found or not for this user" };
        }

        // Start a transaction by creating the orgs_users record
        const { data: orgUserData, error: orgUserError } = await supabase
            .from("orgs_users")
            .insert({
                org_id: inviteData.org_id,
                user_id: user.id,
                user_role: inviteData.user_role,
            })
            .select()
            .single();

        if (orgUserError) {
            return { data: null, error: orgUserError.message };
        }

        // If successful, delete the invitation
        const { error: deleteError } = await supabase
            .from("orgs_invites")
            .delete()
            .eq("id", id);

        if (deleteError) {
            // If we can't delete the invite, we should probably clean up the orgs_users record
            // to maintain data consistency
            await supabase
                .from("orgs_users")
                .delete()
                .eq("org_id", inviteData.org_id)
                .eq("user_id", user.id);
            return { data: null, error: deleteError.message };
        }

        return { data: orgUserData, error: null };
    } catch (err) {
        return { data: null, error: err };
    }
};
