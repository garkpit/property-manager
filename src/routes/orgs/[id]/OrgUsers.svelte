<script lang="ts">
  import DeleteButton from "$lib/components/iconbuttons/DeleteButton.svelte";
  import type { Org } from "$lib/services/orgService.svelte";
  import { deleteOrgUser, getOrgUsers } from "$lib/services/orgService.svelte";
  import * as Card from "$lib/components/ui/card/index.js";
  import * as Table from "$lib/components/ui/table/index.js";
  import UserRole from "./UserRole.svelte";
  import SaveButton from "@/components/iconbuttons/SaveButton.svelte";
  import { alertManager } from "$lib/components/ui/alert/alert.svelte.ts";
  import { toast } from "svelte-sonner";

  let { org, users } = $props<{
    org: Org;
    users: any[];
  }>();

  async function handleSubmit(user: any) {
    console.log("handleSubmit", user);
  }

  async function handleDelete(user: any) {
    if (user === null) return;
    if (user.id === null) return;
    const result = await alertManager.show({
      title: "Confirm Remove User",
      message:
        "Are you sure you want to remove this user from this organization?",
      buttons: [
        { label: "Cancel", value: "cancel", variant: "outline" },
        { label: "Delete", value: "delete", variant: "destructive" },
      ],
    });

    if (result === "delete") {
      // Handle delete action
      const { data, error } = await deleteOrgUser(user.id);
      if (error) {
        toast.error("ERROR", { description: (error as Error).message });
      } else {
        // need to refresh the users list
        if (org) {
          users = await getOrgUsers(org.id);
        }
        setTimeout(() => {
          toast.success("SUCCESS", {
            description: "User removed from organization",
          });
        }, 500);
        // goto("/orgs");
      }
    }
  }
</script>

<Card.Root class="w-[350px]">
  <Card.Header>
    <Card.Title>Users</Card.Title>
    <Card.Description>Users of this organization.</Card.Description>
  </Card.Header>
  <Card.Content>
    <Table.Root>
      <Table.Body>
        {#if users}
          {#each users as user, i (i)}
            <Table.Row class="">
              <Table.Cell class="">
                <div class="ml-4 flex items-center">
                  {user.email}<br />
                  {#if user.firstname || user.lastname}
                    {user.firstname + " " + user.lastname}<br />
                  {/if}
                  <DeleteButton
                    onclick={() => {
                      handleDelete(user);
                    }}
                    classes="ml-6"
                  />
                </div>

                <div class="flex items-center">
                  <UserRole {user} classes="mt-2" />
                  {#if user.user_role !== user.new_user_role}
                    <div class="ml-4 flex items-center">
                      <SaveButton
                        onclick={() => {
                          handleSubmit(user);
                        }}
                      />
                    </div>
                  {/if}
                </div>
              </Table.Cell>
            </Table.Row>
          {/each}
        {/if}
      </Table.Body>
    </Table.Root>
  </Card.Content>
</Card.Root>
