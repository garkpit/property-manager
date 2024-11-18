<script lang="ts">
  import PageTemplate from "$lib/components/PageTemplate.svelte";
  import { Plus } from "lucide-svelte";
  import type { Property } from "$lib/services/propertyService.svelte";
  import { upsertProperty } from "$lib/services/propertyService.svelte";
  import { goto } from "$app/navigation";

  const actionItems = [
    {
      groupName: "Properties",
      groupItems: [
        {
          icon: Plus,
          label: "Add Property",
          onClick: async () => {
            goto("/properties/new");
          },
        },
      ],
    },
  ];

  let properties: Property[] = [];

  async function loadProperties() {
    // TODO: Implement properties loading from Supabase
  }
  $effect(() => {
    loadProperties();
  });
</script>

<PageTemplate {actionItems}>
  {#snippet TopCenter()}
    Properties
  {/snippet}

  {#snippet Middle()}
    {#if properties.length === 0}
      <div
        class="flex flex-col items-center justify-center h-full text-muted-foreground"
      >
        <p>No properties yet</p>
        <p class="text-sm">
          Click the "Add Property" button to create your first property
        </p>
      </div>
    {:else}
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 p-4">
        {#each properties as property}
          <div
            class="border rounded-lg p-4 shadow-sm hover:shadow-md transition-shadow"
          >
            <h3 class="text-lg font-semibold">{property.name}</h3>
            <!-- Add more property details as needed -->
          </div>
        {/each}
      </div>
    {/if}
  {/snippet}
</PageTemplate>
