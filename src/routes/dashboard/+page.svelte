<script lang="ts">
    import Content from '$lib/components/Content.svelte'
    import StatusBar from '@/components/StatusBar.svelte'
    import Navbar from '@/components/Navbar.svelte'
    import * as Sidebar from "$lib/components/ui/sidebar/index.js";
    import { Menu } from 'lucide-svelte';
    import { Button } from "$lib/components/ui/button";
</script>

<Sidebar.Provider>
    <Sidebar.Root>
        <Sidebar.Content class="pt-[var(--header-height)]">
            <Sidebar.Group>
                <Sidebar.GroupLabel>Navigation</Sidebar.GroupLabel>
                <Sidebar.GroupContent>
                    <Sidebar.Menu>
                        <Sidebar.MenuItem>
                            <Sidebar.MenuButton>
                                {#snippet child({ props })}
                                    <a href="/dashboard" {...props}>
                                        <span>Dashboard</span>
                                    </a>
                                {/snippet}
                            </Sidebar.MenuButton>
                        </Sidebar.MenuItem>
                        <!-- Add more menu items as needed -->
                    </Sidebar.Menu>
                </Sidebar.GroupContent>
            </Sidebar.Group>
        </Sidebar.Content>
    </Sidebar.Root>

    <div id="contentpage" class="flex flex-col h-fit">
        <Navbar>
            {#snippet topLeft()}
                <Sidebar.Trigger>
                    {#snippet child({ props })}
                        <Button variant="ghost" size="icon" {...props}>
                            <Menu class="h-5 w-5" />
                        </Button>
                    {/snippet}
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