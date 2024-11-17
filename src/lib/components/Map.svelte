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
      style: {
        version: 8,
        sources: {
          osm: {
            type: 'raster',
            tiles: ['https://tile.openstreetmap.org/{z}/{x}/{y}.png'],
            tileSize: 256,
            attribution: '&copy; OpenStreetMap Contributors',
            maxzoom: 19
          }
        },
        layers: [
          {
            id: 'osm',
            type: 'raster',
            source: 'osm',
            minzoom: 0,
            maxzoom: 19
          }
        ]
      },
      center: [-74.5, 40], // Default center (New York)
      zoom: 13,
      pitch: 45,
      bearing: -17.6,
      antialias: true
    });

    // Add navigation controls (including rotation)
    map.addControl(new maplibregl.NavigationControl({
      visualizePitch: true
    }));

    // Add scale control
    map.addControl(new maplibregl.ScaleControl({
      maxWidth: 80,
      unit: 'metric'
    }));

    // Add fullscreen control
    map.addControl(new maplibregl.FullscreenControl());

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
