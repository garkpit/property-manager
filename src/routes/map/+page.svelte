<!-- +page.svelte -->
<script lang="ts">
  import PageTemplate from "$lib/components/PageTemplate.svelte";
  import Map from '$lib/components/Map.svelte';
</script>

<PageTemplate>
  {#snippet TopCenter()}
    Interactive Map
  {/snippet}

  {#snippet Middle()}
    <div class="map-wrapper">
      <Map />
    </div>
  {/snippet}
</PageTemplate>

<style>
  .map-wrapper {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    height: calc(100vh - var(--header-height) - var(--footer-height));
    margin: -1rem;
  }
</style>
