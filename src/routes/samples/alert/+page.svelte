<script lang="ts">
  import PageTemplate from "$lib/components/PageTemplate.svelte";
  import { alertManager } from "$lib/components/ui/alert/alert.svelte.ts";
  import { Button } from "$lib/components/ui/button";

  async function showSimpleAlert() {
    await alertManager.show({
      title: "Success",
      message: "Operation completed successfully",
    });
  }

  async function showConfirmDialog() {
    const result = await alertManager.show({
      title: "Confirm Delete",
      message: "Are you sure you want to delete this item?",
      buttons: [
        { label: "Cancel", value: "cancel", variant: "outline" },
        { label: "Delete", value: "delete", variant: "destructive" },
      ],
    });

    if (result === "delete") {
      // Handle delete action
      console.log("Deleting item...");
    }
  }
  async function showChoicesDialog() {
    const result = await alertManager.show({
      title: "Pick an Option",
      message: "Click on your chocie:",
      buttons: [
        { label: "A", value: "A", variant: "default" },
        { label: "B", value: "B", variant: "secondary" },
        { label: "C", value: "C", variant: "outline" },
        { label: "D", value: "D", variant: "destructive" },
        { label: "E", value: "E", variant: "ghost" },
        { label: "F", value: "F", variant: "link" },
        { label: "Cancel", value: "cancel", variant: "outline" },
      ],
    });

    console.log("result:", result);
  }
</script>

<!-- <PageTemplate {actionItems} /> -->
<PageTemplate>
  <!--{#snippet TopLeft()}{/snippet}-->
  {#snippet TopCenter()}
    Alert Samples
  {/snippet}
  <!--{#snippet TopRight()}{/snippet}-->

  {#snippet Middle()}
    <Button onclick={showSimpleAlert} variant="secondary"
      >Show Simple Alert</Button
    >
    <Button onclick={showConfirmDialog} variant="secondary"
      >Show Confirm Dialog</Button
    >
    <Button onclick={showChoicesDialog} variant="secondary"
      >Show Choices Dialog</Button
    >
  {/snippet}

  <!--{#snippet BottomLeft()}{/snippet}-->
  <!--{#snippet BottomCenter()}{/snippet}-->
  <!--{#snippet BottomRight()}{/snippet}-->
</PageTemplate>
