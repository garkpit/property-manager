<script lang="ts">
  import Content from "$lib/components/Content.svelte";
  import StatusBar from "$lib/components/StatusBar.svelte";
  import Navbar from "$lib/components/Navbar.svelte";
  import LeftDrawer from "$lib/components/LeftDrawer.svelte";
  import * as Sidebar from "$lib/components/ui/sidebar/index.js";
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
  <LeftDrawer />
  <div id="contentpage" class="flex flex-col h-fit">
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
        <h1>Welcome to the dashboard.</h1>
      {/snippet}
    </Content>

    <StatusBar></StatusBar>
  </div>
</Sidebar.Provider>
