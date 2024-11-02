<script lang="ts">
    import Content from '$lib/components/Content.svelte'
    import StatusBar from '$lib/components/StatusBar.svelte'
    import Navbar from '$lib/components/Navbar.svelte'
    import LeftDrawer from '$lib/components/LeftDrawer.svelte'
    import * as Sidebar from "$lib/components/ui/sidebar/index.js";
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
                TR
            {/snippet}
        </Navbar>

        <Content>
            {#snippet content()}
                <h1>welcome to the dashboard</h1>
            {/snippet}
        </Content>

        <StatusBar />
    </div>
</Sidebar.Provider>