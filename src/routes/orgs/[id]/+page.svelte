<script lang="ts">
  import PageTemplate from "$lib/components/PageTemplate.svelte";
  import { page } from "$app/stores";
  import { getOrgById } from "$lib/services/orgService.svelte";
  import type { Org } from "$lib/services/orgService.svelte";
  import { goto } from "$app/navigation";
  import { ArrowLeft } from "lucide-svelte";
  import { Button } from "$lib/components/ui/button";
  const id = $derived($page.params.id);
  let org = $state<Org | null>(null);
  let loading = $state(true);
  const load = async () => {
    const { data, error } = await getOrgById(id);
    if (error) {
      console.error("getOrgById error", error);
      loading = false;
    } else {
      if (data) {
        org = data;
      } else {
        org = null;
      }
      loading = false;
    }
  };
  $effect(() => {
    load();
  });
  /*
	const actionItems: any[] = [
	  {
		groupName: "Group Header Here",
		groupItems: [
		  {
			icon: IconFromLucide,
			label: "Item Label Here",
			onClick: () => {console.log("item was clicked")},
		  },
		],
	  }
	];
	*/
</script>

<!-- <PageTemplate {actionItems} /> -->
<PageTemplate>
  {#snippet TopLeft()}
    <Button
      variant="ghost"
      size="icon"
      onclick={() => {
        goto("/orgs");
      }}
      class="h-9 w-9"
    >
      <ArrowLeft class="w-6 h-6" />
    </Button>
  {/snippet}
  {#snippet TopCenter()}
    {#if loading}
      Loading...
    {:else}
      {org?.title}
    {/if}
  {/snippet}
  <!--{#snippet TopRight()}{/snippet}-->

  {#snippet Middle()}
    Org Details:
    {org?.title}
  {/snippet}

  <!--{#snippet BottomLeft()}{/snippet}-->
  <!--{#snippet BottomCenter()}{/snippet}-->
  <!--{#snippet BottomRight()}{/snippet}-->
</PageTemplate>
