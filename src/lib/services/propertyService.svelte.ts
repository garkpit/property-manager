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
    if (!user) {
        return {
            data: null,
            error: new Error("You need to be logged in to view properties"),
        };
    }
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
    if (!user) {
        return {
            data: null,
            error: new Error("You need to be logged in to view properties"),
        };
    }

    if (!currentOrg?.id) {
        return { data: null, error: new Error("No organization selected") };
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

    if (data && !property.id) {
        // If this is a new property (no ID), trigger geocoding
        const geocodeResponse = await supabase.functions.invoke(
            "server_function",
            {
                body: {
                    action: "property_geocode",
                    payload: { id: data.id },
                },
            },
        );
        console.log("geocodeResponse", geocodeResponse);
        // We don't need to wait for or handle the geocoding response
        // as it will update the database asynchronously
    }

    return { data, error };
}

export async function getPropertyById(
    propertyId: string,
): Promise<{ data: Property | null; error: Error | null }> {
    const { data, error } = await supabase
        .from("properties")
        .select("*")
        .eq("id", propertyId)
        .single();

    return { data, error };
}
