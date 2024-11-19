<script lang="ts">
  import PageTemplate from "$lib/components/PageTemplate.svelte";
  import { Plus } from "lucide-svelte";
  import { Search } from "lucide-svelte";
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
  import { Input } from "$lib/components/ui/input";

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
  let filteredProperties = $state<Property[]>([]);
  let searchQuery = $state("");
  let searchTimeout: ReturnType<typeof setTimeout>;
  let loading = $state(false);
  let error = $state<string | null>(null);

  async function loadProperties() {
    loading = true;
    error = null;

    const { data, error: err } = await getOrgProperties();
    console.log("getOrgProperties", data);
    if (err) {
      error = err.message;
      loading = false;
      return;
    }

    properties = data || [];
    loading = false;
  }

  function filterProperties() {
    if (!searchQuery.trim()) {
      filteredProperties = properties;
      return;
    }

    const query = searchQuery?.toLowerCase() ?? "";
    filteredProperties = properties.filter((property) => {
      const searchFields = [
        property.title,
        property.subtitle,
        property.address,
        property.address2,
        property.city,
        property.region,
        property.postal,
        property.notes,
      ];
      return searchFields.some((field) => field?.toLowerCase().includes(query));
    });
  }

  $effect(() => {
    if (searchTimeout) {
      clearTimeout(searchTimeout);
    }
    if (searchQuery !== undefined) {
      searchTimeout = setTimeout(filterProperties, 500);
    }
  });

  $effect(() => {
    filteredProperties = properties;
  });

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
      <div class="p-4 space-y-4">
        <div class="relative">
          <Search
            class="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground"
          />
          <Input
            type="search"
            placeholder="Search properties..."
            class="pl-8"
            bind:value={searchQuery}
          />
        </div>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead class="w-full">Property</TableHead>
              <TableHead class="w-[100px]">Date</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {#each filteredProperties as property}
              <TableRow
                class="cursor-pointer hover:bg-muted/50"
                onclick={() => goto(`/properties/${property.id}`)}
              >
                <TableCell>
                  <div class="space-y-1">
                    <div class="font-medium">
                      {property.title || "Untitled Property"}
                    </div>
                    <div class="text-sm text-muted-foreground">
                      {[
                        property.address,
                        property.address2,
                        property.city,
                        property.region,
                        property.postal,
                      ]
                        .filter(Boolean)
                        .join(", ")}
                    </div>
                  </div>
                </TableCell>
                <TableCell class="whitespace-nowrap">
                  {property.created_at
                    ? new Date(property.created_at).toLocaleDateString()
                    : "-"}
                </TableCell>
              </TableRow>
            {/each}
          </TableBody>
        </Table>
      </div>
    {/if}
  {/snippet}
</PageTemplate>
