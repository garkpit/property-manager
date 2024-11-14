<script lang="ts">
  import { getMessage } from "$lib/services/messageService.svelte";
  import { page } from "$app/stores";
  import PageTemplate from "$lib/components/PageTemplate.svelte";

  const id = $derived($page.params.id);
  let message = $state<any | null>(null);

  const load = async () => {
    const { data, error } = await getMessage(id);
    if (error) {
      console.error("getMessage error", error);
    }
    message = data;
  };
  $effect(() => {
    load();
  });
</script>

<!-- <PageTemplate {actionItems} /> -->
<PageTemplate>
  <!--{#snippet TopLeft()}{/snippet}-->
  {#snippet TopCenter()}
    Message Details
  {/snippet}
  <!--{#snippet TopRight()}{/snippet}-->

  {#snippet Middle()}
    <pre>{JSON.stringify(message, null, 2)}</pre>
  {/snippet}

  <!--{#snippet BottomLeft()}{/snippet}-->
  <!--{#snippet BottomCenter()}{/snippet}-->
  <!--{#snippet BottomRight()}{/snippet}-->
</PageTemplate>
