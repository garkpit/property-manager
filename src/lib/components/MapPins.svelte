<!-- MapPins.svelte -->
<script lang="ts">
  import maplibregl from 'maplibre-gl';
  import 'maplibre-gl/dist/maplibre-gl.css';

  interface Props {
    locations: Array<{ lat: number; lng: number; title?: string }>;
    map?: maplibregl.Map;
  }
  const { locations = [], map } = $props<Props>();
  const currentMarkers: maplibregl.Marker[] = [];

  // Create markers for each location
  $effect(() => {
    if (!map || !locations.length) return;

    // Remove existing markers
    while (currentMarkers.length > 0) {
      const marker = currentMarkers.pop();
      marker?.remove();
    }

    // Add new markers
    locations.forEach(location => {
      const marker = new maplibregl.Marker({ className: 'map-marker' })
        .setLngLat([location.lng, location.lat])
        .addTo(map);

      if (location.title) {
        marker.setPopup(
          new maplibregl.Popup({ offset: 25 })
            .setHTML(`<h3>${location.title}</h3>`)
        );
      }

      currentMarkers.push(marker);
    });
  });

  // Cleanup markers when component is destroyed
  $effect.pre(() => {
    return () => {
      while (currentMarkers.length > 0) {
        const marker = currentMarkers.pop();
        marker?.remove();
      }
    };
  });
</script>
