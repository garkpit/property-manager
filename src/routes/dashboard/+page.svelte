<script lang="ts">
    import Content from '$lib/components/Content.svelte'
    import StatusBar from '@/components/StatusBar.svelte'
    import Navbar from '@/components/Navbar.svelte'
    import LeftDrawer from '$lib/components/LeftDrawer.svelte'
    import * as Sidebar from "$lib/components/ui/sidebar/index.js";

    let isDrawerOpen = $state(true); // Initialize with desired default state
</script>

<Sidebar.Provider bind:open={isDrawerOpen}>
    <LeftDrawer />

    <div id="contentpage" class="flex flex-col h-fit">
        <Navbar>
            {#snippet topLeft()}
                <Sidebar.Trigger>
                </Sidebar.Trigger>
            {/snippet}
            {#snippet title()}
                Title
            {/snippet}
            {#snippet topRight()}
                TR
            {/snippet}
        </Navbar>

        <Content>
            {#snippet children()}
                <h1>welcome to the dashboard</h1>
            {/snippet}
        </Content>

        <StatusBar />
    </div>
</Sidebar.Provider>