<script lang="ts">
  import {
    getMessage,
    markMessageAsUnread,
    markMessageAsRead,
  } from "$lib/services/messageService.svelte";
  import { page } from "$app/stores";
  import PageTemplate from "$lib/components/PageTemplate.svelte";
  import { Button } from "$lib/components/ui/button";
  import { goto } from "$app/navigation";
  import { ArrowLeft } from "lucide-svelte";
  import * as Table from "$lib/components/ui/table";
  import { getUser } from "$lib/services/backend.svelte";
  import { Mail, MailOpen } from "lucide-svelte";
  const user = $derived(getUser());
  const id = $derived($page.params.id);
  let message = $state<any | null>(null);
  const actionItems: any[] = [
    {
      groupName: "Manage Message",
      groupItems: [
        {
          icon: Mail,
          label: "Mark as unread",
          onClick: async () => {
            console.log("marking message as unread");
            await markMessageAsUnread(id);
            console.log("calling load(false)");
            load(false); // don't mark as read
          },
        },
        {
          icon: MailOpen,
          label: "Mark as read",
          onClick: async () => {
            await markMessageAsRead(id);
            load(true); // mark as read
          },
        },
      ],
    },
  ];

  const load = async (markRead = true) => {
    if (!user) {
      console.log("message detail load: user not found, returning");
      return;
    }
    const { data, error } = await getMessage(id);
    if (error) {
      console.error("getMessage error", error);
    }
    message = data;
    // find the recipient record for the current user then check if it's read_at is null
    const recipient = message.messages_recipients.find(
      (r: any) => r.recipient === user.id,
    );
    console.log("load: markRead", markRead);
    if (markRead && !recipient.read_at) {
      await markMessageAsRead(id);
      recipient.read_at = new Date().toISOString().toLocaleString();
    } else {
      console.log("message already read");
    }
  };
  $effect(() => {
    load();
  });

  // Format date helper
  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleString();
  };
</script>

<PageTemplate {actionItems}>
  {#snippet TopLeft()}
    <Button
      variant="ghost"
      size="icon"
      onclick={() => {
        goto("/messages");
      }}
    >
      <ArrowLeft class="h-4 w-4" />
    </Button>
  {/snippet}

  {#snippet TopCenter()}
    Message Details
  {/snippet}

  {#snippet Middle()}
    {#if message}
      <div class="space-y-6">
        <!-- Message Content Section -->
        <div class="mb-8">
          <h2 class="text-lg font-semibold mb-2">{message.subject}</h2>
          <div
            class="flex items-center gap-x-4 text-sm text-muted-foreground mb-4"
          >
            <span
              ><b>FROM:</b>
              {message.sender_profile.email}
              &lt;{message.sender_profile.firstname}
              {message.sender_profile.lastname}&gt;</span
            >
            <span>•</span>
            <span>{formatDate(message.created_at)}</span>
          </div>
          <div class="whitespace-pre-wrap rounded-lg bg-muted/50 p-4 w-full">
            {message.message}
          </div>
        </div>

        <!-- Recipients Table -->
        <div>
          <h3 class="text-sm font-semibold mb-2">Recipients</h3>
          <Table.Root>
            <Table.Header>
              <Table.Row>
                <Table.Head>Name</Table.Head>
                <Table.Head>Email</Table.Head>
                <Table.Head class="w-32">Status</Table.Head>
              </Table.Row>
            </Table.Header>
            <Table.Body>
              {#each message.messages_recipients as recipient}
                <Table.Row>
                  <Table.Cell
                    >{recipient.profiles.firstname}
                    {recipient.profiles.lastname}</Table.Cell
                  >
                  <Table.Cell>{recipient.profiles.email}</Table.Cell>
                  <Table.Cell
                    >{recipient.read_at
                      ? formatDate(recipient.read_at)
                      : "Unread"}</Table.Cell
                  >
                </Table.Row>
              {/each}
            </Table.Body>
          </Table.Root>
        </div>
      </div>
    {/if}
  {/snippet}
</PageTemplate>
