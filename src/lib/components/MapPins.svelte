<!-- MapPins.svelte -->
<script lang="ts">
  import maplibregl from 'maplibre-gl';
  import 'maplibre-gl/dist/maplibre-gl.css';

  interface Props {
    locations: Array<{
      lat: number;
      lng: number;
      title?: string;
      details?: {
        'addr:housenumber'?: string;
        'addr:street'?: string;
        'addr:postcode'?: string;
        name?: string;
        opening_hours?: string;
        phone?: string;
        [key: string]: string | undefined;
      };
    }>;
    map?: maplibregl.Map;
  }
  const { locations = [], map } = $props<Props>();
  const currentMarkers: maplibregl.Marker[] = [];

  function formatDetails(details: Props['locations'][0]['details']) {
    if (!details) return '';
    
    const address = [
      details['addr:housenumber'],
      details['addr:street'],
      details['addr:postcode']
    ].filter(Boolean).join(' ');

    return `
      <div class="popup-content">
        <h3>${details.name || 'Unnamed Location'}</h3>
        ${address ? `<p>${address}</p>` : ''}
        ${details.opening_hours ? `<p>Hours: ${details.opening_hours}</p>` : ''}
        ${details.phone ? `<p>Phone: ${details.phone}</p>` : ''}
      </div>
    `;
  }

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

      if (location.details || location.title) {
        marker.setPopup(
          new maplibregl.Popup({ offset: 25 })
            .setHTML(location.details ? formatDetails(location.details) : `<h3>${location.title}</h3>`)
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

<style>
  :global(.popup-content) {
    padding: 8px;
  }
  :global(.popup-content h3) {
    margin: 0 0 8px 0;
    font-size: 16px;
    font-weight: 600;
  }
  :global(.popup-content p) {
    margin: 4px 0;
    font-size: 14px;
  }
</style>
