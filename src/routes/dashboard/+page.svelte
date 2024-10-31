<script lang="ts">
    import SidebarPage from '$lib/components/sidebar-page.svelte'
    import Content from '$lib/components/Content.svelte'
    import StatusBar from '@/components/StatusBar.svelte'
    import Navbar from '@/components/Navbar.svelte'
</script>

<!-- <SidebarPage /> -->

<div id="contentpage" class="flex flex-col h-fit">
<Navbar>
    {#snippet topLeft()}
        TL
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