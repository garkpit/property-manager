<script lang="ts">
  import type { Property } from "$lib/services/propertyService.svelte";

  let { property } = $props<{
    property: Partial<Property>;
  }>();

  let dragActive = $state(false);
  let files = $state<FileList | null>(null);

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
    if (e.dataTransfer?.files) {
      files = e.dataTransfer.files;
      // Handle files here
      console.log("Files dropped:", files);
    }
  }

  function handleChange(e: Event) {
    const target = e.target as HTMLInputElement;
    if (target.files) {
      files = target.files;
      // Handle files here
      console.log("Files selected:", files);
    }
  }
</script>

<div class="p-4">
  <h2 class="text-2xl font-semibold mb-4">Property Images</h2>

  <div
    class="relative border-2 border-dashed rounded-lg p-8 text-center
           {dragActive ? 'border-blue-500 bg-blue-50' : 'border-gray-300'}"
    ondragenter={handleDrag}
    ondragleave={handleDrag}
    ondragover={handleDrag}
    ondrop={handleDrop}
    role="region"
    aria-label="Image upload drop zone"
  >
    <input
      type="file"
      multiple
      accept="image/*"
      class="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
      onchange={handleChange}
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
        Supports: JPG, PNG, GIF (Max 10MB each)
      </div>
    </div>
  </div>

  {#if files}
    <div class="mt-4">
      <h3 class="text-lg font-semibold mb-2">Selected Files:</h3>
      <ul class="space-y-2">
        {#each Array.from(files) as file}
          <li class="text-sm text-gray-600">
            {file.name} ({Math.round(file.size / 1024)}KB)
          </li>
        {/each}
      </ul>
    </div>
  {/if}
</div>
