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

  let {
    open = $bindable(false),
    replyToMessage = $bindable<any | null>(null),
  } = $props();
  let showRecipients = $state(false);
  let profiles: Profile[] = $state([]);
  let hasSetupReply = $state(false);

  let message: Message = $state({
    subject: "",
    message: "",
    metadata: {},
  });

  let recipients: Profile[] = $state([]);
  const recipientString = $derived(
    recipients
      .map(
        (recipient) =>
          `${recipient.email} <${recipient.firstname} ${recipient.lastname}>`,
      )
      .join(", "),
  );

  function handleSelectRecipients(selected: Profile[]) {
    console.log("Selected profiles:", selected);
    recipients = selected;
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
        toast.error(error);
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
    if (open && replyToMessage && !hasSetupReply) {
      hasSetupReply = true;

      // Set subject with Re: prefix if not already present
      message.subject = replyToMessage.subject.startsWith("Re:")
        ? replyToMessage.subject
        : `Re: ${replyToMessage.subject}`;

      // Format original message in the reply
      const originalDate = new Date(replyToMessage.created_at).toLocaleString();
      message.message = `On ${originalDate}, ${replyToMessage.sender_profile.email} wrote:\n${replyToMessage.message}`;

      // Add original sender to recipients
      const senderProfile = {
        id: replyToMessage.sender, // Use the sender ID from the message
        email: replyToMessage.sender_profile.email,
        firstname: replyToMessage.sender_profile.firstname,
        lastname: replyToMessage.sender_profile.lastname,
      };
      recipients = [senderProfile];
    }
  });
</script>

<Dialog.Root bind:open>
  <Dialog.Content class="sm:max-w-[600px]">
    <Dialog.Header>
      <Dialog.Title>Compose Message</Dialog.Title>
    </Dialog.Header>

    <div class="py-4">
      <form
        class="space-y-4 w-full max-w-md"
        onsubmit={(e) => {
          e.preventDefault();
          handleSubmit();
        }}
      >
        <Button onclick={() => (showRecipients = true)}
          >Select Recipients</Button
        >

        <Recipients
          bind:open={showRecipients}
          onSelect={handleSelectRecipients}
        />
        <div class="space-y-2">
          <label for="recipient" class="text-sm font-medium">Recipient</label>
          {recipientString}
        </div>

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
            rows={4}
            required
          />
        </div>

        <Button type="submit" class="w-full">Send Message</Button>
      </form>
    </div>

    <Dialog.Footer>
      <Button variant="outline" onclick={() => (open = false)}>Cancel</Button>
    </Dialog.Footer>
  </Dialog.Content>
</Dialog.Root>
