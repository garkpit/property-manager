<script lang="ts">
  import { createMessage } from "$lib/services/messageService.svelte";
  import type { Message } from "$lib/services/messageService.svelte";
  import { Button } from "$lib/components/ui/button";
  import { Input } from "$lib/components/ui/input";
  import { Textarea } from "$lib/components/ui/textarea";
  import Recipients from "../Recipients.svelte";
  import type { Profile } from "$lib/services/profileService.svelte";
  import { cn } from "$lib/utils";
  let showRecipients = $state(false);
  let profiles: Profile[] = $state([]);

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
      } else {
        console.log("Message sent:", data);
      }
    } catch (e) {
      console.error("Failed to send message (e):", e);
    }
  }
</script>

<form
  class="space-y-4 w-full max-w-md"
  onsubmit={(e) => {
    e.preventDefault();
    handleSubmit();
  }}
>
  <Button onclick={() => (showRecipients = true)}>Select Recipients</Button>

  <Recipients bind:open={showRecipients} onSelect={handleSelectRecipients} />
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
