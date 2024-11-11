<script lang="ts">
  import { saveOrg, deleteOrg } from "$lib/services/orgService.svelte";
  import type { Org } from "$lib/services/orgService.svelte";
  import { goto } from "$app/navigation";
  import * as Card from "$lib/components/ui/card/index.js";
  import { Label } from "$lib/components/ui/label";
  import { Input } from "$lib/components/ui/input";
  import SaveButton from "@/components/iconbuttons/SaveButton.svelte";
  import DeleteButton from "@/components/iconbuttons/DeleteButton.svelte";
  import { toast } from "svelte-sonner";
  import { alertManager } from "$lib/components/ui/alert/alert.svelte.ts";
  import CancelButton from "@/components/iconbuttons/CancelButton.svelte";
  import { loadingState } from "$lib/components/loading/loading-state.svelte.ts";

  const { org } = $props<{
    org: Org;
  }>();
  //let org = $state<Org | null>(null);
  let id = $derived(org?.id);
  let titleError = $state("");
  let isFormChanged = $state(false);

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

    loadingState.show("Saving organization...");
    const { data, error } = await saveOrg(org);
    loadingState.hide();
    if (error) {
      toast.error("ERROR", { description: (error as Error).message });
    } else {
      setTimeout(() => {
        toast.success("SUCCESS", { description: "Organization updated" });
      }, 500);
      goto("/orgs");
    }
  }
  async function handleCancel() {
    goto("/orgs");
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
      loadingState.show("Deleting organization...");
      const { data, error } = await deleteOrg(org);
      console.log("orgDelete data", data);
      console.log("orgDelete error", error);
      loadingState.hide();
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

<Card.Root class="w-[350px] md:w-[500px]">
  <Card.Header>
    <Card.Title>Details</Card.Title>
    <Card.Description>Details of the organization.</Card.Description>
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
    {#if isFormChanged}
      <div>
        <CancelButton onclick={handleCancel} classes="mr-2" />
        <SaveButton onclick={handleSubmit} />
      </div>
    {/if}
  </Card.Footer>
</Card.Root>
