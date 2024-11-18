import type { Database } from "$lib/types/database.types";
import { supabase } from "./backend.svelte.ts";
import {
    FunctionsFetchError,
    FunctionsHttpError,
    FunctionsRelayError,
} from "@supabase/supabase-js";
import { getUser } from "$lib/services/backend.svelte.ts";
import { getCurrentOrg } from "./backend.svelte.ts";
import type { Org } from "./backend.svelte.ts";
const user = $derived(getUser());
const currentOrg: Org | null = $derived(getCurrentOrg());

export type Property = Database["public"]["Tables"]["properties"]["Insert"];

export async function getOrgProperties(): Promise<{
    data: Property[] | null;
    error: Error | null;
}> {
    if (!currentOrg?.id) {
        return { data: null, error: new Error("No organization selected") };
    }

    const { data, error } = await supabase
        .from("properties")
        .select("*")
        .eq("orgid", currentOrg.id)
        .order("created_at", { ascending: false });

    return { data, error };
}

export async function upsertProperty(
    property: Partial<Property>,
): Promise<{ data: Property | null; error: Error | null }> {
    if (!currentOrg?.id) {
        return { data: null, error: new Error("No organization selected") };
    }
    if (!user) {
        return { data: null, error: new Error("No user logged in") };
    }

    // Ensure the property is associated with the current org
    const propertyWithOrg = {
        ...property,
        orgid: currentOrg.id,
        userid: user.id,
    };

    const { data, error } = await supabase
        .from("properties")
        .upsert(propertyWithOrg)
        .select()
        .single();

    return { data, error };
}
