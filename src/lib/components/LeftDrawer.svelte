<script lang="ts">
    import * as Sidebar from "$lib/components/ui/sidebar/index.js";
</script>

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
