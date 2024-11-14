<script lang="ts">
  import { getMessage } from "$lib/services/messageService.svelte";
  import { page } from "$app/stores";
  import PageTemplate from "$lib/components/PageTemplate.svelte";
  import { Button } from "$lib/components/ui/button";
  import { goto } from "$app/navigation";
  import { ArrowLeft } from "lucide-svelte";

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
  {#snippet TopLeft()}
    <Button
      variant="ghost"
      size="icon"
      onclick={() => {
        goto("/messages");
      }}
    >
      <ArrowLeft class="h-4 w-4" />
    </Button>
  {/snippet}

  {#snippet TopCenter()}
    Message Details
  {/snippet}

  <!--{#snippet TopRight()}{/snippet}-->

  {#snippet Middle()}
    {JSON.stringify(message, null, 2)}
  {/snippet}

  <!--{#snippet BottomLeft()}{/snippet}-->
  <!--{#snippet BottomCenter()}{/snippet}-->
  <!--{#snippet BottomRight()}{/snippet}-->
</PageTemplate>
