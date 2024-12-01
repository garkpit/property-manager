<script lang="ts">
  import { createEventDispatcher } from "svelte";
  import { Search } from "lucide-svelte";
  import type { Contact } from "$lib/services/contactService.svelte";
  import { getContacts } from "$lib/services/contactService.svelte";
  import * as Dialog from "$lib/components/ui/dialog";
  import { Button } from "$lib/components/ui/button";
  import { Input } from "$lib/components/ui/input";
  import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
  } from "$lib/components/ui/table";

  const dispatch = createEventDispatcher<{
    select: { id: string };
    close: void;
  }>();

  let contacts = $state<Contact[]>([]);
  let filteredContacts = $state<Contact[]>([]);
  let searchQuery = $state("");
  let loading = $state(false);
  let error = $state<string | null>(null);

  async function loadContacts() {
    loading = true;
    error = null;

    const { data, error: err } = await getContacts();

    if (err) {
      error = err.message;
      loading = false;
      return;
    }

    contacts = data || [];
    filterContacts();
    loading = false;
  }

  function filterContacts() {
    if (!searchQuery?.trim()) {
      filteredContacts = contacts;
      return;
    }

    const query = searchQuery.toLowerCase();
    filteredContacts = contacts.filter((contact) => {
      const searchFields = [
        contact.firstname,
        contact.lastname,
        contact.email,
        contact.phone,
      ];
      return searchFields.some(
        (field) => field && field.toLowerCase().includes(query)
      );
    });
  }

  function handleSelect(contact: Contact) {
    dispatch("select", { id: contact.id });
  }

  function handleClose() {
    dispatch("close");
  }

  // Load contacts when component mounts
  $effect(() => {
    loadContacts();
  });

  // Filter contacts when search query changes
  $effect(() => {
    filterContacts();
  });
</script>

<Dialog.Root>
  <Dialog.Content class="sm:max-w-[600px]">
    <Dialog.Header>
      <Dialog.Title>Select Contact</Dialog.Title>
      <Dialog.Description>
        Choose a contact to associate with this property
      </Dialog.Description>
    </Dialog.Header>

    <div class="space-y-4">
      <div class="relative">
        <Search class="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
        <Input
          type="search"
          placeholder="Search contacts..."
          class="pl-8"
          bind:value={searchQuery}
        />
      </div>

      {#if loading}
        <div class="flex items-center justify-center py-4">
          <div
            class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"
          ></div>
        </div>
      {:else if error}
        <div class="text-destructive">{error}</div>
      {:else if contacts.length === 0}
        <div class="text-center py-4 text-muted-foreground">
          <p>No contacts found</p>
          <p class="text-sm">Create a contact first to associate it with properties</p>
        </div>
      {:else}
        <div class="max-h-[400px] overflow-y-auto">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Name</TableHead>
                <TableHead>Email</TableHead>
                <TableHead>Phone</TableHead>
                <TableHead class="w-[100px]"></TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {#each filteredContacts as contact}
                <TableRow>
                  <TableCell>
                    {contact.firstname} {contact.lastname}
                  </TableCell>
                  <TableCell>{contact.email}</TableCell>
                  <TableCell>{contact.phone}</TableCell>
                  <TableCell>
                    <Button
                      variant="ghost"
                      size="sm"
                      onclick={() => handleSelect(contact)}
                    >
                      Select
                    </Button>
                  </TableCell>
                </TableRow>
              {/each}
            </TableBody>
          </Table>
        </div>
      {/if}
    </div>

    <Dialog.Footer>
      <Button variant="outline" onclick={handleClose}>Cancel</Button>
    </Dialog.Footer>
  </Dialog.Content>
</Dialog.Root>
