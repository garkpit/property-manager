<script lang="ts">
  import type { Property } from "$lib/services/propertyService.svelte";
  import { upsertProperty } from "$lib/services/propertyService.svelte";
  import * as Select from "$lib/components/ui/select";
  import { Input } from "$lib/components/ui/input";
  import { Textarea } from "$lib/components/ui/textarea";
  import { Label } from "$lib/components/ui/label";
  import { Button } from "$lib/components/ui/button";
  import { Save } from "lucide-svelte";
  import { goto } from "$app/navigation";

  const { property } = $props<{
    property: Partial<Property>;
  }>();

  let loading = $state(false);
  let error = $state<string | null>(null);

  async function saveProperty() {
    console.log("saveProperty", property);
    loading = true;
    error = null;

    const { error: err } = await upsertProperty(property);

    if (err) {
      error = err.message;
      loading = false;
      return;
    }

    loading = false;
    goto("/properties");
  }

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
    property.closing_date = closingDateInput
      ? formatDateForDb(closingDateInput)
      : null;
  });

  const propertyTypeContent = $derived(
    propertyTypes.find((t) => t.value === property.property_type)?.label ??
      "Select property type",
  );

  const propertySubtypeContent = $derived(
    propertySubtypes.find((t) => t.value === property.property_subtype)
      ?.label ?? "Select property subtype",
  );

  const transactionTypeContent = $derived(
    transactionTypes.find((t) => t.value === property.transaction_type)
      ?.label ?? "Select transaction type",
  );

  const statusContent = $derived(
    propertyStatuses.find((s) => s.value === property.status)?.label ??
      "Select status",
  );
</script>

<div class="max-w-2xl mx-auto p-4 space-y-6">
  <!-- Address Information -->
  <div class="space-y-4">
    <h3 class="text-lg font-semibold">Address</h3>
    <div class="grid grid-cols-1 gap-4">
      <div class="space-y-2">
        <Label for="address">Address</Label>
        <Input id="address" bind:value={property.address} />
      </div>
      <div class="space-y-2">
        <Label for="address2">Address 2</Label>
        <Input id="address2" bind:value={property.address2} />
      </div>
      <div class="grid grid-cols-2 gap-4">
        <div class="space-y-2">
          <Label for="city">City</Label>
          <Input id="city" bind:value={property.city} />
        </div>
        <div class="space-y-2">
          <Label for="region">Region</Label>
          <Input id="region" bind:value={property.region} />
        </div>
      </div>
      <div class="grid grid-cols-2 gap-4">
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
            {#each propertyTypes as type}
              <Select.Item value={type.value}>{type.label}</Select.Item>
            {/each}
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
            {#each propertySubtypes as type}
              <Select.Item value={type.value}>{type.label}</Select.Item>
            {/each}
          </Select.Content>
        </Select.Root>
      </div>
    </div>
  </div>

  <!-- Property Details -->
  <div class="space-y-4">
    <h3 class="text-lg font-semibold">Property Details</h3>
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <div class="space-y-2">
        <Label for="beds">Beds</Label>
        <Input
          id="beds"
          type="number"
          bind:value={property.beds}
          min="0"
          step="1"
        />
      </div>
      <div class="space-y-2">
        <Label for="baths">Baths</Label>
        <Input
          id="baths"
          type="number"
          bind:value={property.baths}
          min="0"
          step="0.5"
        />
      </div>
      <div class="space-y-2">
        <Label for="living_area">Living Area (sqft)</Label>
        <Input
          id="living_area"
          type="number"
          bind:value={property.living_area}
          min="0"
          step="1"
        />
      </div>
      <div class="space-y-2">
        <Label for="land_area">Land Area (sqft)</Label>
        <Input
          id="land_area"
          type="number"
          bind:value={property.land_area}
          min="0"
          step="1"
        />
      </div>
      <div class="space-y-2">
        <Label for="year_built">Year Built</Label>
        <Input
          id="year_built"
          type="number"
          bind:value={property.year_built}
          min="1800"
          max={new Date().getFullYear()}
          step="1"
        />
      </div>
    </div>
  </div>

  <!-- Transaction Details -->
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
            {#each transactionTypes as type}
              <Select.Item value={type.value}>{type.label}</Select.Item>
            {/each}
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
            {#each propertyStatuses as status}
              <Select.Item value={status.value}>{status.label}</Select.Item>
            {/each}
          </Select.Content>
        </Select.Root>
      </div>
      <div class="space-y-2">
        <Label for="list_date">List Date</Label>
        <Input id="list_date" type="date" bind:value={listDateInput} />
      </div>
      <div class="space-y-2">
        <Label for="closing_date">Closing Date</Label>
        <Input id="closing_date" type="date" bind:value={closingDateInput} />
      </div>
    </div>
  </div>

  <!-- Additional Information -->
  <div class="space-y-4">
    <h3 class="text-lg font-semibold">Additional Information</h3>
    <div class="space-y-2">
      <Label for="notes">Notes</Label>
      <Textarea
        id="notes"
        bind:value={property.notes}
        rows={4}
        placeholder="Add any additional notes about the property"
      />
    </div>
  </div>

  {#if error}
    <div class="text-destructive mb-4">{error}</div>
  {/if}

  <div class="flex justify-end">
    <Button onclick={saveProperty} disabled={loading}>
      <Save class="mr-2 h-4 w-4" />
      {loading ? "Saving..." : "Save"}
    </Button>
  </div>
</div>
