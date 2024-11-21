<script lang="ts">
  import { fade } from "svelte/transition";
  import { ChevronLeft, ChevronRight } from "lucide-svelte";

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
      class="w-full bg-black/50 text-white p-2 rounded-b-lg flex items-center justify-between"
    >
      <button
        class="p-1 hover:bg-black/30 rounded-full transition-colors disabled:opacity-50"
        on:click={previousImage}
        disabled={currentImageIndex === 0}
      >
        <ChevronLeft size={24} />
      </button>
      <span class="text-sm font-medium">
        Image {currentImageIndex + 1} of {totalImages}
      </span>
      <button
        class="p-1 hover:bg-black/30 rounded-full transition-colors disabled:opacity-50"
        on:click={nextImage}
        disabled={currentImageIndex === totalImages - 1}
      >
        <ChevronRight size={24} />
      </button>
    </div>
  </div>
{/if}

<style>
  /* Ensure smooth image transitions */
  img {
    transition: all 0.3s ease-in-out;
  }
</style>
