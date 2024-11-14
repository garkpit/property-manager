<script lang="ts">
  import { getInboxMessages } from "$lib/services/messageService.svelte";
  import type { Message } from "$lib/services/messageService.svelte";
  import * as Table from "$lib/components/ui/table";
  import { goto } from "$app/navigation";

  let inboxMessages: any[] = $state([]);

  const load = async () => {
    const { data, error } = await getInboxMessages(0, 100);
    if (error) {
      console.error(error);
    } else if (data) {
      inboxMessages = data;
      console.log(data);
    }
  };

  $effect(() => {
    load();
  });
</script>

<Table.Root>
  <Table.Header>
    <Table.Row>
      <Table.Head>Subject</Table.Head>
      <Table.Head>Sender</Table.Head>
      <Table.Head>Date</Table.Head>
    </Table.Row>
  </Table.Header>
  <Table.Body>
    {#each inboxMessages as message}
      <Table.Row
        onclick={() => {
          goto(`/messages/${message.id}`);
        }}
      >
        <Table.Cell class="font-medium">{message.subject}</Table.Cell>
        <Table.Cell>{message.sender_email}</Table.Cell>
        <Table.Cell>{message.created_at}</Table.Cell>
      </Table.Row>
    {/each}
  </Table.Body>
</Table.Root>
