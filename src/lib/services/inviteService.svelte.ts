import type { Database } from "$lib/types/database.types";
import { getUser, supabase } from "./backend.svelte.ts";
const user = $derived(getUser());
import {
    FunctionsFetchError,
    FunctionsHttpError,
    FunctionsRelayError,
} from "@supabase/supabase-js";
export type Invite = Database["public"]["Tables"]["orgs_invites"]["Insert"];

export const getPendingInviteCount = async () => {
    if (!user) {
        return { data: 0, error: "user not found" };
    }
    const { count, error } = await supabase
        .from("orgs_invites")
        .select("*", { count: "exact", head: true })
        .eq("email", user.email);
    return { data: count, error };
};
export const getInvites = async (orgid: string) => {
    const { data, error } = await supabase.from("orgs_invites").select("*").eq(
        "orgid",
        orgid,
    );
    return { data, error };
};

export const createInvite = async (
    orgid: string,
    email: string,
    user_role: string,
) => {
    try {
        const { data, error } = await supabase.functions.invoke(
            "server_function",
            {
                body: {
                    action: "invite_insert",
                    payload: {
                        orgid,
                        email,
                        user_role,
                    },
                },
            },
        );
        let errorMessage = "";
        if (!error) {
            return { data, error: null };
        } else {
            if (error instanceof FunctionsHttpError) {
                errorMessage = await error.context.json();
            } else if (error instanceof FunctionsRelayError) {
                errorMessage = error.message;
            } else if (error instanceof FunctionsFetchError) {
                errorMessage = error.message;
            }
            error.message = errorMessage;
            return { data, error };
        }
    } catch (e) {
        const error = e as Error;
        console.error("create invite unknown error", e);
        if (error) error.message = "unknown error";
        return { data: null, error };
    }
};

export const deleteInvite = async (
    id: string, // orgs_invites id
) => {
    try {
        const { data, error } = await supabase.functions.invoke(
            "server_function",
            {
                body: {
                    action: "invite_delete",
                    payload: {
                        id,
                    },
                },
            },
        );
        let errorMessage = "";
        if (!error) {
            return { data, error: null };
        } else {
            if (error instanceof FunctionsHttpError) {
                errorMessage = await error.context.json();
            } else if (error instanceof FunctionsRelayError) {
                errorMessage = error.message;
            } else if (error instanceof FunctionsFetchError) {
                errorMessage = error.message;
            }
            error.message = errorMessage;
            return { data, error };
        }
    } catch (e) {
        const error = e as Error;
        console.error("saveOrg unknown error", e);
        if (error) error.message = "unknown error";
        return { data: null, error };
    }
};
