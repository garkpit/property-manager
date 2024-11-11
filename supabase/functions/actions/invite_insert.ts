import { supabase } from "../_shared/supabase_client.ts";
import type { User } from "@supabase/supabase-js";
import { getUserRole } from "../_shared/get_user_role.ts";
import type { Invite } from "$lib/services/inviteService.svelte.ts";
interface Payload {
    id: string | null;
    invite: Invite;
}
export const invite_insert = async (
    payload: Payload,
    user: User | null,
): Promise<{ data: unknown; error: unknown | null }> => {
    console.log("invite_insert payload", payload);
    console.log("invite_insert user", user);
    try {
        if (!user) {
            return { data: null, error: "User not found" };
        }
        // Get the title from the request body
        const id = payload.id;
        const invite = payload.invite;
        if (!invite.orgid) {
            return { data: null, error: "orgid is required" };
        }

        // check to make sure the user is an owner of the org
        const { data: userRole, error: userRoleError } = await getUserRole(
            invite.orgid,
            user.id,
        );
        if (userRoleError) {
            return { data: null, error: userRoleError };
        }
        if (userRole !== "Owner") {
            return {
                data: null,
                error: "User is not an owner of the organization",
            };
        }
        if (!invite.email) {
            return { data: null, error: "email is required" };
        }
        // make sure email is a valid email
        if (!invite.user_role) {
            return { data: null, error: "user_role is required" };
        }
        // make sure user_role is a valid user role
        if (
            invite.user_role !== "Owner" &&
            invite.user_role !== "Admin" &&
            invite.user_role !== "Member" &&
            invite.user_role !== "Read Only"
        ) {
            return { data: null, error: "user_role is not valid" };
        }

        // Insert new orgs_users row
        const { data: insertData, error: insertError } = await supabase
            .from("orgs_users")
            .insert({
                orgid: invite.orgid,
                owner: user.id,
                email: invite.email,
                user_role: invite.user_role,
                metadata: invite.metadata || {},
            })
            .select()
            .single();

        if (insertError) {
            return { data: null, error: insertError };
        } else {
            return { data: insertData, error: null };
        }
    } catch (err) {
        return { data: null, error: err };
    }
};
