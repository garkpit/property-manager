<script lang="ts">
  import PageTemplate from "$lib/components/PageTemplate.svelte";
  import { page } from "$app/stores";
  import { getOrgById } from "$lib/services/orgService.svelte";
  import type { Org } from "$lib/services/orgService.svelte";
  import { goto } from "$app/navigation";
  import { ArrowLeft } from "lucide-svelte";
  import { Button } from "$lib/components/ui/button";
  import * as Card from "$lib/components/ui/card/index.js";
  import { Label } from "$lib/components/ui/label";
  import { Input } from "$lib/components/ui/input";
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
    <div class="flex items-center justify-center">
      <Card.Root class="w-[350px]">
        <Card.Header>
          <Card.Title>Organization Details</Card.Title>
          <Card.Description>This is your organization.</Card.Description>
        </Card.Header>
        <Card.Content>
          <form>
            <div class="grid w-full items-center gap-4">
              <div class="flex flex-col space-y-1.5">
                <Label for="name">Title</Label>
                <Input
                  id="name"
                  value={org?.title ?? ""}
                  placeholder="Title of your organization"
                />
              </div>
              <div class="flex flex-col space-y-1.5">
                <Label for="name">Created</Label>
                <Input
                  id="name"
                  disabled
                  value={org?.created_at?.substring(0, 10) ?? ""}
                />
              </div>
            </div>
          </form>
        </Card.Content>
        <Card.Footer class="flex justify-between">
          <Button variant="outline">Cancel</Button>
          <Button>Update</Button>
        </Card.Footer>
      </Card.Root>
    </div>
  {/snippet}

  <!--{#snippet BottomLeft()}{/snippet}-->
  <!--{#snippet BottomCenter()}{/snippet}-->
  <!--{#snippet BottomRight()}{/snippet}-->
</PageTemplate>
