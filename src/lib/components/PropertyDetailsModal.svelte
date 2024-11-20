<script lang="ts">
  import type { Property } from "$lib/services/propertyService.svelte";
  import PropertyDetails from "./PropertyDetails.svelte";
  import { fade, scale } from "svelte/transition";
  import { X } from "lucide-svelte";
  import { createEventDispatcher } from "svelte";

  const dispatch = createEventDispatcher();

  const { property, isOpen } = $props<{
    property: Property;
    isOpen: boolean;
  }>();

  function handleClose() {
    dispatch('update:isOpen', false);
  }
</script>

{#if isOpen}
  <!-- Modal Backdrop -->
  <div
    class="fixed inset-0 bg-black bg-opacity-50 z-[9999] flex items-center justify-center"
    transition:fade
    on:click={handleClose}
  >
    <!-- Modal Content -->
    <div
      class="bg-white dark:bg-gray-800 rounded-lg w-full max-w-4xl max-h-[90vh] overflow-y-auto mx-4 relative"
      transition:scale
      on:click|stopPropagation
    >
      <!-- Close Button -->
      <button
        class="absolute top-4 right-4 p-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-full transition-colors"
        on:click={handleClose}
      >
        <X size={24} />
      </button>

      <PropertyDetails {property} />
    </div>
  </div>
{/if}

<style>
  /* Add smooth scrollbar for the modal content */
  .overflow-y-auto {
    scrollbar-width: thin;
    scrollbar-color: #CBD5E0 #F7FAFC;
  }

  .overflow-y-auto::-webkit-scrollbar {
    width: 8px;
  }

  .overflow-y-auto::-webkit-scrollbar-track {
    background: #F7FAFC;
  }

  .overflow-y-auto::-webkit-scrollbar-thumb {
    background-color: #CBD5E0;
    border-radius: 4px;
  }
</style>
