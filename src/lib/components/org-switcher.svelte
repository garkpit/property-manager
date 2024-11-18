<script lang="ts">
  import * as DropdownMenu from "$lib/components/ui/dropdown-menu/index.js";
  import * as Sidebar from "$lib/components/ui/sidebar/index.js";
  import { useSidebar } from "$lib/components/ui/sidebar/index.js";
  import { ChevronsUpDown, Plus } from "lucide-svelte";
  import {
    getCurrentOrg,
    updateCurrentOrg,
  } from "$lib/services/backend.svelte";
  import { fetchOrgs } from "$lib/services/orgService.svelte";
  import { Star } from "lucide-svelte";
  import { goto } from "$app/navigation";
  interface Org {
    id: string;
    title: string;
    created_at: string;
    metadata: any;
    user_role: string;
  }
  const org: Org | null = $derived(getCurrentOrg());

  let orgs = $state([] as Org[]);

  // This should be `Component` after lucide-svelte updates types
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  //  let { teams }: { teams: { name: string; logo: any; plan: string }[] } =
  //   $props();
  const sidebar = useSidebar();
  const load = async () => {
    // const { data, error } = await getAllOrgs();
    const { data, error } = await fetchOrgs();
    if (error) {
    } else {
      orgs = data;
    }
  };
  $effect(() => {
    load();
  });
  async function handleOrgChange(id: string) {
    return await updateCurrentOrg(id);
  }
  const handleSelectOrg = async (id: string) => {
    const success = await handleOrgChange(id);
    if (!success) {
      console.error("Error switching organization");
    }
  };
</script>

<Sidebar.Menu>
  <Sidebar.MenuItem>
    <DropdownMenu.Root>
      <DropdownMenu.Trigger>
        {#snippet child({ props })}
          <Sidebar.MenuButton
            {...props}
            size="lg"
            class="data-[state=open]:bg-sidebar-accent data-[state=open]:text-sidebar-accent-foreground"
          >
            <div
              class="flex aspect-square size-8 items-center justify-center rounded-lg"
            >
              <Star class="size-4" />
            </div>
            <div class="grid flex-1 text-left text-sm leading-tight">
              <span class="truncate font-semibold">
                {org?.title || "No Org Selected"}
              </span>
              <span class="truncate text-xs">{org?.user_role}</span>
            </div>
            <ChevronsUpDown class="ml-auto" />
          </Sidebar.MenuButton>
        {/snippet}
      </DropdownMenu.Trigger>
      <DropdownMenu.Content
        class="w-[--bits-dropdown-menu-anchor-width] min-w-56 rounded-lg"
        align="start"
        side={sidebar.isMobile ? "bottom" : "right"}
        sideOffset={4}
      >
        <DropdownMenu.Label class="text-muted-foreground text-xs"
          >Orgs</DropdownMenu.Label
        >
        {#each orgs as o, index}
          <DropdownMenu.Item
            onSelect={() => {
              handleSelectOrg(o.id);
            }}
            class="gap-2 p-2"
          >
            <div class="flex size-6 items-center justify-center rounded-sm">
              <Star class="size-4 shrink-0" />
            </div>
            {o.title} [{o.user_role}]
            <!--<DropdownMenu.Shortcut>⌘{index + 1}</DropdownMenu.Shortcut>-->
          </DropdownMenu.Item>
        {/each}
        <DropdownMenu.Separator />
        <DropdownMenu.Item
          class="gap-2 p-2"
          onclick={() => {
            goto("/orgs/new");
          }}
        >
          <div
            class="bg-background flex size-6 items-center justify-center rounded-md border"
          >
            <Plus class="size-4" />
          </div>
          <div class="text-muted-foreground font-medium">Add New Org</div>
        </DropdownMenu.Item>
      </DropdownMenu.Content>
    </DropdownMenu.Root>
  </Sidebar.MenuItem>
</Sidebar.Menu>
