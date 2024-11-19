<script lang="ts">
  let { imageUrl, onClose } = $props<{
    imageUrl: string;
    onClose: () => void;
  }>();

  function handleBackdropClick(event: MouseEvent) {
    // Only close if clicking the backdrop, not the image
    if ((event.target as HTMLElement).classList.contains("modal-backdrop")) {
      onClose();
    }
  }

  function handleKeydown(event: KeyboardEvent) {
    if (event.key === "Escape") {
      onClose();
    }
  }
</script>

<svelte:window onkeydown={handleKeydown} />

<div
  class="modal-backdrop fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
  role="dialog"
  aria-modal="true"
>
  <button
    class="absolute inset-0 w-full h-full cursor-default"
    onclick={handleBackdropClick}
    aria-label="Close modal"
  >
    <span class="sr-only">Close modal</span>
  </button>
  <div
    class="relative max-w-4xl max-h-[90vh] bg-white rounded-lg shadow-xl overflow-hidden"
  >
    <button
      type="button"
      class="absolute top-2 right-2 bg-gray-800 bg-opacity-50 text-white rounded-full w-8 h-8
             flex items-center justify-center hover:bg-opacity-75 focus:outline-none
             focus:ring-2 focus:ring-white"
      onclick={onClose}
      aria-label="Close modal"
    >
      ×
    </button>
    <img
      src={imageUrl}
      alt="Full size property image"
      class="max-h-[90vh] object-contain"
    />
  </div>
</div>
