<script lang="ts">
  import { page } from "$app/stores";
  import PageTemplate from "$lib/components/PageTemplate.svelte";
  import type { Property } from "$lib/services/propertyService.svelte";
  import { supabase } from "$lib/services/backend.svelte";
  import { ArrowLeft, Edit, Check } from "lucide-svelte";
  import PropertyDetails from "@/components/PropertyDetails.svelte";
  import PropertyEdit from "$lib/components/PropertyEdit.svelte";
  import PropertyImages from "$lib/components/PropertyImages.svelte";
  import PropertyHistory from "$lib/components/PropertyHistory.svelte";
  import { Button } from "$lib/components/ui/button";
  import { goto } from "$app/navigation";
  import * as Tabs from "$lib/components/ui/tabs/index.js";
  import { upsertProperty } from "$lib/services/propertyService.svelte";

  const isNew = $derived($page.params.id === "new");
  const propertyId = $derived($page.params.id);
  let isEditing = $state(false);

  $effect(() => {
    // Set initial editing state based on isNew
    isEditing = isNew;
  });

  let property: Partial<Property> = $state({});

  $effect(() => {
    // Initialize property based on isNew condition
    property = isNew
      ? {
          property_type: "",
          property_subtype: "",
          address: "",
          address2: "",
          city: "",
          region: "",
          postal: "",
          country: "",
          beds: 0,
          baths: 0,
          living_area: 0,
          land_area: 0,
          year_built: new Date().getFullYear(),
          metadata: {},
        }
      : {};
  });

  let loading = $state(false);
  let error = $state<string | null>(null);

  const loadProperty = async () => {
    const { data, error: err } = await supabase
      .from("properties")
      .select("*")
      .eq("id", propertyId)
      .single();

    if (err) {
      error = err.message;
      loading = false;
      return;
    }

    property = data;
  };
  async function load() {
    if (isNew) return;

    loading = true;
    error = null;

    await loadProperty();

    loading = false;
  }

  function handleBack(event: MouseEvent) {
    goto("/properties");
  }

  async function handleSave() {
    loading = true;
    error = null;

    const { error: err } = await upsertProperty(property);

    if (err) {
      error = err.message;
      loading = false;
      return;
    }

    loading = false;
    isEditing = false;
    // No need to navigate since we're already on the correct page
    // Just need to exit edit mode
  }

  $effect(() => {
    load();
  });
</script>

<PageTemplate>
  {#snippet TopLeft()}
    <Button variant="ghost" size="icon" onclick={() => goto("/properties")}>
      <ArrowLeft class="h-4 w-4" />
    </Button>
  {/snippet}

  {#snippet TopCenter()}
    Property Details
  {/snippet}

  {#snippet TopRight()}
    {#if !isNew && !isEditing}
      <Button variant="ghost" size="icon" onclick={() => (isEditing = true)}>
        <Edit class="h-4 w-4" />
      </Button>
    {:else if isEditing}
      <Button variant="ghost" size="icon" onclick={handleSave}>
        <Check class="h-4 w-4" />
      </Button>
    {/if}
  {/snippet}

  {#snippet Middle()}
    {#if loading}
      <div class="flex items-center justify-center h-full">
        <div
          class="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900"
        ></div>
      </div>
    {:else if error}
      <div class="text-red-500 p-4">{error}</div>
    {:else if isEditing}
      <PropertyEdit bind:property on:save={() => (isEditing = false)} />
    {:else}
      <div class="flex items-center justify-center">
        <Tabs.Root value="details" class="inline-block">
          <Tabs.List class="flex justify-center">
            <Tabs.Trigger value="details">Details</Tabs.Trigger>
            <Tabs.Trigger value="images">Images</Tabs.Trigger>
            <Tabs.Trigger value="history">History</Tabs.Trigger>
          </Tabs.List>
          <Tabs.Content value="details">
            <PropertyDetails {property} />
          </Tabs.Content>
          <Tabs.Content value="images">
            <PropertyImages {property} onReload={loadProperty} />
          </Tabs.Content>
          <Tabs.Content value="history">
            <PropertyHistory {property} />
          </Tabs.Content>
        </Tabs.Root>
      </div>
    {/if}
  {/snippet}
</PageTemplate>
