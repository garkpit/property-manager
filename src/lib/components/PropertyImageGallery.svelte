<script lang="ts">
  import { fade } from "svelte/transition";
  import {
    ChevronLeft,
    ChevronRight,
    ChevronsLeft,
    ChevronsRight,
  } from "lucide-svelte";

  const { images = $bindable() } = $props<{
    images: Array<{ url: string }>;
  }>();

  let currentImageIndex = $state(0);
  const totalImages = $derived(images.length);
  const currentImage = $derived(images[currentImageIndex]?.url);

  function nextImage() {
    if (currentImageIndex < totalImages - 1) {
      currentImageIndex++;
    }
  }

  function previousImage() {
    if (currentImageIndex > 0) {
      currentImageIndex--;
    }
  }

  function firstImage() {
    currentImageIndex = 0;
  }

  function lastImage() {
    currentImageIndex = totalImages - 1;
  }
</script>

{#if images && images.length > 0}
  <!-- Container with 4:3 aspect ratio -->
  <div class="relative mb-6">
    <div class="w-full pb-[75%] relative">
      <!-- Image container with theme-aware background -->
      <div class="absolute inset-0 bg-background rounded-t-lg">
        <img
          src={currentImage}
          alt="Property Image"
          class="w-full h-full object-contain rounded-t-lg"
        />
      </div>
    </div>
    <!-- Navigation Bar (moved outside the image container) -->
    <div
      class="w-full text-gray-700 p-2 rounded-b-lg flex items-center justify-between"
    >
      <div class="flex items-center gap-1">
        <button
          class="p-1 hover:bg-black/30 rounded-full transition-colors disabled:opacity-50"
          on:click={firstImage}
          disabled={currentImageIndex === 0}
          aria-label="First image"
        >
          <ChevronsLeft size={24} />
        </button>
        <button
          class="p-1 hover:bg-black/30 rounded-full transition-colors disabled:opacity-50"
          on:click={previousImage}
          disabled={currentImageIndex === 0}
          aria-label="Previous image"
        >
          <ChevronLeft size={24} />
        </button>
      </div>
      <span class="text-sm font-medium">
        {currentImageIndex + 1} of {totalImages}
      </span>
      <div class="flex items-center gap-1">
        <button
          class="p-1 hover:bg-black/30 rounded-full transition-colors disabled:opacity-50"
          on:click={nextImage}
          disabled={currentImageIndex === totalImages - 1}
          aria-label="Next image"
        >
          <ChevronRight size={24} />
        </button>
        <button
          class="p-1 hover:bg-black/30 rounded-full transition-colors disabled:opacity-50"
          on:click={lastImage}
          disabled={currentImageIndex === totalImages - 1}
          aria-label="Last image"
        >
          <ChevronsRight size={24} />
        </button>
      </div>
    </div>
  </div>
{/if}

<style>
  /* Ensure smooth image transitions */
  img {
    transition: all 0.3s ease-in-out;
  }
</style>
