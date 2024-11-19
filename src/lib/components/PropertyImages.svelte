<script lang="ts">
  import type { Property } from "$lib/services/propertyService.svelte";
  import {
    uploadImages,
    deletePropertyImage,
    type PropertyImage,
  } from "$lib/services/imageService.svelte";
  import ImageModal from "./ImageModal.svelte";

  let { property, onReload } = $props<{
    property: Partial<Property>;
    onReload: () => void;
  }>();

  let dragActive = $state(false);
  let files = $state<FileList | null>(null);
  let previews = $state<string[]>([]);
  let errorMessage = $state<string | null>(null);
  let isUploading = $state(false);
  let existingImages = $state<{ url: string; name: string }[]>([]);
  let isLoading = $state(true);
  let isDeletingImage = $state<{ [key: string]: boolean }>({});
  let selectedImage = $state<string | null>(null);
  let dragSource = $state<number | null>(null);

  const ALLOWED_TYPES = ["image/jpeg", "image/png", "image/gif"];

  function validateFiles(fileList: FileList): boolean {
    const invalidFiles = Array.from(fileList).filter(
      (file) => !ALLOWED_TYPES.includes(file.type),
    );

    if (invalidFiles.length > 0) {
      errorMessage = `Invalid file type(s): ${invalidFiles.map((f) => f.name).join(", ")}. Only JPG, PNG, and GIF files are allowed.`;
      return false;
    }

    errorMessage = null;
    return true;
  }

  function createPreviews(fileList: FileList) {
    if (!validateFiles(fileList)) {
      return;
    }

    // Create new preview URLs for the new files
    const newPreviews = Array.from(fileList)
      .filter((file) => file.type.startsWith("image/"))
      .map((file) => URL.createObjectURL(file));

    // Combine existing files with new files
    const dt = new DataTransfer();

    // Add existing files
    if (files) {
      Array.from(files).forEach((file) => dt.items.add(file));
    }

    // Add new files
    Array.from(fileList).forEach((file) => dt.items.add(file));

    // Update files
    files = dt.files;

    // Update previews
    previews = [...previews, ...newPreviews];
  }

  function handleDrag(e: DragEvent) {
    e.preventDefault();
    e.stopPropagation();
    if (e.type === "dragenter" || e.type === "dragover") {
      dragActive = true;
    } else if (e.type === "dragleave") {
      dragActive = false;
    }
  }

  function handleDrop(e: DragEvent) {
    e.preventDefault();
    e.stopPropagation();
    dragActive = false;
    if (e.dataTransfer?.files && e.dataTransfer.files.length > 0) {
      createPreviews(e.dataTransfer.files);
      console.log("Files dropped:", files);
    }
  }

  function handleChange(e: Event) {
    const target = e.target as HTMLInputElement;
    if (target.files && target.files.length > 0) {
      createPreviews(target.files);
      console.log("Files selected:", files);
    }
  }

  function removeFile(index: number) {
    // Convert FileList to Array to allow manipulation
    const fileArray = Array.from(files || []);
    // Remove the file at the specified index
    fileArray.splice(index, 1);

    // Revoke the URL for the removed preview
    if (previews[index]) {
      URL.revokeObjectURL(previews[index]);
    }

    // Update previews array
    const newPreviews = [...previews];
    newPreviews.splice(index, 1);
    previews = newPreviews;

    // Convert back to FileList-like object
    const dt = new DataTransfer();
    fileArray.forEach((file) => dt.items.add(file));
    files = dt.files;

    if (files.length === 0) {
      files = null;
    }
  }

  async function handleUpload() {
    if (!files || !property.id) return;

    try {
      isUploading = true;
      errorMessage = null;

      const result = await uploadImages(Array.from(files), property.id);

      if (result.success) {
        // Clear the files and previews after successful upload
        files = null;
        previews.forEach((url) => URL.revokeObjectURL(url));
        previews = [];
        console.log("Upload successful:", result.urls);

        // Refresh the list of existing images
        await loadExistingImages();
        onReload();
      } else if (result.error) {
        errorMessage = result.error;
      }
    } catch (error) {
      console.error("Upload failed:", error);
      errorMessage = "Failed to upload images. Please try again.";
    } finally {
      isUploading = false;
    }
  }

  // Load existing images when component mounts
  async function loadExistingImages() {
    if (!property.id) return;

    try {
      isLoading = true;
      errorMessage = null;

      if (property.metadata?.images) {
        existingImages = property.metadata.images;
      } else {
        existingImages = [];
      }
    } catch (error) {
      console.error("Error loading images:", error);
      errorMessage = "Failed to load existing images. Please try again.";
    } finally {
      isLoading = false;
    }
  }

  async function handleDeleteImage(fileName: string) {
    if (!property.id) return;

    try {
      isDeletingImage[fileName] = true;
      const result = await deletePropertyImage(property.id, fileName);

      if (result.success) {
        // Refresh the list after successful deletion
        existingImages = existingImages.filter((img) => img.name !== fileName);
        await loadExistingImages();
        onReload();
      } else {
        errorMessage = `Failed to delete image: ${result.error}`;
      }
    } catch (error) {
      console.error("Error deleting image:", error);
      errorMessage = "Failed to delete image. Please try again.";
    } finally {
      isDeletingImage[fileName] = false;
    }
  }

  function openModal(imageUrl: string) {
    selectedImage = imageUrl;
  }

  function closeModal() {
    selectedImage = null;
  }

  function handleDragStart(e: DragEvent, index: number) {
    dragSource = index;
    if (e.dataTransfer && e.target instanceof HTMLElement) {
      e.dataTransfer.effectAllowed = 'move';
      e.dataTransfer.setData('text/plain', index.toString());
      
      // Find the image element within the dragged container
      const container = e.target;
      const imgElement = container.querySelector('img');
      
      if (imgElement) {
        // Use the container itself as the drag image
        // This ensures we get the entire styled container with the image
        e.dataTransfer.setDragImage(container, container.offsetWidth / 2, container.offsetHeight / 2);
      }
    }
  }

  function handleDragOver(e: DragEvent, index: number) {
    if (dragSource === index) return;
    
    if (e.currentTarget instanceof HTMLElement) {
      e.currentTarget.classList.add("bg-gray-100");
    }
  }

  function handleDragLeave(e: DragEvent) {
    if (e.currentTarget instanceof HTMLElement) {
      e.currentTarget.classList.remove("bg-gray-100");
    }
  }

  function handleDragEnd(e: DragEvent) {
    if (e.currentTarget instanceof HTMLElement) {
      e.currentTarget.classList.remove("bg-gray-100");
    }
    dragSource = null;
  }

  function handleImageDrop(e: DragEvent, dropIndex: number) {
    if (dragSource === null || dragSource === dropIndex) return;
    
    const items = [...existingImages];
    const [removed] = items.splice(dragSource, 1);
    items.splice(dropIndex, 0, removed);
    existingImages = items;
    
    if (e.currentTarget instanceof HTMLElement) {
      e.currentTarget.classList.remove("bg-gray-100");
    }
    dragSource = null;
  }

  // Load images when property changes
  $effect(() => {
    if (property.id) {
      loadExistingImages();
    } else {
      // Clear existing images if no property id
      existingImages = [];
    }
  });

  // Cleanup previews when component is destroyed
  $effect.root(() => {
    if (previews.length > 0) {
      return () => {
        previews.forEach((url) => URL.revokeObjectURL(url));
      };
    }
  });
