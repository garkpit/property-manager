<script lang="ts">
  import DeleteButton from "$lib/components/iconbuttons/DeleteButton.svelte";
  import type { Org } from "$lib/services/orgService.svelte";
  import {
    deleteOrgUser,
    getOrgUsers,
    updateUserRole,
  } from "$lib/services/orgService.svelte";
  import * as Card from "$lib/components/ui/card/index.js";
  import * as Table from "$lib/components/ui/table/index.js";
  import AddButton from "$lib/components/iconbuttons/AddButton.svelte";
  import RoleSelector from "./RoleSelector.svelte";
  import SaveButton from "@/components/iconbuttons/SaveButton.svelte";
  import { alertManager } from "$lib/components/ui/alert/alert.svelte.ts";
  import { toast } from "svelte-sonner";
  import { getUser } from "$lib/services/backend.svelte";
  import { getInvites } from "$lib/services/inviteService.svelte";
  import type { Invite } from "$lib/services/inviteService.svelte";
  import { cn } from "$lib/utils";
  const user = $derived(getUser());

  let { org } = $props<{
    org: Org;
  }>();

  let invites = $state<Invite[]>([]);
  const load = async () => {
    const { data, error } = await getInvites(org.id);
    invites = data || [];
    console.table(invites);
  };
  $effect(() => {
    load();
  });

  let newInviteEmail = $state("");
  let isEmailValid = $derived(validateEmail(newInviteEmail));
  let showValidation = $state(false);

  let selectedRole = $state("Member"); // Default to 'Member'

  function validateEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    const isValid = emailRegex.test(email);
    console.log("Email validation:", { email, isValid });
    return isValid;
  }

  async function handleAdd() {
    showValidation = true;
    console.log("Handle Add:", {
      newInviteEmail,
      isEmailValid,
      showValidation,
      selectedRole,
    });
    if (!isEmailValid) {
      toast.error("Invalid email", {
        description: "Please enter a valid email address",
      });
      return;
    }
    console.log("Processing invite:", {
      email: newInviteEmail,
      role: selectedRole,
    });
  }

  /*
  async function handleUpdateRole(user: any) {
    if (user === null) return;
    if (!user.new_user_role) return;
    const result = await alertManager.show({
      title: "Confirm Role Change",
      message: `Are you sure you want to change the role for ${user.email} from ${user.user_role} to ${user.new_user_role}?`,
      buttons: [
        { label: "Cancel", value: "cancel", variant: "outline" },
        { label: "Update", value: "update", variant: "destructive" },
      ],
    });

    if (result === "update") {
      // Handle update action
      const { data, error } = await updateUserRole(user.id, user.new_user_role);
      if (error) {
        toast.error("ERROR", { description: (error as Error).message });
      } else {
        // refresh the page here
        toast.success("SUCCESS", {
          description: "User role updated",
        });
        setTimeout(() => {
          window.location.reload();
        }, 1000);
        // goto("/orgs");
      }
    }
  }

  async function handleDelete(user: any) {
    if (user === null) return;
    if (user.id === null) return;
    const result = await alertManager.show({
      title: "Confirm Remove User",
      message: `Are you sure you want to remove ${user.email} from this organization?`,
      buttons: [
        { label: "Cancel", value: "cancel", variant: "outline" },
        { label: "Delete", value: "delete", variant: "destructive" },
      ],
    });

    if (result === "delete") {
      // Handle delete action
      console.log("deleteOrgUser", user.id);
      const {
        data: { data, error },
      } = await deleteOrgUser(user.id);
      if (error) {
        toast.error("ERROR", {
          description: (error as Error).message,
        });
      } else {
        // refresh the page here
        toast.success("SUCCESS", {
          description: "User removed from organization",
        });
        setTimeout(() => {
          window.location.reload();
        }, 1000);
        // goto("/orgs");
      }
    }
  }
    */
</script>

<Card.Root class="w-[350px] md:w-[500px]">
  <Card.Header>
    <Card.Title>Invites</Card.Title>
    <Card.Description>Invitations to join this organization.</Card.Description>
  </Card.Header>
  <Card.Content class="pl-4 pr-4 pt-0">
    <Table.Root>
      <Table.Body>
        {#if invites}
          {#each invites as inv, i (i)}
            <Table.Row>
              <Table.Cell
                class="w-[44px] max-w-[44px] m-0 p-0 hidden md:table-cell"
              >
                <DeleteButton
                  onclick={() => {
                    // handleDelete(inv);
                  }}
                  classes="m-0 p-0"
                />
              </Table.Cell>
              <Table.Cell class="pl-2 w-[280px] max-w-[280px]">
                {inv.email}<br />
              </Table.Cell>
              <Table.Cell
                class="pl-2 pr-0 mr-0 w-[180px] min-w-[180px] max-w-[180px] hidden md:table-cell"
              >
                <div class="flex">
                  <!-- <UserRole user={u} classes="w-[110px] max-w-[110px]" /> -->
                  <!--
                  {#if inv.new_user_role && u.user_role !== u.new_user_role}
                    <SaveButton
                      onclick={() => {
                        handleUpdateRole(u);
                      }}
                      classes="ml-4"
                    />
                  {/if}
                  -->
                </div>
              </Table.Cell>
            </Table.Row>
          {/each}

          <Table.Row>
            <Table.Cell
              class="w-[44px] max-w-[44px] m-0 p-0 hidden md:table-cell"
            >
              <AddButton
                onclick={() => {
                  console.log("Add button clicked");
                  handleAdd();
                }}
                classes="m-0 p-0"
              />
            </Table.Cell>
            <Table.Cell class="pl-2 w-[280px] max-w-[280px]">
              <div class="flex flex-col space-y-1">
                <input
                  type="email"
                  placeholder="Enter email address"
                  bind:value={newInviteEmail}
                  class={cn(
                    "w-full px-2 py-1 text-sm border rounded focus:outline-none focus:ring-2 focus:ring-primary",
                    showValidation && !isEmailValid && "border-destructive",
                    showValidation && isEmailValid && "border-green-500",
                  )}
                />
                {#if showValidation && !isEmailValid}
                  <span
                    class="text-xs text-destructive bg-destructive/10 p-1 rounded"
                  >
                    Please enter a valid email address
                  </span>
                {/if}
              </div>
            </Table.Cell>
            <Table.Cell
              class="pl-2 pr-0 mr-0 w-[180px] min-w-[180px] max-w-[180px] hidden md:table-cell"
            >
              <div class="flex">
                <RoleSelector
                  user={{
                    user_role: selectedRole,
                    new_user_role: selectedRole,
                  }}
                  classes="w-[110px] max-w-[110px]"
                  bind:value={selectedRole}
                />
              </div>
            </Table.Cell>
          </Table.Row>
        {/if}
      </Table.Body>
    </Table.Root>
  </Card.Content>
</Card.Root>
