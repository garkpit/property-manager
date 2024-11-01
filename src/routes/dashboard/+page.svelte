<script lang="ts">
    import Content from '$lib/components/Content.svelte'
    import StatusBar from '@/components/StatusBar.svelte'
    import Navbar from '@/components/Navbar.svelte'
    import LeftDrawer from '$lib/components/LeftDrawer.svelte'
    import * as Sidebar from "$lib/components/ui/sidebar/index.js";

    let isDrawerOpen = $state(typeof window !== 'undefined' && window.innerWidth >= 768 ? true : false);

    // Add a window resize listener to update the drawer state
    $effect(() => {
        if (typeof window !== 'undefined') {
            const handleResize = () => {
                isDrawerOpen = window.innerWidth >= 768;
            };
            
            window.addEventListener('resize', handleResize);
            return () => window.removeEventListener('resize', handleResize);
        }
    });
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
                {#if isDrawerOpen}
                    Panel is Open
                {:else}
                    Panel is Closed
                {/if}
            {/snippet}
        </Content>

        <StatusBar />
    </div>
</Sidebar.Provider>