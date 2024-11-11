import type { Database } from "$lib/types/database.types";
import { supabase } from "./backend.svelte.ts";
export type Invite = Database["public"]["Tables"]["orgs_invites"]["Row"];

export const createInvite = async (invite: Invite) => {
};
