import type { Database } from "$lib/types/database.types";
import { supabase } from "./backend.svelte.ts";
export type Invite = Database["public"]["Tables"]["orgs_invites"]["Row"];

export const getInvites = async (orgid: string) => {
    const { data, error } = await supabase.from("orgs_invites").select("*").eq(
        "orgid",
        orgid,
    );
    return { data, error };
};
export const createInvite = async (invite: Invite) => {
};
