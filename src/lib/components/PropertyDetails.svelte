<script lang="ts">
  import type { Property } from "$lib/services/propertyService.svelte";
  import { fade } from "svelte/transition";

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

<div class="max-w-4xl mx-auto p-6 space-y-8" transition:fade>
  <!-- Property Header -->
  <div class="border-b border-gray-200 pb-6">
    {#if property.title}
      <h1 class="text-4xl font-bold text-gray-900 mb-2">{property.title}</h1>
    {/if}
    {#if property?.metadata?.images && property?.metadata?.images.length > 0}
      <!-- Thumbnail Image -->
      <div class="mb-6">
        <img
          src={property.metadata.images[0].url}
          alt={property.title || "Property Image"}
          class="w-full object-contain rounded-lg shadow-md"
        />
      </div>
    {/if}
    {#if property.subtitle}
      <h2 class="text-2xl text-gray-700 mb-4">{property.subtitle}</h2>
    {/if}
    <h3 class="text-3xl font-bold text-gray-900 mb-2">
      {property.property_type} in {property.city}
    </h3>
    <p class="text-lg text-gray-600">
      {property.address}
      {#if property.address2}, {property.address2}{/if}
    </p>
  </div>

  <!-- Key Property Stats -->
  <div class="grid grid-cols-2 md:grid-cols-4 gap-6 py-6">
    <div
      class="text-center p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors duration-200"
    >
      <span class="block text-2xl font-bold text-gray-900">{property.beds}</span
      >
      <span class="text-gray-600">Beds</span>
    </div>
    <div
      class="text-center p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors duration-200"
    >
      <span class="block text-2xl font-bold text-gray-900"
        >{property.baths}</span
      >
      <span class="text-gray-600">Baths</span>
    </div>
    <div
      class="text-center p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors duration-200"
    >
      <span class="block text-2xl font-bold text-gray-900"
        >{property.living_area}</span
      >
      <span class="text-gray-600">Sq Ft</span>
    </div>
    <div
      class="text-center p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors duration-200"
    >
      <span class="block text-2xl font-bold text-gray-900"
        >{property.year_built}</span
      >
      <span class="text-gray-600">Year Built</span>
    </div>
  </div>

  <!-- Property Details -->
  <div class="bg-white rounded-xl shadow-sm p-6 space-y-6">
    <h3 class="text-xl font-semibold text-gray-900 border-b pb-4">
      Property Details
    </h3>
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
      <div class="space-y-4">
        <div
          class="flex justify-between items-center py-2 border-b border-gray-100"
        >
          <span class="text-gray-600">Property Type</span>
          <span
            class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium
            {property.property_type === 'Residential'
              ? 'bg-blue-100 text-blue-800'
              : property.property_type === 'Commercial'
                ? 'bg-purple-100 text-purple-800'
                : property.property_type === 'Land'
                  ? 'bg-emerald-100 text-emerald-800'
                  : 'bg-gray-100 text-gray-800'}"
          >
            {property.property_type}
          </span>
        </div>
        <div
          class="flex justify-between items-center py-2 border-b border-gray-100"
        >
          <span class="text-gray-600">Subtype</span>
          <span
            class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium
            {property.property_subtype?.includes('Single Family')
              ? 'bg-sky-100 text-sky-800'
              : property.property_subtype?.includes('Condo')
                ? 'bg-indigo-100 text-indigo-800'
                : property.property_subtype?.includes('Multi-Family')
                  ? 'bg-violet-100 text-violet-800'
                  : property.property_subtype?.includes('Office')
                    ? 'bg-amber-100 text-amber-800'
                    : property.property_subtype?.includes('Retail')
                      ? 'bg-rose-100 text-rose-800'
                      : 'bg-gray-100 text-gray-800'}"
          >
            {property.property_subtype}
          </span>
        </div>
        <div
          class="flex justify-between items-center py-2 border-b border-gray-100"
        >
          <span class="text-gray-600">Living Area</span>
          <span class="font-medium text-gray-900"
            >{property.living_area} sq ft</span
          >
        </div>
      </div>
      <div class="space-y-4">
        <div
          class="flex justify-between items-center py-2 border-b border-gray-100"
        >
          <span class="text-gray-600">Land Area</span>
          <span class="font-medium text-gray-900"
            >{property.land_area} sq ft</span
          >
        </div>
        <div
          class="flex justify-between items-center py-2 border-b border-gray-100"
        >
          <span class="text-gray-600">Status</span>
          <span
            class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium
            {property.status === 'Active'
              ? 'bg-green-100 text-green-800'
              : property.status === 'Pending'
                ? 'bg-yellow-100 text-yellow-800'
                : 'bg-gray-100 text-gray-800'}"
          >
            {property.status}
          </span>
        </div>
        <div
          class="flex justify-between items-center py-2 border-b border-gray-100"
        >
          <span class="text-gray-600">Transaction Type</span>
          <span
            class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium
            {property.transaction_type === 'Sale'
              ? 'bg-teal-100 text-teal-800'
              : property.transaction_type === 'Rental'
                ? 'bg-orange-100 text-orange-800'
                : property.transaction_type === 'Lease'
                  ? 'bg-cyan-100 text-cyan-800'
                  : 'bg-gray-100 text-gray-800'}"
          >
            {property.transaction_type}
          </span>
        </div>
      </div>
    </div>
  </div>

  <!-- Financial Details -->
  <div class="bg-white rounded-xl shadow-sm p-6 space-y-6">
    <h3 class="text-xl font-semibold text-gray-900 border-b pb-4">
      Financial Details
    </h3>
    <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
      <div class="space-y-2">
        <span class="text-sm text-gray-600">List Price</span>
        <p class="text-2xl font-bold text-gray-900">
          {formatPrice(property.list_price)}
        </p>
        <span class="text-sm text-gray-500"
          >Listed on {formatDate(property.list_date)}</span
        >
      </div>
      {#if property.sale_price}
        <div class="space-y-2">
          <span class="text-sm text-gray-600">Sale Price</span>
          <p class="text-2xl font-bold text-gray-900">
            {formatPrice(property.sale_price)}
          </p>
          <span class="text-sm text-gray-500"
            >Closed on {formatDate(property.closing_date)}</span
          >
        </div>
      {/if}
    </div>
  </div>

  <!-- Additional Information -->
  {#if property.notes}
    <div class="bg-white rounded-xl shadow-sm p-6 space-y-4">
      <h3 class="text-xl font-semibold text-gray-900 border-b pb-4">
        Additional Information
      </h3>
      <div class="prose max-w-none">
        <p class="text-gray-700 leading-relaxed whitespace-pre-wrap">
          {property.notes}
        </p>
      </div>
    </div>
  {/if}

  <!-- Location -->
  <div class="bg-white rounded-xl shadow-sm p-6 space-y-4">
    <h3 class="text-xl font-semibold text-gray-900 border-b pb-4">Location</h3>
    <div class="text-gray-700">
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
