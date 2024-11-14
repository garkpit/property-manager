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
export type MessageRecipient =
    Database["public"]["Tables"]["messages_recipients"]["Insert"];

export const getInboxMessages = async (
    start: number = 0,
    count: number = 100,
) => {
    if (!user) return { data: null, error: "User not logged in" };
    const { data, error } = await supabase
        .from("messages")
        .select(`
            id,
            created_at,
            subject,
            message,
            sender,
            metadata,
            messages_recipients!inner (
                recipient,
                read_at,
                deleted_at
            )
        `)
        .eq("messages_recipients.recipient", user.id)
        .is("messages_recipients.deleted_at", null)
        .range(start, start + count)
        .limit(count)
        .order("created_at", { ascending: false });

    // Transform the data to match the previous structure
    const transformedData = data?.map((msg) => ({
        ...msg,
        recipient: msg.messages_recipients[0].recipient,
        read_at: msg.messages_recipients[0].read_at,
    }));

    return { data: transformedData, error };
};

export const getSentMessages = async (
    start: number = 0,
    count: number = 100,
) => {
    if (!user) return { data: null, error: "User not logged in" };
    const { data, error } = await supabase
        .from("messages")
        .select(`
            id,
            created_at,
            subject,
            message,
            sender,
            metadata,
            messages_recipients (
                recipient,
                read_at,
                deleted_at
            )
        `)
        .eq("sender", user.id)
        .is("sender_deleted_at", null)
        .range(start, start + count)
        .limit(count)
        .order("created_at", { ascending: false });

    // Transform the data to match the previous structure
    const transformedData = data?.map((msg) => ({
        ...msg,
        recipient: msg.messages_recipients[0].recipient,
        read_at: msg.messages_recipients[0].read_at,
    }));

    return { data: transformedData, error };
};

export const getMessage = async (id: string) => {
    if (!user) return { data: null, error: "User not logged in" };
    const { data, error } = await supabase
        .from("messages")
        .select(`
            id,
            created_at,
            subject,
            message,
            sender,
            metadata,
            messages_recipients (
                recipient,
                read_at,
                deleted_at
            )
        `)
        .eq("id", id)
        .single();

    // Transform the data to match the previous structure
    const transformedData = data
        ? {
            ...data,
            recipient: data.messages_recipients[0].recipient,
            read_at: data.messages_recipients[0].read_at,
        }
        : null;

    return { data: transformedData, error };
};

export const deleteReceivedMessage = async (id: string) => {
    if (!user) return { data: null, error: "User not logged in" };
    const { error } = await supabase
        .from("messages_recipients")
        .update({ deleted_at: new Date().toISOString() })
        .eq("messageid", id)
        .eq("recipient", user.id);
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

export const createMessage = async (
    message: Omit<Message, "recipient">,
    recipientIds: string[],
) => {
    if (!user) return { data: null, error: "User not logged in" };
    if (!message.sender) message.sender = user.id;
    if (recipientIds.length === 0) {
        return { data: null, error: "At least one recipient is required" };
    }
    if (!message.subject) return { data: null, error: "Subject is required" };
    if (!message.message) return { data: null, error: "Message is required" };

    // Start a Supabase transaction
    const { data: messageData, error: messageError } = await supabase
        .from("messages")
        .insert(message)
        .select()
        .single();

    if (messageError) return { data: null, error: messageError };

    // Create recipient records
    const recipientRecords = recipientIds.map((recipientId) => ({
        messageid: messageData.id,
        recipient: recipientId,
    }));

    const { error: recipientsError } = await supabase
        .from("messages_recipients")
        .insert(recipientRecords);

    if (recipientsError) {
        // If creating recipients failed, we should ideally delete the message
        // but Supabase doesn't support true transactions across tables
        return { data: null, error: recipientsError };
    }

    return { data: messageData, error: null };
};
