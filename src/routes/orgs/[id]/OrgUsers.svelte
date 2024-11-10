<script lang="ts">
  import type { Org } from "$lib/services/orgService.svelte";
  import * as Card from "$lib/components/ui/card/index.js";
  import * as Table from "$lib/components/ui/table/index.js";
  import UserRole from "./UserRole.svelte";
  import SaveButton from "@/components/iconbuttons/SaveButton.svelte";
  import CancelButton from "@/components/iconbuttons/CancelButton.svelte";

  let { users } = $props<{
    org: Org;
    users: any[];
  }>();

  async function handleSubmit(user: any) {
    console.log("handleSubmit", user);
  }

  async function handleCancel(user: any) {
    delete user.new_user_role;
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
                {user.email}<br />
                {#if user.firstname || user.lastname}
                  {user.firstname + " " + user.lastname}<br />
                {/if}
                <div class="flex items-center">
                  <UserRole {user} />
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
