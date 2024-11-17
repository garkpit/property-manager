<!-- +page.svelte -->
<script lang="ts">
  import PageTemplate from "$lib/components/PageTemplate.svelte";
  import Map from "$lib/components/Map.svelte";
  import MapPins from "$lib/components/MapPins.svelte";
  import type maplibregl from "maplibre-gl";
  import { OverpassService } from "$lib/services/overpass";
  import {
    Coffee,
    ChefHat,
    Beer,
    Martini,
    Landmark,
    CircleDollarSign,
    PillBottle,
    Hospital,
    School,
    CircleParking,
  } from "lucide-svelte";
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

  const locatePlaces = async (placeType: string) => {
    if (!map) return;
    const center = map.getCenter();
    const overpass = new OverpassService();
    places = await overpass.findNearbyPlaces(
      { lat: center.lat, lon: center.lng },
      placeType,
      2000, // radius parameter (using default)
      10, // limit parameter - show 25 results
    );
    console.log("places", places);
  };

  /**
            "bar": "bar",
            "pub": "pub",
            "atm": "atm",
            "bank": "bank",
            "pharmacy": "pharmacy",
            "hospital": "hospital",
            "school": "school",
            "parking": "parking",

   */
  const actionItems: any[] = [
    {
      groupName: "Locate:",
      groupItems: [
        {
          icon: Coffee,
          label: "cafe",
          onClick: () => {
            locatePlaces("cafe");
          },
        },
        {
          icon: ChefHat,
          label: "restaurant",
          onClick: () => {
            locatePlaces("restaurant");
          },
        },
        {
          icon: Martini,
          label: "pub",
          onClick: () => {
            locatePlaces("pub");
          },
        },
        {
          icon: Beer,
          label: "bar",
          onClick: () => {
            locatePlaces("bar");
          },
        },
        {
          icon: CircleDollarSign,
          label: "atm",
          onClick: () => {
            locatePlaces("atm");
          },
        },
        {
          icon: Landmark,
          label: "bank",
          onClick: () => {
            locatePlaces("bank");
          },
        },
        {
          icon: PillBottle,
          label: "pharmacy",
          onClick: () => {
            locatePlaces("pharmacy");
          },
        },
        {
          icon: Hospital,
          label: "hospital",
          onClick: () => {
            locatePlaces("hospital");
          },
        },
        {
          icon: School,
          label: "school",
          onClick: () => {
            locatePlaces("school");
          },
        },
        {
          icon: CircleParking,
          label: "parking",
          onClick: () => {
            locatePlaces("parking");
          },
        },
      ],
    },
  ];
</script>

<PageTemplate {actionItems}>
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
