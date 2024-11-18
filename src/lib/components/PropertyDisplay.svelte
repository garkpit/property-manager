<script lang="ts">
  import type { Property } from "$lib/services/propertyService.svelte";

  const { property } = $props<{
    property: Property;
  }>();

  const formatDate = (date: string | null) => {
    if (!date) return '';
    return new Date(date).toLocaleDateString();
  };
</script>

<div class="max-w-2xl mx-auto p-4 space-y-6">
  <!-- Address Information -->
  <div class="space-y-4">
    <h3 class="text-lg font-semibold">Address</h3>
    <div class="grid grid-cols-1 gap-2">
      <p>{property.address}</p>
      {#if property.address2}
        <p>{property.address2}</p>
      {/if}
      <p>{property.city}, {property.region} {property.postal}</p>
      <p>{property.country}</p>
    </div>
  </div>

  <!-- Property Details -->
  <div class="space-y-4">
    <h3 class="text-lg font-semibold">Property Details</h3>
    <div class="grid grid-cols-2 gap-4">
      <div>
        <span class="font-medium">Type:</span> {property.property_type}
      </div>
      <div>
        <span class="font-medium">Subtype:</span> {property.property_subtype}
      </div>
      <div>
        <span class="font-medium">Beds:</span> {property.beds}
      </div>
      <div>
        <span class="font-medium">Baths:</span> {property.baths}
      </div>
      <div>
        <span class="font-medium">Living Area:</span> {property.living_area} sq ft
      </div>
      <div>
        <span class="font-medium">Land Area:</span> {property.land_area} sq ft
      </div>
      <div>
        <span class="font-medium">Year Built:</span> {property.year_built}
      </div>
    </div>
  </div>

  <!-- Transaction Information -->
  <div class="space-y-4">
    <h3 class="text-lg font-semibold">Transaction Information</h3>
    <div class="grid grid-cols-2 gap-4">
      <div>
        <span class="font-medium">Transaction Type:</span> {property.transaction_type}
      </div>
      <div>
        <span class="font-medium">Status:</span> {property.status}
      </div>
      <div>
        <span class="font-medium">List Date:</span> {formatDate(property.list_date)}
      </div>
      <div>
        <span class="font-medium">Closing Date:</span> {formatDate(property.closing_date)}
      </div>
      <div>
        <span class="font-medium">List Price:</span> ${property.list_price?.toLocaleString()}
      </div>
      <div>
        <span class="font-medium">Sale Price:</span> ${property.sale_price?.toLocaleString()}
      </div>
    </div>
  </div>

  <!-- Additional Information -->
  {#if property.notes}
    <div class="space-y-4">
      <h3 class="text-lg font-semibold">Additional Information</h3>
      <div class="bg-muted p-4 rounded-lg">
        <p class="whitespace-pre-wrap">{property.notes}</p>
      </div>
    </div>
  {/if}
</div>
