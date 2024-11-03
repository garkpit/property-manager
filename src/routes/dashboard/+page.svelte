<script lang="ts">
  import * as Sidebar from "$lib/components/ui/sidebar";
  import LeftDrawer from "$lib/components/LeftDrawer.svelte";
  import StatusBar from "$lib/components/StatusBar.svelte";
  import Navbar from "$lib/components/Navbar.svelte";
  import Content from "$lib/components/Content.svelte";
  import { MoreVertical, Settings, CircleHelp, LogOut } from "lucide-svelte";
  import Actions from "$lib/components/actions.svelte";
  const actionItems: any[] = [
    {
      groupName: "Settings",
      groupItems: [
        {
          icon: Settings,
          label: "Settings",
          onClick: () => console.log("Settings clicked"),
        },
        {
          icon: CircleHelp,
          label: "Help",
          onClick: () => console.log("Help clicked"),
        },
      ],
    },
    {
      groupName: "Information",
      groupItems: [
        {
          icon: Settings,
          label: "Info 1",
          onClick: () => console.log("Info 1 clicked"),
        },
        {
          icon: CircleHelp,
          label: "Info 2 - this is a longer label",
          onClick: () => console.log("Info 2 clicked"),
        },
      ],
    },
    {
      icon: LogOut,
      label: "Logout",
      onClick: () => console.log("Logout clicked"),
      separator: true,
    },
  ];
</script>

<Sidebar.Provider>
  <div class="flex min-h-screen">
    <LeftDrawer />

    <main class="flex-1 relative flex flex-col">
      <div class="flex flex-col h-screen">
        <Navbar>
          {#snippet Left()}
            <Sidebar.Trigger />
          {/snippet}
          {#snippet Center()}
            Dashboard
          {/snippet}
          {#snippet Right()}
            <Actions items={actionItems} triggerIcon={MoreVertical} />
          {/snippet}
        </Navbar>

        <Content>
          {#snippet Middle()}
            <div class="flex items-center justify-between">
              <h1 class="text-3xl font-bold">Welcome to the Dashboard</h1>
            </div>
          {/snippet}
        </Content>

        <StatusBar />
      </div>
    </main>
  </div>
</Sidebar.Provider>
