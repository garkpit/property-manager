<script lang="ts">
  import PageTemplate from "$lib/components/PageTemplate.svelte";

  import {
    updateUser,
    getCurrentOrgId,
    setCurrentOrgId,
    getUser,
  } from "$lib/services/backend.svelte";
  import { t } from "$lib/i18n/index";
  import { toast } from "svelte-sonner";
  import GenericList from "$lib/components/GenericList.svelte";
  import { Plus } from "lucide-svelte";
  import type { Org } from "$lib/types/org";
  import { fetchOrgs } from "$lib/services/orgService.svelte";

  import type { PageData } from "./$types";
  import { goto } from "$app/navigation";
  import { Button } from "@/components/ui/button";
  const user = $derived(getUser());

  let orgs = $state([] as Org[]);
  const currentOrgId = $derived(getCurrentOrgId());
  const currentOrg = $derived(orgs.find((org: Org) => org.id === currentOrgId));

  const load = async () => {
    // const { data, error } = await getAllOrgs();
    const { data, error } = await fetchOrgs("title", "asc");
    if (error) {
    } else {
      orgs = data as any[];
    }
  };
  async function handleOrgClick(org: Org) {
    try {
      await setCurrentOrg(org);
      await goto(`/dashboard/orgs/${org.id}`);
    } catch (error) {
      console.error("Error handling org click:", error);
      toast.error("ERROR", {
        description: $t("org.navigationError"),
      });
    }
  }
  $effect(() => {
    load();
  });

  async function setCurrentOrg(org: Org) {
    try {
      const { data, error } = await updateUser({
        data: { currentOrgId: org.id },
      });

      if (error) throw error;

      setCurrentOrgId(org.id);

      toast.success("SUCCESS", {
        description: $t("org.currentOrgUpdated"),
      });
    } catch (error) {
      console.error("Error setting current org:", error);
      toast.error("ERROR", {
        description: $t("org.currentOrgUpdateError"),
      });

      throw error;
    }
  }

  async function handleNewOrgClick() {
    await goto("/dashboard/orgs/new");
  }

  const headers = [{ key: "title", label: "orgs.title", sortable: true }];
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
    {$t("org.listTitle")}
  {/snippet}
  {#snippet TopRight()}
    <Button
      variant="ghost"
      size="icon"
      onclick={handleNewOrgClick}
      class="h-9 w-9"
      aria-label={$t("org.addNew")}
    >
      <Plus class="w-6 h-6" />
    </Button>
  {/snippet}

  {#snippet Middle()}
    <div class="container mx-auto p-4">
      {#if user}
        <div class="space-y-6">
          <!-- Current Org display -->
          <div class="bg-secondary p-4 rounded-lg mb-4">
            <h2 class="text-lg font-semibold mb-2">{$t("org.currentOrg")}</h2>
            {#if currentOrg}
              <p>{currentOrg.title}</p>
            {:else}
              <p class="text-gray-500">{$t("org.noCurrentOrg")}</p>
            {/if}
          </div>

          <GenericList data={orgs} {headers} onRowClick={handleOrgClick} />
        </div>
      {:else}
        <p class="pt-8 text-center text-lg text-gray-500">
          {$t("common.notLoggedIn")}
        </p>
      {/if}
    </div>
  {/snippet}

  <!--{#snippet BottomLeft()}{/snippet}-->
  <!--{#snippet BottomCenter()}{/snippet}-->
  <!--{#snippet BottomRight()}{/snippet}-->
</PageTemplate>
