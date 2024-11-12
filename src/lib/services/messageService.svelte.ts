import type { Database } from "$lib/types/database.types";
import { supabase } from "./backend.svelte.ts";
import {
    FunctionsFetchError,
    FunctionsHttpError,
    FunctionsRelayError,
} from "@supabase/supabase-js";
import { getUser } from "$lib/services/backend.svelte.ts";
const user = $derived(getUser());

export type Message = Database["public"]["Tables"]["messages"]["Insert"];

export const getInboxMessages = async (
    start: number = 0,
    count: number = 100,
) => {
    if (!user) return { data: null, error: "User not logged in" };
    const { data, error } = await supabase
        .from("messages")
        .select(
            "id, created_at, subject, message, sender, recipient, metadata, read_at",
        )
        .eq("recipient", user.id)
        .is("recipient_deleted_at", null)
        .range(start, start + count)
        .limit(count)
        .order("created_at", { ascending: false });
    return { data, error };
};

export const getSentMessages = async (
    start: number = 0,
    count: number = 100,
) => {
    if (!user) return { data: null, error: "User not logged in" };
    const { data, error } = await supabase
        .from("messages")
        .select(
            "id, created_at, subject, message, sender, recipient, metadata, read_at",
        )
        .eq("sender", user.id)
        .is("sender_deleted_at", null)
        .range(start, start + count)
        .limit(count)
        .order("created_at", { ascending: false });
    return { data, error };
};

export const getMessage = async (id: string) => {
    if (!user) return { data: null, error: "User not logged in" };
    const { data, error } = await supabase
        .from("messages")
        .select("id, subject, message, sender, recipient, metadata, read_at")
        .eq("id", id);
    return { data, error };
};

export const deleteReceivedMessage = async (id: string) => {
    if (!user) return { data: null, error: "User not logged in" };
    const { error } = await supabase
        .from("messages")
        .update({ recipient_deleted_at: (new Date()).toISOString() })
        .eq("id", id);
    return { data: null, error };
};

export const deleteSentMessage = async (id: string) => {
    if (!user) return { data: null, error: "User not logged in" };
    const { error } = await supabase
        .from("messages")
        .update({ sender_deleted_at: (new Date()).toISOString() })
        .eq("id", id);
    return { data: null, error };
};

export const createMessage = async (message: Message) => {
    if (!user) return { data: null, error: "User not logged in" };
    if (!message.sender) message.sender = user.id;
    if (!message.recipient) {
        return { data: null, error: "Recipient is required" };
    }
    if (!message.subject) return { data: null, error: "Subject is required" };
    if (!message.message) return { data: null, error: "Message is required" };

    const { data, error } = await supabase.from("messages").insert(message);
    return { data, error };
};
