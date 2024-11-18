<!-- MapPins.svelte -->
<script lang="ts">
  import maplibregl from 'maplibre-gl';
  import 'maplibre-gl/dist/maplibre-gl.css';

  interface Props {
    locations: Array<{
      lat: number;
      lng: number;
      title?: string;
      property?: any;  // This will be the full property object
    }>;
    map?: maplibregl.Map;
  }
  const { locations = [], map } = $props<Props>();
  const currentMarkers: maplibregl.Marker[] = [];

  function createPopupHTML(location: Props['locations'][0]) {
    if (!location.property) {
      return `<h3>${location.title || 'Unnamed Location'}</h3>`;
    }
    
    const { address, city, status, list_price, beds, baths } = location.property;
    return `
      <div class="popup-content">
        <h3>${address || 'No Address'}</h3>
        <p class="city">${city || ''}</p>
        <p class="status">${status || ''}</p>
        <p class="price">$${(list_price || 0).toLocaleString()}</p>
        <div class="specs">
          <span>${beds || 0} beds</span>
          <span>${baths || 0} baths</span>
        </div>
      </div>
    `;
  }

  // Create markers for each location
  $effect(() => {
    if (!map) return;

    // Remove existing markers
    while (currentMarkers.length > 0) {
      const marker = currentMarkers.pop();
      marker?.remove();
    }

    // Add new markers only if we have locations
    if (locations.length > 0) {
      locations.forEach(location => {
        const marker = new maplibregl.Marker({ className: 'map-marker' })
          .setLngLat([location.lng, location.lat])
          .addTo(map);

        const popup = new maplibregl.Popup({ 
          offset: 25,
          closeButton: false,
          className: 'property-popup'
        })
          .setHTML(createPopupHTML(location));

        marker.setPopup(popup);
        currentMarkers.push(marker);
      });
    }
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
  :global(.property-popup .maplibregl-popup-content) {
    background-color: white;
    color: black;
    border: 1px solid var(--border);
  }

  :global(.dark .property-popup .maplibregl-popup-content) {
    background-color: black;
    color: white;
    border-color: #333;
  }

  :global(.property-popup .maplibregl-popup-tip) {
    border-top-color: white !important;
    border-bottom-color: white !important;
  }

  :global(.dark .property-popup .maplibregl-popup-tip) {
    border-top-color: black !important;
    border-bottom-color: black !important;
  }

  :global(.popup-content) {
    padding: 12px;
    min-width: 200px;
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

  :global(.popup-content .city) {
    color: #666;
  }

  :global(.dark .popup-content .city) {
    color: #a1a1aa;
  }

  :global(.popup-content .status) {
    text-transform: capitalize;
    color: #2563eb;
    font-weight: 500;
  }

  :global(.dark .popup-content .status) {
    color: #60a5fa;
  }

  :global(.popup-content .price) {
    font-weight: 600;
    font-size: 16px;
    margin: 8px 0;
  }

  :global(.popup-content .specs) {
    display: flex;
    gap: 12px;
    color: #666;
  }

  :global(.dark .popup-content .specs) {
    color: #a1a1aa;
  }
</style>
