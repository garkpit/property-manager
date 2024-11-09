<script lang="ts">
  import PageTemplate from "$lib/components/PageTemplate.svelte";
  import { page } from "$app/stores";
  import {
    getOrgById,
    saveOrg,
    deleteOrg,
    getOrgUsers,
  } from "$lib/services/orgService.svelte";
  import type { Org } from "$lib/services/orgService.svelte";
  import { goto } from "$app/navigation";
  import { ArrowLeft } from "lucide-svelte";
  import { Button } from "$lib/components/ui/button";
  import * as Card from "$lib/components/ui/card/index.js";
  import { Label } from "$lib/components/ui/label";
  import { Input } from "$lib/components/ui/input";
  import SaveButton from "@/components/iconbuttons/SaveButton.svelte";
  import DeleteButton from "@/components/iconbuttons/DeleteButton.svelte";
  import { toast } from "svelte-sonner";
  import { alertManager } from "$lib/components/ui/alert/alert.svelte.ts";

  const id = $derived($page.params.id);
  let org = $state<Org | null>(null);
  let users = $state<any[] | null>(null);
  let loading = $state(true);
  let titleError = $state("");
  let isFormChanged = $state(false);

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
            id: u.userid,
            created_at: new Date(u.created_at).toLocaleDateString(),
            user_role: u.user_role,
            email: u.email,
            firstname: u.raw_user_meta_data.firstname,
            lastname: u.raw_user_meta_data.lastname,
            email_verified: u.raw_user_meta_data.email_verified,
          });
        }
        users = tempUsers;
        console.log("got users", users);
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

  function validateTitle(title: string) {
    if (!title.trim()) {
      titleError = "Title is required";
      return false;
    }
    titleError = "";
    return true;
  }
  function handleInput() {
    isFormChanged = true;
  }
  async function handleSubmit() {
    if (!org) return;

    if (!validateTitle(org.title)) {
      return;
    }

    const { data, error } = await saveOrg(org);
    if (error) {
      toast.error("ERROR", { description: (error as Error).message });
    } else {
      setTimeout(() => {
        toast.success("SUCCESS", { description: "Organization updated" });
      }, 500);
      goto("/orgs");
    }
  }
  async function handleDelete() {
    if (org === null) return;
    const result = await alertManager.show({
      title: "Confirm Delete",
      message: "Are you sure you want to delete this organization?",
      buttons: [
        { label: "Cancel", value: "cancel", variant: "outline" },
        { label: "Delete", value: "delete", variant: "destructive" },
      ],
    });

    if (result === "delete") {
      // Handle delete action
      const { data, error } = await deleteOrg(org);
      if (error) {
        toast.error("ERROR", { description: (error as Error).message });
      } else {
        setTimeout(() => {
          toast.success("SUCCESS", { description: "Organization deleted" });
        }, 500);
        goto("/orgs");
      }
    }
  }
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
    {#if isFormChanged}
      <SaveButton onclick={handleSubmit} />
    {/if}
  {/snippet}

  {#snippet Middle()}
    <div class="flex items-center justify-center">
      <Card.Root class="w-[350px]">
        <Card.Header>
          <Card.Title>Organization Details</Card.Title>
          <Card.Description>This is your organization.</Card.Description>
        </Card.Header>
        <Card.Content>
          <form
            oninput={handleInput}
            onsubmit={(e) => {
              e.preventDefault();
              handleSubmit();
            }}
          >
            <div class="grid w-full items-center gap-4">
              <div class="flex flex-col space-y-1.5">
                <Label for="name">Title</Label>
                <Input
                  id="name"
                  value={org?.title ?? ""}
                  placeholder="Title of your organization"
                  class={titleError ? "border-destructive" : ""}
                  oninput={(e) => {
                    if (org) org.title = e.currentTarget.value;
                    validateTitle(e.currentTarget.value);
                  }}
                />
                {#if titleError}
                  <p class="text-sm text-destructive">{titleError}</p>
                {/if}
              </div>
              {#if id !== "new"}
                <div class="flex flex-col space-y-1.5">
                  <Label for="name">Created</Label>
                  <Input
                    id="name"
                    disabled
                    value={org?.created_at?.substring(0, 10) ?? ""}
                  />
                </div>
              {/if}
            </div>
          </form>
        </Card.Content>
        <Card.Footer class="flex justify-between">
          {#if id !== "new"}
            <DeleteButton onclick={handleDelete} />
          {/if}
        </Card.Footer>
      </Card.Root>
    </div>
  {/snippet}

  <!--{#snippet BottomLeft()}{/snippet}-->
  <!--{#snippet BottomCenter()}{/snippet}-->
  <!--{#snippet BottomRight()}{/snippet}-->
</PageTemplate>
