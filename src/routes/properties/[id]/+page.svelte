<script lang="ts">
  import { page } from "$app/stores";
  import PageTemplate from "$lib/components/PageTemplate.svelte";
  import type { Property } from "$lib/services/propertyService.svelte";
  import {
    ArrowLeft,
    Edit,
    Check,
    Printer,
    Save,
    FileText,
  } from "lucide-svelte";
  import PropertyDetails from "@/components/PropertyDetails.svelte";
  import PropertyEdit from "$lib/components/PropertyEdit.svelte";
  import PropertyImages from "$lib/components/PropertyImages.svelte";
  import PropertyHistory from "$lib/components/PropertyHistory.svelte";
  import { Button } from "$lib/components/ui/button";
  import { goto } from "$app/navigation";
  import * as Tabs from "$lib/components/ui/tabs/index.js";
  import FlyerMaker from "$lib/components/FlyerMaker.svelte";
  import {
    upsertProperty,
    getPropertyById,
  } from "$lib/services/propertyService.svelte";
  import { getPDF } from "$lib/services/export.service.svelte";

  const isNew = $derived($page.params.id === "new");
  const propertyId = $derived($page.params.id);
  let isEditing = $state(false);
  let flyerMakerOpen = $state(false);

  $effect(() => {
    // Set initial editing state based on isNew
    isEditing = isNew;
  });

  let property: Partial<Property> = $state({});

  $effect(() => {
    // Initialize property based on isNew condition
    property = isNew
      ? {
          property_type: "",
          property_subtype: "",
          address: "",
          address2: "",
          city: "",
          region: "",
          postal: "",
          country: "",
          beds: 0,
          baths: 0,
          living_area: 0,
          land_area: 0,
          year_built: new Date().getFullYear(),
          metadata: {},
        }
      : {};
  });

  let loading = $state(false);
  let error = $state<string | null>(null);

  const loadProperty = async () => {
    const { data, error: err } = await getPropertyById(propertyId);

    if (err) {
      error = err.message;
      loading = false;
      return;
    }

    property = data;
  };

  async function load() {
    if (isNew) return;

    loading = true;
    error = null;

    await loadProperty();

    loading = false;
  }

  function handleBack(event: MouseEvent) {
    goto("/properties");
  }

  async function handleSave() {
    loading = true;
    error = null;

    // If this was a new property, navigate to the property list
    if (isNew) {
      goto("/properties");
      return;
    }

    // For existing properties, reload the data and exit edit mode
    await loadProperty();
    loading = false;
    isEditing = false;
  }

  $effect(() => {
    load();
  });

  const exportPDF = async () => {
    console.log("exportPDF");
    // Get the property details container element
    const propertyContent =
      document.getElementById("property-details")?.innerHTML;
    console.log("propertyContent", propertyContent);
    if (propertyContent) {
      // Generate a title for the PDF
      const title = `Property_${property.address || "Details"}_${new Date().toISOString().split("T")[0]}`;
      const pdf = await getPDF(propertyContent, title);
      console.log("pdf", pdf);

      // Create a URL for the PDF blob
      const url = URL.createObjectURL(pdf);

      // Create a temporary link element
      const link = document.createElement("a");
      link.href = url;
      link.download = `${title}.pdf`;

      // Append to document, click, and cleanup
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);

      // Revoke the URL to free up memory
      URL.revokeObjectURL(url);
    }
  };

  const actionItems = $derived([
    {
      icon: Edit,
      label: "Edit",
      onClick: () => (isEditing = true),
      show: !isEditing && !isNew,
    },
    {
      icon: Check,
      label: "Save",
      onClick: handleSave,
      show: isEditing || isNew,
    },
    {
      icon: FileText,
      label: "Create Flyer",
      onClick: () => (flyerMakerOpen = true),
      show: !isEditing && !isNew,
    },
  ]);
</script>

<PageTemplate {actionItems}>
  {#snippet TopLeft()}
    <Button variant="ghost" size="icon" onclick={() => goto("/properties")}>
      <ArrowLeft class="h-4 w-4" />
    </Button>
  {/snippet}

  {#snippet TopCenter()}
    Property Details
  {/snippet}

  {#snippet Middle()}
    {#if loading}
      <div class="flex items-center justify-center h-full">
        <div
          class="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900"
        ></div>
      </div>
    {:else if error}
      <div class="text-red-500 p-4">{error}</div>
    {:else if isEditing}
      <PropertyEdit bind:property onSave={handleSave} />
    {:else}
      <div class="w-full flex justify-center">
        <div class="max-w-4xl w-full">
          <Tabs.Root value="details" class="w-full">
            <Tabs.List class="flex justify-center">
              <Tabs.Trigger value="details">Details</Tabs.Trigger>
              <Tabs.Trigger value="images">Images</Tabs.Trigger>
              <Tabs.Trigger value="history">History</Tabs.Trigger>
            </Tabs.List>
            <div id="property-details">
              <Tabs.Content value="details" class="w-full">
                <PropertyDetails {property} />
              </Tabs.Content>
              <Tabs.Content value="images" class="w-full">
                <PropertyImages {property} onReload={loadProperty} />
              </Tabs.Content>
              <Tabs.Content value="history" class="w-full">
                <PropertyHistory {property} />
              </Tabs.Content>
            </div>
          </Tabs.Root>
        </div>
      </div>
    {/if}
  {/snippet}
</PageTemplate>

<FlyerMaker {property} bind:open={flyerMakerOpen} />
