<script lang="ts">
  import { page } from "$app/stores";
  import PageTemplate from "$lib/components/PageTemplate.svelte";
  import type { Property } from "$lib/services/propertyService.svelte";
  import { supabase } from "$lib/services/backend.svelte";
  import { ArrowLeft, Edit } from "lucide-svelte";
  import PropertyDisplay from "$lib/components/PropertyDisplay.svelte";
  import PropertyEdit from "$lib/components/PropertyEdit.svelte";
  import { Button } from "$lib/components/ui/button";
  import { goto } from "$app/navigation";

  const isNew = $derived($page.params.id === "new");
  const propertyId = $derived($page.params.id);
  let isEditing = $state(isNew);

  let property: Partial<Property> = $state(
    isNew
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
      : {},
  );

  let loading = $state(false);
  let error = $state<string | null>(null);

  async function load() {
    if (isNew) return;

    loading = true;
    error = null;

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
    loading = false;
  }

  function handleBack(event: MouseEvent) {
    goto("/properties");
  }

  $effect(() => {
    load();
  });
</script>

<PageTemplate>
  {#snippet TopLeft()}
    <Button variant="ghost" size="icon" onclick={handleBack}>
      <ArrowLeft class="h-4 w-4" />
    </Button>
  {/snippet}

  {#snippet TopRight()}
    {#if !isEditing && !isNew}
      <Button variant="ghost" size="icon" onclick={() => (isEditing = true)}>
        <Edit class="h-4 w-4" />
      </Button>
    {/if}
  {/snippet}

  {#snippet Middle()}
    {#if loading}
      <div class="flex items-center justify-center h-full">
        <div
          class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"
        ></div>
      </div>
    {:else if error}
      <div class="flex items-center justify-center h-full">
        <div class="text-destructive">{error}</div>
      </div>
    {:else if isEditing}
      <PropertyEdit {property} />
    {:else}
      <PropertyDisplay property={property as Property} />
    {/if}
  {/snippet}
</PageTemplate>
