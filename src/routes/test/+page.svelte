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
              <h1 class="text-3xl font-bold">Welcome to Test Page</h1>
            </div>

            <div class="mt-8 grid gap-6 flex-1">
              {#each Array(10) as _, i}
                <div class="rounded-lg border bg-card p-6 shadow-sm">
                  <h2 class="text-xl font-semibold mb-4">
                    Sample Content Section {i + 1}
                  </h2>
                  <p class="text-muted-foreground">
                    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed
                    do eiusmod tempor incididunt ut labore et dolore magna
                    aliqua. Ut enim ad minim veniam, quis nostrud exercitation
                    ullamco laboris nisi ut aliquip ex ea commodo consequat.
                  </p>
                </div>
              {/each}
            </div>
          {/snippet}
        </Content>

        <StatusBar />
      </div>
    </main>
  </div>
</Sidebar.Provider>
