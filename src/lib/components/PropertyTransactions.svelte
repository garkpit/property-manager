<script lang="ts">
  import type { Property } from "$lib/services/propertyService.svelte";

  let { property } = $props<{
    property: Partial<Property>;
  }>();
</script>

<div class="p-4">
  <h2 class="text-2xl font-semibold mb-4">Property Transactions</h2>
  <p class="text-gray-500">Property transactions...</p>
</div>
