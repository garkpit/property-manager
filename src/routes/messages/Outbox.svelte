<script lang="ts">
  import { getSentMessages } from "$lib/services/messageService.svelte";
  import type { Message } from "$lib/services/messageService.svelte";
  import GenericList from "$lib/components/GenericList.svelte";
  import * as Table from "$lib/components/ui/table";
  import { getUser } from "$lib/services/backend.svelte";
  import { goto } from "$app/navigation";
  const user = $derived(getUser());

  let sentMessages: any[] = $state([]);
  const load = async () => {
    if (!user) {
      return;
    }
    const { data, error } = await getSentMessages(0, 100);
    if (error) {
      console.error(error);
    } else if (data) {
      sentMessages = data;
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
      <Table.Head>Recipient(s)</Table.Head>
      <Table.Head>Date</Table.Head>
    </Table.Row>
  </Table.Header>
  <Table.Body>
    {#each sentMessages as message}
      <Table.Row
        onclick={() => {
          goto(`/messages/${message.id}`);
        }}
      >
        <Table.Cell class="font-medium">{message.subject}</Table.Cell>
        <Table.Cell
          >{message.recipients.map((recipient: any) => {
            return " " + recipient.email;
          })}</Table.Cell
        >
        <Table.Cell>{message.created_at}</Table.Cell>
      </Table.Row>
    {/each}
  </Table.Body>
</Table.Root>
