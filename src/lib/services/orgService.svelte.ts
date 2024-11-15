import { getItemById, getList, getSession } from "./backend.svelte.ts";
import { supabase } from "./backend.svelte.ts";
import type { Database } from "$lib/types/database.types";
import {
    FunctionsFetchError,
    FunctionsHttpError,
    FunctionsRelayError,
} from "@supabase/supabase-js";

export type Org = Database["public"]["Tables"]["orgs"]["Insert"];

//import type { Org } from "$lib/types/org.ts";
//import type { Database } from "$lib/types/database.types";

export const getAllOrgs = async () => {
    return fetchOrgs("title", "asc");
};

export async function fetchOrgs(
    column: string,
    direction: "asc" | "desc",
): Promise<{
    data: Database["public"]["Tables"]["orgs"]["Row"][];
    error: unknown | null;
}> {
    const { data, error } = await getList("orgs", 1, 50, column, direction);
    return { data: data ?? [], error };
}

export const getOrgById = async (
    id: string,
): Promise<{
    data: Database["public"]["Tables"]["orgs"]["Insert"] | null;
    error: unknown | null;
}> => {
    try {
        const { data } = await getItemById("orgs", id);
        return { data, error: null };
    } catch (error) {
        return { data: null, error };
    }
};

export const getMyRoleInOrg = async (orgId: string) => {
    const { data: sessionData, error: sessionError } = await getSession();
    const { data, error } = await supabase
        .from("orgs_users")
        .select("user_role")
        .eq("orgid", orgId)
        .eq("userid", sessionData?.session?.user?.id)
        .limit(1)
        .single();
    return { data: data?.user_role, error };
};

export const saveOrg = async (org: Org) => {
    try {
        const { data: { data, error }, error: saveOrgError } = await supabase
            .functions.invoke(
                "server_function",
                {
                    body: {
                        action: "org_upsert",
                        payload: {
                            id: org.id === "new" ? null : org.id,
                            title: org.title,
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

export const deleteOrg = async (org: Org) => {
    try {
        const { data, error } = await supabase.functions.invoke(
            "server_function",
            {
                body: { action: "org_delete", payload: { id: org.id } },
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
        console.error("deleteOrg unknown error", e);
        if (error) error.message = "unknown error";
        return { data: null, error };
    }
};
export const updateUserRole = async (
    orgs_users_id: string,
    new_user_role: string,
) => {
    if (!orgs_users_id || !new_user_role) {
        return {
            data: null,
            error: "orgs_users_id or new_user_role not provided",
        };
    }
    try {
        const { data, error } = await supabase.functions.invoke(
            "server_function",
            {
                body: {
                    action: "org_user_update_role",
                    payload: { id: orgs_users_id, user_role: new_user_role },
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
        console.error("updateUserRole unknown error", e);
        if (error) error.message = "unknown error";
        return { data: null, error };
    }
};
export const deleteOrgUser = async (id: string) => {
    try {
        const { data, error } = await supabase.functions.invoke(
            "server_function",
            {
                body: { action: "org_user_delete", payload: { id } },
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
        console.error("deleteOrgUser unknown error", e);
        if (error) error.message = "unknown error";
        return { data: null, error };
    }
};
export const getOrgUsers = async (org: Org) => {
    try {
        const { data, error } = await supabase.functions.invoke(
            "server_function",
            {
                body: { action: "get_org_users", payload: { id: org.id } },
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
        console.error("deleteOrg unknown error", e);
        if (error) error.message = "unknown error";
        return { data: null, error };
    }
};
