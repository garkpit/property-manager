<script lang="ts">
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
  import * as Table from "$lib/components/ui/table/index.js";
  import UserRole from "./UserRole.svelte";

  const { org, users } = $props<{
    org: Org;
    users: any[];
  }>();
  //let org = $state<Org | null>(null);
  let id = $derived(org?.id);
  // let users = $state<any[] | null>(null);
  let loading = $state(true);
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

<Card.Root class="w-[350px]">
  <Card.Header>
    <Card.Title>Organization Users</Card.Title>
    <Card.Description>Users of this organization.</Card.Description>
  </Card.Header>
  <Card.Content>
    <Table.Root>
      <Table.Body>
        {#if users}
          {#each users as user, i (i)}
            <Table.Row class="">
              <Table.Cell class="">
                {user.email}<br />
                {#if user.firstname || user.lastname}
                  {user.firstname + " " + user.lastname}<br />
                {/if}
                <UserRole initialValue={user.user_role} />
              </Table.Cell>
            </Table.Row>
          {/each}
        {/if}
      </Table.Body>
      <!--
            <Table.Footer>
              <Table.Row>
                <Table.Cell colspan={3}>Total</Table.Cell>
                <Table.Cell class="text-right">$2,500.00</Table.Cell>
              </Table.Row>
            </Table.Footer>
            -->
    </Table.Root>
  </Card.Content>
  <Card.Footer></Card.Footer>
</Card.Root>
