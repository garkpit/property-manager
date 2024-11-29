<script lang="ts">
  import type { Property } from "$lib/services/propertyService.svelte";
  import { fade } from "svelte/transition";
  import PropertyImageGallery from "./PropertyImageGallery.svelte";

  const { property } = $props<{
    property: Property;
  }>();

  const formatDate = (date: string | null) => {
    if (!date) return "";
    return new Date(date).toLocaleDateString();
  };

  const formatPrice = (price: number | null) => {
    if (!price) return "N/A";
    return new Intl.NumberFormat("en-US", {
      style: "currency",
      currency: "USD",
      minimumFractionDigits: 0,
      maximumFractionDigits: 0,
    }).format(price);
  };
</script>

<!--<div class="max-w-4xl mx-auto p-6 space-y-8" transition:fade>
-->
<div
  id="property-details"
  class="w-full p-4 md:p-6 lg:p-8 space-y-8"
  transition:fade
>
  <!-- Property Header -->
  <div class="border-b border-border pb-6">
    {#if property.title}
      <h1 class="text-4xl font-bold text-foreground mb-2">{property.title}</h1>
    {/if}
    {#if property?.metadata?.images && property?.metadata?.images.length > 0}
      <div class="w-full">
        <PropertyImageGallery images={property.metadata.images} />
      </div>
    {/if}
    {#if property.subtitle}
      <h2 class="text-2xl text-muted-foreground mb-4">{property.subtitle}</h2>
    {/if}
    <h3 class="text-3xl font-bold text-foreground mb-2">
      {property.property_type} in {property.city}
    </h3>
    <p class="text-lg text-muted-foreground">
      {property.address}
      {#if property.address2}, {property.address2}{/if}
    </p>
  </div>

  <!-- Key Property Stats -->
  <div class="grid grid-cols-2 md:grid-cols-4 gap-6 py-6">
    <div
      class="text-center p-4 bg-muted/50 rounded-lg hover:bg-muted transition-colors duration-200"
    >
      <span class="block text-2xl font-bold text-foreground">{property.beds}</span>
      <span class="text-muted-foreground">Beds</span>
    </div>
    <div
      class="text-center p-4 bg-muted/50 rounded-lg hover:bg-muted transition-colors duration-200"
    >
      <span class="block text-2xl font-bold text-foreground">{property.baths}</span>
      <span class="text-muted-foreground">Baths</span>
    </div>
    <div
      class="text-center p-4 bg-muted/50 rounded-lg hover:bg-muted transition-colors duration-200"
    >
      <span class="block text-2xl font-bold text-foreground">{property.living_area}</span>
      <span class="text-muted-foreground">Sq Ft</span>
    </div>
    <div
      class="text-center p-4 bg-muted/50 rounded-lg hover:bg-muted transition-colors duration-200"
    >
      <span class="block text-2xl font-bold text-foreground">{property.year_built}</span>
      <span class="text-muted-foreground">Year Built</span>
    </div>
  </div>

  <!-- Property Details -->
  <div class="bg-card rounded-xl shadow-sm p-6 space-y-6">
    <h3 class="text-xl font-semibold text-foreground border-b border-border pb-4">
      Property Details
    </h3>
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
      <div class="space-y-4">
        <div class="flex justify-between items-center py-2 border-b border-border">
          <span class="text-muted-foreground">Property Type</span>
          <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium
            {property.property_type === 'Residential'
              ? 'bg-blue-100 text-blue-800 dark:bg-blue-950 dark:text-blue-200'
              : property.property_type === 'Commercial'
                ? 'bg-purple-100 text-purple-800 dark:bg-purple-950 dark:text-purple-200'
                : property.property_type === 'Land'
                  ? 'bg-emerald-100 text-emerald-800 dark:bg-emerald-950 dark:text-emerald-200'
                  : 'bg-gray-100 text-gray-800 dark:bg-gray-800 dark:text-gray-200'}">
            {property.property_type}
          </span>
        </div>
        <div class="flex justify-between items-center py-2 border-b border-border">
          <span class="text-muted-foreground">Subtype</span>
          <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium
            {property.property_subtype?.includes('Single Family')
              ? 'bg-sky-100 text-sky-800 dark:bg-sky-950 dark:text-sky-200'
              : property.property_subtype?.includes('Condo')
                ? 'bg-indigo-100 text-indigo-800 dark:bg-indigo-950 dark:text-indigo-200'
                : property.property_subtype?.includes('Multi-Family')
                  ? 'bg-violet-100 text-violet-800 dark:bg-violet-950 dark:text-violet-200'
                  : property.property_subtype?.includes('Office')
                    ? 'bg-amber-100 text-amber-800 dark:bg-amber-950 dark:text-amber-200'
                    : property.property_subtype?.includes('Retail')
                      ? 'bg-rose-100 text-rose-800 dark:bg-rose-950 dark:text-rose-200'
                      : 'bg-gray-100 text-gray-800 dark:bg-gray-800 dark:text-gray-200'}">
            {property.property_subtype}
          </span>
        </div>
        <div class="flex justify-between items-center py-2 border-b border-border">
          <span class="text-muted-foreground">Living Area</span>
          <span class="font-medium text-foreground">{property.living_area} sq ft</span>
        </div>
      </div>
      <div class="space-y-4">
        <div class="flex justify-between items-center py-2 border-b border-border">
          <span class="text-muted-foreground">Land Area</span>
          <span class="font-medium text-foreground">{property.land_area} sq ft</span>
        </div>
        <div class="flex justify-between items-center py-2 border-b border-border">
          <span class="text-muted-foreground">Status</span>
          <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium
            {property.status === 'Active'
              ? 'bg-green-100 text-green-800 dark:bg-green-950 dark:text-green-200'
              : property.status === 'Pending'
                ? 'bg-yellow-100 text-yellow-800 dark:bg-yellow-950 dark:text-yellow-200'
                : 'bg-gray-100 text-gray-800 dark:bg-gray-800 dark:text-gray-200'}">
            {property.status}
          </span>
        </div>
        <div class="flex justify-between items-center py-2 border-b border-border">
          <span class="text-muted-foreground">Transaction Type</span>
          <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium
            {property.transaction_type === 'Sale'
              ? 'bg-teal-100 text-teal-800 dark:bg-teal-950 dark:text-teal-200'
              : property.transaction_type === 'Rental'
                ? 'bg-orange-100 text-orange-800 dark:bg-orange-950 dark:text-orange-200'
                : property.transaction_type === 'Lease'
                  ? 'bg-cyan-100 text-cyan-800 dark:bg-cyan-950 dark:text-cyan-200'
                  : 'bg-gray-100 text-gray-800 dark:bg-gray-800 dark:text-gray-200'}">
            {property.transaction_type}
          </span>
        </div>
      </div>
    </div>
  </div>

  <!-- Financial Details -->
  <div class="bg-card rounded-xl shadow-sm p-6 space-y-6">
    <h3 class="text-xl font-semibold text-foreground border-b border-border pb-4">
      Financial Details
    </h3>
    <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
      <div class="space-y-2">
        <span class="text-sm text-muted-foreground">List Price</span>
        <p class="text-2xl font-bold text-foreground">
          {formatPrice(property.list_price)}
        </p>
        <span class="text-sm text-muted-foreground">Listed on {formatDate(property.list_date)}</span>
      </div>
      {#if property.sale_price}
        <div class="space-y-2">
          <span class="text-sm text-muted-foreground">Sale Price</span>
          <p class="text-2xl font-bold text-foreground">
            {formatPrice(property.sale_price)}
          </p>
          <span class="text-sm text-muted-foreground">Closed on {formatDate(property.closing_date)}</span>
        </div>
      {/if}
    </div>
  </div>

  <!-- Additional Information -->
  {#if property.notes}
    <div class="bg-card rounded-xl shadow-sm p-6 space-y-4">
      <h3 class="text-xl font-semibold text-foreground border-b border-border pb-4">
        Additional Information
      </h3>
      <div class="prose max-w-none">
        <p class="text-muted-foreground leading-relaxed whitespace-pre-wrap">
          {property.notes}
        </p>
      </div>
    </div>
  {/if}

  <!-- Location -->
  <div class="bg-card rounded-xl shadow-sm p-6 space-y-4">
    <h3 class="text-xl font-semibold text-foreground border-b border-border pb-4">Location</h3>
    <div class="text-muted-foreground">
      <p class="mb-2">{property.address}</p>
      {#if property.address2}
        <p class="mb-2">{property.address2}</p>
      {/if}
      <p>{property.city}, {property.region} {property.postal}</p>
      <p>{property.country}</p>
    </div>
  </div>
</div>

<style>
  /* Add smooth transitions */
  .transition-colors {
    transition-property: background-color, border-color, color, fill, stroke;
    transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
    transition-duration: 150ms;
  }

  /* Hover effects */
  .hover\:bg-gray-100:hover {
    --tw-bg-opacity: 1;
    background-color: rgba(243, 244, 246, var(--tw-bg-opacity));
  }

  /* Typography improvements */
  .prose {
    max-width: 65ch;
    color: #374151;
  }

  .prose p {
    margin-top: 1.25em;
    margin-bottom: 1.25em;
  }
</style>
