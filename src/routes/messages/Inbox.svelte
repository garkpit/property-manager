<script lang="ts">
  import { getInboxMessages } from "$lib/services/messageService.svelte";
  import type { Message } from "$lib/services/messageService.svelte";
  import GenericList from "$lib/components/GenericList.svelte";
  let inboxMessages: Message[] = $state([]);
  const load = async () => {
    const { data, error } = await getInboxMessages(0, 100);
    if (error) {
      console.error(error);
    } else if (data) {
      inboxMessages = data;
    }
  };
  $effect(() => {
    load();
  });
  /*
    data: any[];
    headers: Header[];
    onRowClick?: (item: any) => void;
    onSort?: (column: string, direction: "asc" | "desc") => Promise<void>;
    showCheckboxes?: boolean;
    onSelectionChange?: (selectedItems: Set<string>) => void;

    id, subject, message, sender, recipient, metadata, read_at
  */
  const headers = [
    { key: "subject", label: "Subject", sortable: true },
    { key: "sender", label: "Sender", sortable: true },
    { key: "created_at", label: "Date", sortable: true },
  ];
</script>

<GenericList data={inboxMessages} {headers} />
