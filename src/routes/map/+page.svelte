<!-- +page.svelte -->
<script lang="ts">
  import PageTemplate from "$lib/components/PageTemplate.svelte";
  import Map from "$lib/components/Map.svelte";
  import MapPins from "$lib/components/MapPins.svelte";
  import type maplibregl from "maplibre-gl";
  import { OverpassService } from "$lib/services/overpass";

  interface MapLocation {
    lat: number;
    lng: number;
    title?: string;
    details?: {
      [key: string]: string | undefined;
      "addr:housenumber"?: string;
      "addr:street"?: string;
      "addr:postcode"?: string;
      name?: string;
      opening_hours?: string;
      phone?: string;
    };
  }

  let map = $state<maplibregl.Map>();
  let places = $state<Array<any>>([]);
  let locations = $derived(
    places.map(
      (place): MapLocation => ({
        lat: Number(place.lat),
        lng: Number(place.lon),
        title: place.tags?.name ?? undefined,
        details: place.tags as MapLocation["details"],
      }),
    ),
  );

  const load = async () => {
    const overpass = new OverpassService();
    places = await overpass.findNearbyPlaces(
      { lat: 37.7749, lon: -122.4194 }, // San Francisco coordinates
      "coffee shop",
      undefined, // radius parameter (using default)
      3, // limit parameter - show 25 results
    );
  };
  $effect(() => {
    load();
  });
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
