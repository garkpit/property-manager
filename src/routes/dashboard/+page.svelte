<script lang="ts">
    import SidebarPage from '$lib/components/sidebar-page.svelte'
    import Content from '$lib/components/Content.svelte'
    import StatusBar from '@/components/StatusBar.svelte'
    import Navbar from '@/components/Navbar.svelte'

    $effect(() => {
        const headerHeight = getComputedStyle(document.documentElement).getPropertyValue('--header-height');
        const headerHeightElement = document.getElementById('header-height');
        if (headerHeightElement) {
            headerHeightElement.textContent = headerHeight;
        }
        
        const safeAreaTop = getComputedStyle(document.documentElement).getPropertyValue('--safe-area-inset-top');
        const safeAreaTopElement = document.getElementById('safe-area-top');
        if (safeAreaTopElement) {
            safeAreaTopElement.textContent = safeAreaTop;
        }
        const footerHeight = getComputedStyle(document.documentElement).getPropertyValue('--footer-height');
        const footerHeightElement = document.getElementById('footer-height');
        if (footerHeightElement) {
            footerHeightElement.textContent = footerHeight;
        }
    });
</script>

<!-- <SidebarPage /> -->

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
        <div>
            Header height: <span id="header-height"></span><br/>
            Safe area top: <span id="safe-area-top"></span><br/>
            Footer height: <span id="footer-height"></span><br/>
          </div>
    {/snippet}
</Content>

<StatusBar />
