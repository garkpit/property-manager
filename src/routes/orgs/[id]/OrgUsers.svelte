<script lang="ts">
  import type { Org } from "$lib/services/orgService.svelte";
  import * as Card from "$lib/components/ui/card/index.js";
  import * as Table from "$lib/components/ui/table/index.js";
  import UserRole from "./UserRole.svelte";

  const { users } = $props<{
    org: Org;
    users: any[];
  }>();
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
    </Table.Root>
  </Card.Content>
</Card.Root>