</script>

<div class="p-4">
  <h2 class="text-2xl font-semibold mb-4">Property Images</h2>

  {#if isLoading}
    <div class="text-center py-4">
      <span class="text-gray-600">Loading existing images...</span>
    </div>
  {:else if existingImages.length > 0}
    <div class="mb-6">
      <h3 class="text-lg font-semibold mb-2">Existing Images:</h3>
      <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
        {#each existingImages as image, i}
          <div
            class="relative aspect-square transition-colors"
            draggable="true"
            on:dragstart={(e) => handleDragStart(e, i)}
            on:dragover|preventDefault={(e) => handleDragOver(e, i)}
            on:dragleave={(e) => handleDragLeave(e)}
            on:dragend={(e) => handleDragEnd(e)}
            on:drop|preventDefault={(e) => handleImageDrop(e, i)}
          >
            <img
              src={image.url}
              alt="Property image"
              class="w-full h-40 object-cover rounded-lg shadow-sm cursor-pointer hover:opacity-90 transition-opacity"
              draggable="false"
              on:click|preventDefault={(e) => openModal(image.url)}
              on:keydown={(e) => {
                if (e.key === "Enter") openModal(image.url);
              }}
              role="button"
              tabindex="0"
            />
            <button
              type="button"
              class="absolute -top-2 -right-2 bg-gray-500 text-white rounded-full w-6 h-6 flex items-center justify-center
                     shadow-md hover:bg-gray-600 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2
                     disabled:opacity-50 disabled:cursor-not-allowed"
              on:click|preventDefault={(e) => handleDeleteImage(image.name)}
              disabled={isDeletingImage[image.name]}
              aria-label="Delete image"
            >
              <i class="fas fa-times"></i>
              {#if isDeletingImage[image.name]}
                <span class="loading loading-spinner loading-xs"></span>
              {/if}
            </button>
          </div>
        {/each}
      </div>
    </div>
  {/if}

  <div
    class="relative border-2 border-dashed rounded-lg p-8 text-center
           {dragActive ? 'border-blue-500 bg-blue-50' : 'border-gray-300'}"
    on:dragenter|preventDefault={(e) => handleDrag(e)}
    on:dragleave={(e) => handleDrag(e)}
    on:dragover|preventDefault={(e) => handleDrag(e)}
    on:drop|preventDefault={(e) => handleDrop(e)}
    role="region"
    aria-label="Image upload drop zone"
  >
    <input
      type="file"
      multiple
      accept=".jpg,.jpeg,.png,.gif,image/jpeg,image/png,image/gif"
      class="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
      on:change={(e) => handleChange(e)}
    />

    <div class="space-y-4">
      <div class="text-5xl text-gray-400">
        <i class="fas fa-cloud-upload-alt"></i>
      </div>
      <div class="text-lg">
        <span class="font-semibold">Drop your images here</span>
        <span class="text-gray-500"> or click to select</span>
      </div>
      <div class="text-sm text-gray-500">
        Supports: JPG, PNG, GIF only (Max 10MB each)
      </div>
    </div>
  </div>
  <div>
    {#if property?.metadata?.images}
      <div class="mt-4">
        {property?.metadata?.images?.length || 0} image(s)
      </div>
      <div class="mt-4">
        <h3 class="text-lg font-semibold">Property Metadata:</h3>
        <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
          {#each property.metadata.images as image}
            {image?.url}<br /><br />
          {/each}
        </div>
      </div>
    {/if}
  </div>

  {#if errorMessage}
    <div class="mt-4 p-4 bg-red-50 text-red-700 rounded-lg">
      {errorMessage}
    </div>
  {/if}

  {#if files}
    <div class="mt-4">
      <div class="flex justify-between items-center mb-4">
        <h3 class="text-lg font-semibold">Selected Files:</h3>
        <button
          type="button"
          class="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600
                 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2
                 disabled:opacity-50 disabled:cursor-not-allowed"
          on:click|preventDefault={(e) => handleUpload()}
          disabled={isUploading}
        >
          {isUploading ? "Uploading..." : "Upload Images"}
        </button>
      </div>
      <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
        {#each Array.from(files) as file, i}
          <div class="space-y-2 relative group">
            {#if previews[i]}
              <div class="relative">
                <img
                  src={previews[i]}
                  alt={file.name}
                  class="w-full h-40 object-cover rounded-lg shadow-sm"
                />
                <button
                  type="button"
                  class="absolute -top-2 -right-2 bg-gray-500 text-white rounded-full w-6 h-6 flex items-center justify-center
                         shadow-md hover:bg-gray-600 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2"
                  on:click|preventDefault={(e) => removeFile(i)}
                  aria-label="Remove image"
                >
                  ×
                </button>
              </div>
            {/if}
            <div class="text-sm text-gray-600 truncate">
              {file.name} ({Math.round(file.size / 1024)}KB)
            </div>
          </div>
        {/each}
      </div>
    </div>
  {/if}

  {#if selectedImage}
    <ImageModal imageUrl={selectedImage} onClose={closeModal} />
  {/if}
</div>
