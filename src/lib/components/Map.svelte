<!-- Map.svelte -->
<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import maplibregl from 'maplibre-gl';
  import 'maplibre-gl/dist/maplibre-gl.css';

  let mapContainer: HTMLDivElement;
  let map: maplibregl.Map;

  onMount(() => {
    map = new maplibregl.Map({
      container: mapContainer,
      style: 'https://demotiles.maplibre.org/style.json',
      center: [-74.5, 40], // Default center (New York)
      zoom: 9
    });

    // Add navigation controls
    map.addControl(new maplibregl.NavigationControl());

    // Ensure map fills container after initialization
    map.resize();
  });

  onDestroy(() => {
    if (map) {
      map.remove();
    }
  });
</script>

<div bind:this={mapContainer} class="map-container" />

<style>
  .map-container {
    width: 100%;
    height: 100%;
  }

  :global(.maplibregl-canvas) {
    width: 100% !important;
    height: 100% !important;
  }
</style>
