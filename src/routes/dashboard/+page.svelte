<script lang="ts">
    import SidebarPage from '$lib/components/sidebar-page.svelte'
    import Content from '$lib/components/Content.svelte'
    import StatusBar from '@/components/StatusBar.svelte'
    import Navbar from '@/components/Navbar.svelte'

    const arr: number[] = [];
    for (let i = 0; i < 100; i++) {
        arr.push(i);
    }

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
        const mSafe = getComputedStyle(document.documentElement).getPropertyValue('var(--safe-area-inset-{top, right, bottom, left})');
        const mSafeElement = document.getElementById('m-safe');
        if (mSafeElement) {
            mSafeElement.textContent = mSafe;
        }
        const safeAreaInsetTop = getComputedStyle(document.documentElement).getPropertyValue('--safe-area-inset-top');
        const safeAreaInsetTopElement = document.getElementById('safe-area-inset-top');
        if (safeAreaInsetTopElement) {
            safeAreaInsetTopElement.textContent = safeAreaInsetTop;
        }
    });
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
        <div>
            Header height: <span id="header-height"></span><br/>
            Safe area top: <span id="safe-area-top"></span><br/>
            Footer height: <span id="footer-height"></span><br/>
            M safe: <span id="m-safe"></span><br/>
            Safe area inset top: <span id="safe-area-inset-top"></span><br/>
        </div>
        {#each arr as item}
            {item}<br/>
        {/each}
    {/snippet}
</Content>

<StatusBar />
</div>