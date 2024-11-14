<script lang="ts">
  import { getSentMessages } from "$lib/services/messageService.svelte";
  import type { Message } from "$lib/services/messageService.svelte";
  import GenericList from "$lib/components/GenericList.svelte";
  import * as Table from "$lib/components/ui/table";

  let sentMessages: any[] = $state([]);
  const load = async () => {
    const { data, error } = await getSentMessages(0, 100);
    if (error) {
      console.error(error);
    } else if (data) {
      sentMessages = data;
      console.log("outbox");
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
    {#each sentMessages as message}
      <Table.Row>
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
