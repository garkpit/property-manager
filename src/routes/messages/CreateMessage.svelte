<script lang="ts">
  import { createMessage } from "$lib/services/messageService.svelte";
  import type { Message } from "$lib/services/messageService.svelte";
  import { Button } from "$lib/components/ui/button";
  import { Input } from "$lib/components/ui/input";
  import { Textarea } from "$lib/components/ui/textarea";
  import Recipients from "./Recipients.svelte";
  import type { Profile } from "$lib/services/profileService.svelte";
  import { cn } from "$lib/utils";
  let showRecipients = $state(false);
  let profiles: Profile[] = $state([]);

  let message: Message = $state({
    subject: "",
    message: "",
    recipient: "",
  });
  function handleSelect(selected: Profile[]) {
    console.log("Selected profiles:", selected);
    // Handle the selected profiles
  }
  async function handleSubmit() {
    try {
      await createMessage(message);
      // Reset form after successful submission
      message = {
        subject: "",
        message: "",
        recipient: "",
      };
    } catch (error) {
      console.error("Failed to send message:", error);
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

  <Recipients bind:open={showRecipients} onSelect={handleSelect} />
  <div class="space-y-2">
    <label for="recipient" class="text-sm font-medium">Recipient</label>
    <Input
      id="recipient"
      type="text"
      bind:value={message.recipient}
      placeholder="Enter recipient"
      required
    />
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
