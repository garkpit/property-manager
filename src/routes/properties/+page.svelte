<script lang="ts">
  import PageTemplate from "$lib/components/PageTemplate.svelte";
  import { Plus } from "lucide-svelte";
  import type { Property } from "$lib/services/propertyService.svelte";
  import {
    upsertProperty,
    getOrgProperties,
  } from "$lib/services/propertyService.svelte";
  import { goto } from "$app/navigation";
  import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
  } from "$lib/components/ui/table";

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

  let properties = $state<Property[]>([]);
  let loading = $state(false);
  let error = $state<string | null>(null);

  async function loadProperties() {
    loading = true;
    error = null;

    const { data, error: err } = await getOrgProperties();

    if (err) {
      error = err.message;
      loading = false;
      return;
    }

    properties = data || [];
    loading = false;
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
    {:else if properties.length === 0}
      <div
        class="flex flex-col items-center justify-center h-full text-muted-foreground"
      >
        <p>No properties yet</p>
        <p class="text-sm">
          Click the "Add Property" button to create your first property
        </p>
      </div>
    {:else}
      <div class="p-4">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Address</TableHead>
              <TableHead>City</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {#each properties as property}
              <TableRow
                class="cursor-pointer hover:bg-muted/50"
                onclick={() => goto(`/properties/${property.id}`)}
              >
                <TableCell>
                  <div class="space-y-1">
                    <div>{property.address || "-"}</div>
                    {#if property.address2}
                      <div class="text-sm text-muted-foreground">
                        {property.address2}
                      </div>
                    {/if}
                  </div>
                </TableCell>
                <TableCell>{property.city || "-"}</TableCell>
              </TableRow>
            {/each}
          </TableBody>
        </Table>
      </div>
    {/if}
  {/snippet}
</PageTemplate>
