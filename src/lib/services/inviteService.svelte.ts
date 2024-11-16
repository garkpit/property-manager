import type { Database } from "$lib/types/database.types";
import { getUser, supabase } from "./backend.svelte.ts";
const user = $derived(getUser());
import {
    FunctionsFetchError,
    FunctionsHttpError,
    FunctionsRelayError,
} from "@supabase/supabase-js";
import { handleServerFunctionResponse } from "$lib/utils/errorHandling";
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
    const response = await supabase.functions.invoke(
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
    return handleServerFunctionResponse(response);
};

export const deleteInvite = async (id: string) => {
    const response = await supabase.functions.invoke(
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
    return handleServerFunctionResponse(response);
};

export const acceptInvite = async (id: string) => {
    const response = await supabase.functions.invoke(
        "server_function",
        {
            body: {
                action: "invite_accept",
                payload: {
                    id,
                },
            },
        },
    );
    return handleServerFunctionResponse(response);
};

export const rejectInvite = async (id: string) => {
    const response = await supabase.functions.invoke(
        "server_function",
        {
            body: {
                action: "invite_reject",
                payload: {
                    id,
                },
            },
        },
    );
    return handleServerFunctionResponse(response);
};

export const getPendingInvites = async () => {
    console.log("getPendingInvites 1");
    if (!user) {
        return { data: null, error: "user not found" };
    }
    console.log("getPendingInvites 2");
    const { data, error } = await supabase
        .from("orgs_invites")
        .select(`
            id,            
            orgs (
                title
            ),
            owner:owner (
                email, firstname, lastname
            ),
            created_at
        `)
        .eq("email", user.email);
    console.log("getPendingInvites raw data:", JSON.stringify(data, null, 2));
    console.log("getPendingInvites 3, data", data);
    console.log("getPendingInvites 3, error", error);

    if (error) {
        return { data: null, error };
    }

    /*
    // Transform the data to match the Invitation interface
    const transformedData = data.map((invite) => ({
        id: invite.id,
        organizationName: invite.org.name,
        inviterEmail: invite.owner.email,
        createdAt: invite.created_at,
    }));
    console.log("transformedData", transformedData);
    */
    return { data, error: null };
};
