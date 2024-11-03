<script lang="ts">
  import * as Sidebar from "$lib/components/ui/sidebar";
  import LeftDrawer from "$lib/components/LeftDrawer.svelte";
  import StatusBar from "$lib/components/StatusBar.svelte";
  import Navbar from "$lib/components/Navbar.svelte";
  import Content from "$lib/components/Content.svelte";
  // bg-background???
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
            Right
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
