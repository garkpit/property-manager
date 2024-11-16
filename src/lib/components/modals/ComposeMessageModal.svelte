<script lang="ts">
  import * as Dialog from "$lib/components/ui/dialog";
  import { Button } from "$lib/components/ui/button";
  import { Input } from "$lib/components/ui/input";
  import { Textarea } from "$lib/components/ui/textarea";
  import Recipients from "./Recipients.svelte";
  import { createMessage } from "$lib/services/messageService.svelte.ts";
  import type { Message } from "$lib/services/messageService.svelte.ts";
  import type { Profile } from "$lib/services/profileService.svelte.ts";
  import { cn } from "$lib/utils";
  import { triggerMessageRefresh } from "$lib/state/messageState.svelte.ts";
  import { toast } from "svelte-sonner";
  import { getUser } from "$lib/services/backend.svelte";

  // Define extended message type that includes joined fields
  type MessageWithProfile = Message & {
    sender_profile: {
      email: string;
      firstname: string;
      lastname: string;
      id: string;
    };
  };

  let {
    open = $bindable(false),
    replyToMessage = $bindable<MessageWithProfile | null>(null),
  } = $props();
  let showRecipients = $state(false);
  let hasSetupReply = $state(false);

  let message: Message = $state({
    subject: "",
    message: "",
    metadata: {},
    id: "",
    sender: "",
    created_at: new Date().toISOString(),
    sender_profile: {
      email: "",
      firstname: "",
      lastname: "",
      id: "",
    },
  });

  let recipients: Profile[] = $state([]);
  const recipientString = $derived(
    recipients
      .map(
        (recipient) => {
          const name = [recipient.firstname, recipient.lastname]
            .filter(Boolean)
            .join(" ");
          return `${recipient.email}${name ? ` <${name}>` : " <>"}`
        }
      )
      .join(", "),
  );

  function handleSelectRecipients(selected: Profile[]): void {
    recipients = selected;
    showRecipients = false;
  }

  async function handleSubmit() {
    try {
      if (recipients.length === 0) {
        toast.error("At least one recipient is required");
        return;
      }
      const { data, error } = await createMessage(
        {
          subject: message.subject,
          message: message.message,
          metadata: {},
        },
        recipients.map((recipient) => recipient.id),
      );
      if (error) {
        console.error("Failed to send message (error):", error);
        toast.error(
          error.toString() ||
            "An unexpected error occurred while sending the message",
        );
      } else {
        console.log("Message sent:", data);
        // Clear form data after successful send
        message.subject = "";
        message.message = "";
        recipients = [];
        triggerMessageRefresh();
        open = false;
      }
    } catch (e) {
      console.error("Failed to send message (e):", e);
      toast.error("An unexpected error occurred while sending the message");
    }
  }

  $effect(() => {
    // Reset the setup flag when the modal closes
    if (!open) {
      hasSetupReply = false;
      // Clear form data
      message.subject = "";
      message.message = "";
      recipients = [];
    }
  });

  $effect(() => {
    // Only set up reply once when the modal opens and we have a message to reply to
    if (!open || !replyToMessage || hasSetupReply) return;

    hasSetupReply = true;

    // Store the non-null message in a const to help TypeScript
    const msg = replyToMessage as MessageWithProfile;

    // Set subject with Re: prefix if not already present
    message.subject = msg.subject?.startsWith("Re:")
      ? msg.subject
      : `Re: ${msg.subject || ""}`;

    // Format original message in the reply
    const originalDate = new Date(
      msg.created_at ? msg.created_at : "",
    ).toLocaleString();
    message.message = `On ${originalDate}, ${msg.sender_profile.email} wrote:\n${msg.message || ""}`;

    // Add original sender to recipients
    recipients = [
      {
        id: msg.sender || "",
        email: msg.sender_profile.email,
        firstname: msg.sender_profile.firstname,
        lastname: msg.sender_profile.lastname,
      },
    ];
  });
</script>

<Dialog.Root bind:open>
  <Dialog.Content class="sm:max-w-[600px]">
    <Dialog.Header>
      <Dialog.Title>Compose Message</Dialog.Title>
    </Dialog.Header>

    <div class="py-4">
      <form
        class="space-y-4 w-full"
        onsubmit={(e) => {
          e.preventDefault();
          handleSubmit();
        }}
      >
        <div class="flex items-center gap-4 w-full">
          <Button onclick={() => (showRecipients = true)}
            >Select Recipients</Button
          >
          {#if recipients.length > 0}
            <div class="text-sm flex-1">
              {recipientString}
            </div>
          {/if}
        </div>

        <Recipients
          bind:open={showRecipients}
          onSelect={handleSelectRecipients}
        />

        <div class="space-y-2">
          <label for="subject" class="text-sm font-medium">Subject</label>
          <Input
            id="subject"
            type="text"
            bind:value={message.subject}
            placeholder="Enter subject"
            required
          />
        </div>

        <div class="space-y-2">
          <label for="message" class="text-sm font-medium">Message</label>
          <Textarea
            id="message"
            bind:value={message.message}
            placeholder="Type your message here"
            rows={8}
            required
            class="min-h-[200px]"
          />
        </div>

        <div class="flex justify-end space-x-2">
          <Button variant="outline" onclick={() => (open = false)}
            >Cancel</Button
          >
          <Button type="submit">Send Message</Button>
        </div>
      </form>
    </div>
  </Dialog.Content>
</Dialog.Root>
