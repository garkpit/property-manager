<script lang="ts">
  import { page } from "$app/stores";
  import PageTemplate from "$lib/components/PageTemplate.svelte";
  import { upsertProperty } from "$lib/services/propertyService.svelte";
  import type { Property } from "$lib/services/propertyService.svelte";
  import { supabase } from "$lib/services/backend.svelte";
  import { goto } from "$app/navigation";
  import { Save } from "lucide-svelte";
  import * as Select from "$lib/components/ui/select";
  import { Input } from "$lib/components/ui/input";
  import { Textarea } from "$lib/components/ui/textarea";
  import { Label } from "$lib/components/ui/label";

  const isNew = $derived($page.params.id === "new");
  const propertyId = $derived($page.params.id);

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

  const propertyTypes = [
    { value: "residential", label: "Residential" },
    { value: "commercial", label: "Commercial" },
    { value: "land", label: "Land" },
  ];

  const propertySubtypes = [
    { value: "single_family", label: "Single Family" },
    { value: "multi_family", label: "Multi Family" },
    { value: "condo", label: "Condo" },
    { value: "townhouse", label: "Townhouse" },
    { value: "apartment", label: "Apartment" },
    { value: "office", label: "Office" },
    { value: "retail", label: "Retail" },
    { value: "industrial", label: "Industrial" },
    { value: "other", label: "Other" },
  ];

  const propertyTypeContent = $derived(
    propertyTypes.find((t) => t.value === property.property_type)?.label ??
      "Select Type",
  );

  const propertySubtypeContent = $derived(
    propertySubtypes.find((t) => t.value === property.property_subtype)
      ?.label ?? "Select Subtype",
  );

  const transactionTypes = [
    { value: "sale", label: "Sale" },
    { value: "rental", label: "Rental" },
    { value: "lease", label: "Lease" },
  ];

  const propertyStatuses = [
    { value: "active", label: "Active" },
    { value: "pending", label: "Pending" },
    { value: "sold", label: "Sold" },
    { value: "off_market", label: "Off Market" },
  ];

  const transactionTypeContent = $derived(
    transactionTypes.find((t) => t.value === property.transaction_type)
      ?.label ?? "Select Type",
  );

  const statusContent = $derived(
    propertyStatuses.find((s) => s.value === property.status)?.label ??
      "Select Status",
  );

  // Format date from ISO string to YYYY-MM-DD for input[type="date"]
  function formatDateForInput(dateStr: string | null): string {
    if (!dateStr) return "";
    return new Date(dateStr).toISOString().split("T")[0];
  }

  // Format date from input to ISO string for database
  function formatDateForDb(dateStr: string | null): string | null {
    if (!dateStr) return null;
    return new Date(dateStr).toISOString();
  }

  let listDateInput = $state("");
  let closingDateInput = $state("");

  $effect(() => {
    listDateInput = formatDateForInput(property.list_date);
    closingDateInput = formatDateForInput(property.closing_date);
  });

  $effect(() => {
    property.list_date = listDateInput ? formatDateForDb(listDateInput) : null;
    property.closing_date = closingDateInput ? formatDateForDb(closingDateInput) : null;
  });

  let metadataString = $state("");

  $effect(() => {
    metadataString = property.metadata
      ? JSON.stringify(property.metadata, null, 2)
      : "";
  });

  $effect(() => {
    try {
      if (metadataString) {
        property.metadata = JSON.parse(metadataString);
      } else {
        property.metadata = {};
      }
    } catch (e) {
      // Invalid JSON, keep the string but don't update the metadata
    }
  });

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

    property = {
      ...data,
      list_date: formatDateForInput(data.list_date),
      closing_date: formatDateForInput(data.closing_date),
    };
    loading = false;
  }

  async function saveProperty() {
    loading = true;
    error = null;

    const propertyToSave = {
      ...property,
      list_date: formatDateForDb(property.list_date),
      closing_date: formatDateForDb(property.closing_date),
    };

    const { data, error: err } = await upsertProperty(propertyToSave);

    if (err) {
      error = err.message;
      loading = false;
      return;
    }

    // If this was a new property, redirect to the property's page
    if (isNew && data) {
      goto(`/properties/${data.id}`);
    }

    loading = false;
  }

  const actionItems = [
    {
      groupName: "Property",
      groupItems: [
        {
          icon: Save,
          label: "Save Property",
          onClick: saveProperty,
        },
      ],
    },
  ];

  $effect(() => {
    load();
  });
