<script lang="ts">
  import PageTemplate from "$lib/components/PageTemplate.svelte";
  import { page } from "$app/stores";
  import { getOrgById } from "$lib/services/orgService.svelte";
  import type { Database } from "$lib/types/database.types";
  const id = $derived($page.params.id);
  let org = $state<Database["public"]["Tables"]["orgs"]["Row"] | null>(null);
  let loading = $state(true);
  const load = async () => {
    console.log("load got id", id);
    const { data, error } = await getOrgById(id);
    if (error) {
      console.log("getOrgById error", id);
      console.error(error);
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
  <!--{#snippet TopLeft()}{/snippet}-->
  {#snippet TopCenter()}
    {#if loading}
      <!-- promise is pending -->
      <p>loading...</p>
    {:else}
      <!-- promise was fulfilled or not a Promise -->
      {org?.title}
    {/if}
  {/snippet}
  <!--{#snippet TopRight()}{/snippet}-->

  {#snippet Middle()}
    Org Details
  {/snippet}

  <!--{#snippet BottomLeft()}{/snippet}-->
  <!--{#snippet BottomCenter()}{/snippet}-->
  <!--{#snippet BottomRight()}{/snippet}-->
</PageTemplate>
