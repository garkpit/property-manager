<script lang="ts">
  import PageTemplate from "$lib/components/PageTemplate.svelte";
  import { page } from "$app/stores";
  import { getOrgById, getOrgUsers } from "$lib/services/orgService.svelte";
  import type { Org } from "$lib/services/orgService.svelte";
  import { goto } from "$app/navigation";
  import { ArrowLeft } from "lucide-svelte";
  import { Button } from "$lib/components/ui/button";
  import { toast } from "svelte-sonner";
  import OrgDetails from "./OrgDetails.svelte";
  import OrgUsers from "./OrgUsers.svelte";
  import OrgsInvites from "./OrgsInvites.svelte";
  import * as Tabs from "$lib/components/ui/tabs/index.js";

  const id = $derived($page.params.id);
  let org = $state<Org | null>(null);
  let users = $state<any[] | null>(null);
  let loading = $state(true);

  const load = async () => {
    if (id === "new") {
      org = {
        title: "",
        created_at: "",
        id: "",
        metadata: null,
      };
      loading = false;
      return;
    }

    const { data, error } = await getOrgById(id);
    if (error) {
      console.error("getOrgById error", error);
      toast.error("ERROR", { description: (error as Error).message });
      loading = false;
    } else {
      if (data) {
        org = data;
      } else {
        org = null;
      }
      loading = false;
    }
    if (org) {
      const { data: usersData, error: usersError } = await getOrgUsers(org);
      if (usersError) {
        console.error("getOrgUsers error", usersError);
      } else {
        console.log("got users data", usersData.data);
        console.log("usersData.data.length", usersData.data.length);
        const tempUsers = [];
        for (let i = 0; i < usersData.data.length; i++) {
          const u = usersData.data[i];
          console.log("u", u);
          tempUsers.push({
            id: u.id,
            created_at: new Date(u.created_at).toLocaleDateString(),
            user_role: u.user_role,
            email: u.email,
            firstname: u.raw_user_meta_data.firstname || null,
            lastname: u.raw_user_meta_data.lastname || null,
            email_verified: u.raw_user_meta_data.email_verified,
          });
        }
        users = tempUsers;
        console.log("*** got users", users);
        console.table(tempUsers);
      }
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
      {id === "new" ? "New Organization" : org?.title}
    {/if}
  {/snippet}
  {#snippet TopRight()}
    <!--
    {#if isFormChanged}
      <SaveButton onclick={handleSubmit} />
    {/if}
   -->
  {/snippet}

  {#snippet Middle()}
    <div class="flex items-center justify-center">
      <Tabs.Root value="details" class="w-[350px] md:w-[500px]">
        <Tabs.List>
          <Tabs.Trigger value="details">Details</Tabs.Trigger>
          <Tabs.Trigger value="users">Users</Tabs.Trigger>
          <Tabs.Trigger value="invites">Invites</Tabs.Trigger>
        </Tabs.List>
        <Tabs.Content value="details">
          <div class="flex items-center justify-center">
            {#if org}
              <OrgDetails {org} />
            {/if}
          </div>
        </Tabs.Content>
        <Tabs.Content value="users">
          <div class="flex items-center justify-center">
            {#if org && users}
              <OrgUsers {org} {users} />
            {/if}
          </div>
        </Tabs.Content>
        <Tabs.Content value="invites">
          <div class="flex items-center justify-center">
            {#if org}
              <OrgsInvites {org} />
            {/if}
          </div>
        </Tabs.Content>
      </Tabs.Root>
    </div>
  {/snippet}

  <!--{#snippet BottomLeft()}{/snippet}-->
  <!--{#snippet BottomCenter()}{/snippet}-->
  <!--{#snippet BottomRight()}{/snippet}-->
</PageTemplate>
