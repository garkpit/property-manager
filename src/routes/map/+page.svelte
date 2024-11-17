<!-- +page.svelte -->
<script lang="ts">
  import PageTemplate from "$lib/components/PageTemplate.svelte";
  import Map from "$lib/components/Map.svelte";
  import MapPins from "$lib/components/MapPins.svelte";
  import type maplibregl from "maplibre-gl";
  import { OverpassService } from "$lib/services/overpass";

  let map = $state<maplibregl.Map>();

  const load = async () => {
    const overpass = new OverpassService();
    const places = await overpass.findNearbyPlaces(
      { lat: 37.7749, lon: -122.4194 }, // San Francisco coordinates
      "coffee shop",
    );
    console.log(places);
  };
  $effect(() => {
    load();
  });

  // Example locations
  const locations = [
    { lat: 40.7128, lng: -74.006, title: "New York City" },
    { lat: 34.0522, lng: -118.2437, title: "Los Angeles" },
    { lat: 41.8781, lng: -87.6298, title: "Chicago" },
  ];
</script>

<PageTemplate>
  {#snippet TopCenter()}
    Interactive Map
  {/snippet}

  {#snippet Middle()}
    <div class="map-wrapper">
      <Map bind:map>
        {#snippet content()}
          <MapPins {locations} {map} />
        {/snippet}
      </Map>
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
