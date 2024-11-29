<script lang="ts">
  import { page } from "$app/stores";
  import PageTemplate from "$lib/components/PageTemplate.svelte";
  import type { Contact } from "$lib/services/contactService.svelte";
  import { ArrowLeft, Edit, Check } from "lucide-svelte";
  import { Button } from "$lib/components/ui/button";
  import { goto } from "$app/navigation";
  import { Input } from "$lib/components/ui/input";
  import { Label } from "$lib/components/ui/label";
  import {
    upsertContact,
    getContactById,
  } from "$lib/services/contactService.svelte";

  const isNew = $derived($page.params.id === "new");
  const contactId = $derived($page.params.id);
  let isEditing = $state(false);

  $effect(() => {
    // Set initial editing state based on isNew
    isEditing = isNew;
  });

  let contact: Partial<Contact> = $state({});

  $effect(() => {
    // Initialize contact based on isNew condition
    contact = isNew
      ? {
          firstname: "",
          lastname: "",
          email: "",
          phone: "",
        }
      : {};
  });

  let loading = $state(false);
  let error = $state<string | null>(null);

  const loadContact = async () => {
    const { data, error: err } = await getContactById(contactId);

    if (err) {
      error = err.message;
      loading = false;
      return;
    }

    if (data && data.length > 0) {
      contact = data[0];
    }
  };

  async function load() {
    if (isNew) return;

    loading = true;
    error = null;

    await loadContact();

    loading = false;
  }

  async function handleSave() {
    loading = true;
    error = null;

    const { error: err } = await upsertContact(contact);

    if (err) {
      error = err.message;
      loading = false;
      return;
    }

    // If this was a new contact, navigate to the contact list
    if (isNew) {
      goto("/contacts");
      return;
    }

    // For existing contacts, reload the data and exit edit mode
    await loadContact();
    loading = false;
    isEditing = false;
  }

  $effect(() => {
    load();
  });

  const actionItems = [
    {
      icon: Edit,
      label: "Edit",
      onClick: () => (isEditing = true),
      show: !isEditing && !isNew,
    },
    {
      icon: Check,
      label: "Save",
      onClick: handleSave,
      show: isEditing || isNew,
    },
  ];
</script>

<PageTemplate {actionItems}>
  {#snippet TopLeft()}
    <Button variant="ghost" size="icon" onclick={() => goto("/contacts")}>
      <ArrowLeft class="h-4 w-4" />
    </Button>
  {/snippet}

  {#snippet TopCenter()}
    {isNew ? "New Contact" : "Contact Details"}
  {/snippet}

  {#snippet Middle()}
    {#if loading}
      <div class="flex items-center justify-center h-full">
        <div
          class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"
        ></div>
      </div>
    {:else if error}
      <div class="flex items-center justify-center h-full text-destructive">
        <p>{error}</p>
      </div>
    {:else}
      <div class="w-full flex justify-center">
        <div class="max-w-2xl w-full p-6">
          {#if isEditing || isNew}
            <form
              class="space-y-6"
              onsubmit={(e) => {
                e.preventDefault();
                handleSave();
              }}
            >
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="space-y-2">
                  <Label for="firstname">First Name</Label>
                  <Input
                    id="firstname"
                    bind:value={contact.firstname}
                    placeholder="Enter first name"
                  />
                </div>
                <div class="space-y-2">
                  <Label for="lastname">Last Name</Label>
                  <Input
                    id="lastname"
                    bind:value={contact.lastname}
                    placeholder="Enter last name"
                  />
                </div>
              </div>

              <div class="space-y-2">
                <Label for="email">Email</Label>
                <Input
                  id="email"
                  type="email"
                  bind:value={contact.email}
                  placeholder="Enter email address"
                />
              </div>

              <div class="space-y-2">
                <Label for="phone">Phone</Label>
                <Input
                  id="phone"
                  type="tel"
                  bind:value={contact.phone}
                  placeholder="Enter phone number"
                />
              </div>

              <div class="flex justify-end">
                <Button type="submit">Save Contact</Button>
              </div>
            </form>
          {:else}
            <div class="space-y-6">
              <div class="grid gap-4">
                {#if contact.firstname || contact.lastname}
                  <div class="grid grid-cols-3 items-center gap-4">
                    <div class="font-medium">Name</div>
                    <div class="col-span-2">
                      {[contact.firstname, contact.lastname].filter(Boolean).join(" ")}
                    </div>
                  </div>
                {/if}
                {#if contact.email}
                  <div class="grid grid-cols-3 items-center gap-4">
                    <div class="font-medium">Email</div>
                    <div class="col-span-2">{contact.email}</div>
                  </div>
                {/if}
                {#if contact.phone}
                  <div class="grid grid-cols-3 items-center gap-4">
                    <div class="font-medium">Phone</div>
                    <div class="col-span-2">{contact.phone}</div>
                  </div>
                {/if}
                {#if contact.created_at}
                  <div class="grid grid-cols-3 items-center gap-4">
                    <div class="font-medium">Created</div>
                    <div class="col-span-2">
                      {new Date(contact.created_at).toLocaleDateString()}
                    </div>
                  </div>
                {/if}
              </div>
            </div>
          {/if}
        </div>
      </div>
    {/if}
  {/snippet}
</PageTemplate>