</script>

<PageTemplate {actionItems}>
  {#snippet TopCenter()}
    {isNew ? "New Property" : property.name || "Loading..."}
  {/snippet}

  {#snippet Middle()}
    {#if loading}
      <div class="flex items-center justify-center h-full">
        <div
          class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"
        ></div>
      </div>
    {:else if error}
      <div
        class="flex flex-col items-center justify-center h-full text-destructive"
      >
        <p>{error}</p>
        <button
          class="mt-4 px-4 py-2 bg-primary text-primary-foreground rounded-md hover:bg-primary/90"
          onclick={load}
        >
          Retry
        </button>
      </div>
    {:else}
      <div class="max-w-2xl mx-auto p-4 space-y-6">
        <!-- Address Information -->
        <div class="space-y-4">
          <h3 class="text-lg font-semibold">Address</h3>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div class="space-y-2">
              <Label for="address">Address</Label>
              <Input
                id="address"
                bind:value={property.address}
                placeholder="Street Address"
              />
            </div>

            <div class="space-y-2">
              <Label for="address2">Address 2</Label>
              <Input
                id="address2"
                bind:value={property.address2}
                placeholder="Unit, Suite, etc."
              />
            </div>

            <div class="space-y-2">
              <Label for="city">City</Label>
              <Input id="city" bind:value={property.city} />
            </div>

            <div class="space-y-2">
              <Label for="region">State/Region</Label>
              <Input id="region" bind:value={property.region} />
            </div>

            <div class="space-y-2">
              <Label for="postal">Postal Code</Label>
              <Input id="postal" bind:value={property.postal} />
            </div>

            <div class="space-y-2">
              <Label for="country">Country</Label>
              <Input id="country" bind:value={property.country} />
            </div>
          </div>
        </div>

        <!-- Property Details -->
        <div class="space-y-4">
          <h3 class="text-lg font-semibold">Property Details</h3>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div class="space-y-2">
              <Label for="beds">Bedrooms</Label>
              <Input id="beds" type="number" bind:value={property.beds} />
            </div>

            <div class="space-y-2">
              <Label for="baths">Bathrooms</Label>
              <Input
                id="baths"
                type="number"
                step="0.5"
                bind:value={property.baths}
              />
            </div>

            <div class="space-y-2">
              <Label for="year_built">Year Built</Label>
              <Input
                id="year_built"
                type="number"
                bind:value={property.year_built}
              />
            </div>

            <div class="space-y-2">
              <Label for="living_area">Living Area</Label>
              <Input
                id="living_area"
                type="number"
                bind:value={property.living_area}
              />
            </div>

            <div class="space-y-2">
              <Label for="land_area">Land Area</Label>
              <Input
                id="land_area"
                type="number"
                bind:value={property.land_area}
              />
            </div>

            <div class="space-y-2">
              <Label for="hoa_fees">HOA Fees</Label>
              <Input
                id="hoa_fees"
                type="number"
                bind:value={property.hoa_fees}
              />
            </div>
          </div>
        </div>

        <!-- Location -->
        <div class="space-y-4">
          <h3 class="text-lg font-semibold">Location Coordinates</h3>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div class="space-y-2">
              <Label for="lat">Latitude</Label>
              <Input
                id="lat"
                type="number"
                step="any"
                bind:value={property.lat}
              />
            </div>

            <div class="space-y-2">
              <Label for="lng">Longitude</Label>
              <Input
                id="lng"
                type="number"
                step="any"
                bind:value={property.lng}
              />
            </div>
          </div>
        </div>

        <!-- Property Type -->
        <div class="space-y-4">
          <h3 class="text-lg font-semibold">Property Type</h3>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div class="space-y-2">
              <Label for="property_type">Property Type</Label>
              <Select.Root type="single" bind:value={property.property_type}>
                <Select.Trigger class="w-full">
                  {propertyTypeContent}
                </Select.Trigger>
                <Select.Content>
                  <Select.Group>
                    {#each propertyTypes as type}
                      <Select.Item value={type.value}>{type.label}</Select.Item>
                    {/each}
                  </Select.Group>
                </Select.Content>
              </Select.Root>
            </div>

            <div class="space-y-2">
              <Label for="property_subtype">Property Subtype</Label>
              <Select.Root type="single" bind:value={property.property_subtype}>
                <Select.Trigger class="w-full">
                  {propertySubtypeContent}
                </Select.Trigger>
                <Select.Content>
                  <Select.Group>
                    {#each propertySubtypes as subtype}
                      <Select.Item value={subtype.value}
                        >{subtype.label}</Select.Item
                      >
                    {/each}
                  </Select.Group>
                </Select.Content>
              </Select.Root>
            </div>
          </div>
        </div>

        <!-- Transaction Information -->
        <div class="space-y-4">
          <h3 class="text-lg font-semibold">Transaction Details</h3>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div class="space-y-2">
              <Label for="transaction_type">Transaction Type</Label>
              <Select.Root type="single" bind:value={property.transaction_type}>
                <Select.Trigger class="w-full">
                  {transactionTypeContent}
                </Select.Trigger>
                <Select.Content>
                  <Select.Group>
                    {#each transactionTypes as type}
                      <Select.Item value={type.value}>{type.label}</Select.Item>
                    {/each}
                  </Select.Group>
                </Select.Content>
              </Select.Root>
            </div>

            <div class="space-y-2">
              <Label for="status">Status</Label>
              <Select.Root type="single" bind:value={property.status}>
                <Select.Trigger class="w-full">
                  {statusContent}
                </Select.Trigger>
                <Select.Content>
                  <Select.Group>
                    {#each propertyStatuses as status}
                      <Select.Item value={status.value}
                        >{status.label}</Select.Item
                      >
                    {/each}
                  </Select.Group>
                </Select.Content>
              </Select.Root>
            </div>

            <div class="space-y-2">
              <Label for="list_price">List Price</Label>
              <Input
                id="list_price"
                type="number"
                bind:value={property.list_price}
              />
            </div>

            <div class="space-y-2">
              <Label for="closing_price">Closing Price</Label>
              <Input
                id="closing_price"
                type="number"
                bind:value={property.closing_price}
              />
            </div>

            <div class="space-y-2">
              <Label for="list_date">List Date</Label>
              <Input
                id="list_date"
                type="date"
                bind:value={listDateInput}
              />
            </div>

            <div class="space-y-2">
              <Label for="closing_date">Closing Date</Label>
              <Input
                id="closing_date"
                type="date"
                bind:value={closingDateInput}
              />
            </div>
          </div>
        </div>

        <!-- Notes -->
        <div class="space-y-2">
          <Label for="notes">Notes</Label>
          <Textarea
            id="notes"
            bind:value={property.notes}
            placeholder="Additional notes about the property"
          />
        </div>

        <!-- Metadata -->
        <div class="space-y-2">
          <Label for="metadata">Metadata (JSON)</Label>
          <Textarea
            id="metadata"
            bind:value={metadataString}
            placeholder={"{}"}
            class="font-mono"
          />
        </div>
      </div>
    {/if}
  {/snippet}
</PageTemplate>
