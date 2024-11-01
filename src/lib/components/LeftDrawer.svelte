<script lang="ts">
    import * as Sidebar from "$lib/components/ui/sidebar/index.js";
	import SearchForm from "$lib/components/search-form.svelte";
	import * as Collapsible from "$lib/components/ui/collapsible/index.js";
	import TeamSwitcher from "$lib/components/team-switcher.svelte";
	import GalleryVerticalEnd from "lucide-svelte/icons/gallery-vertical-end";
    import NavUser from "$lib/components/nav-user.svelte";
	import Minus from "lucide-svelte/icons/minus";
	import Plus from "lucide-svelte/icons/plus";
	import type { ComponentProps } from "svelte";
	import { AudioWaveform, Command, Settings, BookOpen, Code, Box } from "lucide-svelte"

	let { ref = $bindable(null), ...restProps }: ComponentProps<typeof Sidebar.Root> = $props();
	const data = {
        user: {
			name: "shadcn",
			email: "m@example.com",
			avatar: "/avatars/shadcn.jpg",
		},
		teams: [
			{
				name: "Acme Inc",
				logo: GalleryVerticalEnd,
				plan: "Enterprise",
			},
			{
				name: "Acme Corp.",
				logo: AudioWaveform,
				plan: "Startup",
			},
			{
				name: "Evil Corp.",
				logo: Command,
				plan: "Free",
			},
		],        
		versions: ["1.0.1", "1.1.0-alpha", "2.0.0-beta1"],
		navMain: [
			{
				title: "Getting Started",
				url: "#",
				icon: BookOpen,
				items: [
					{
						title: "Installation",
						url: "#",
					},
					{
						title: "Project Structure",
						url: "#",
					},
				],
			},
			{
				title: "Building Your Application",
				url: "#",
				icon: Box,
				items: [
					{
						title: "About",
						url: "dashboard/about",
					},
					{
						title: "Routing",
						url: "#",
					},
					{
						title: "Data Fetching",
						url: "#",
						isActive: true,
					},
					{
						title: "Rendering",
						url: "#",
					},
					{
						title: "Caching",
						url: "#",
					},
					{
						title: "Styling",
						url: "#",
					},
					{
						title: "Optimizing",
						url: "#",
					},
					{
						title: "Configuring",
						url: "#",
					},
					{
						title: "Testing",
						url: "#",
					},
					{
						title: "Authentication",
						url: "#",
					},
					{
						title: "Deploying",
						url: "#",
					},
					{
						title: "Upgrading",
						url: "#",
					},
					{
						title: "Examples",
						url: "#",
					},
				],
			},
			{
				title: "API Reference",
				url: "#",
				icon: Code,
				items: [
					{
						title: "Components",
						url: "#",
					},
					{
						title: "File Conventions",
						url: "#",
					},
					{
						title: "Functions",
						url: "#",
					},
					{
						title: "next.config.js Options",
						url: "#",
					},
					{
						title: "CLI",
						url: "#",
					},
					{
						title: "Edge Runtime",
						url: "#",
					},
				],
			},
			{
				title: "Architecture",
				url: "#",
				icon: Settings,
				items: [
					{
						title: "Accessibility",
						url: "#",
					},
					{
						title: "Fast Refresh",
						url: "#",
					},
					{
						title: "Svelte Compiler",
						url: "#",
					},
					{
						title: "Supported Browsers",
						url: "#",
					},
					{
						title: "Rollup",
						url: "#",
					},
				],
			},
		],
	};

</script>

<Sidebar.Root class="pt-[var(--header-height)] pb-[var(--footer-height)]">
	<Sidebar.Header>
		<TeamSwitcher teams={data.teams} />
	</Sidebar.Header>
	<Sidebar.Content>
		<Sidebar.Group>
			<Sidebar.Menu>
				{#each data.navMain as mainItem, index (mainItem.title)}
					<Collapsible.Root open={index === 1} class="group/collapsible">
						<Sidebar.MenuItem>
							<Collapsible.Trigger>
								{#snippet child({ props })}
									<Sidebar.MenuButton {...props}>
                                        {#if mainItem.icon}
										<mainItem.icon 
											class="mr-2 h-4 w-4" 
										/>
                                        {/if}
										{mainItem.title}
										<Plus
											class="ml-auto group-data-[state=open]/collapsible:hidden"
										/>
										<Minus
											class="ml-auto group-data-[state=closed]/collapsible:hidden"
										/>
									</Sidebar.MenuButton>
								{/snippet}
							</Collapsible.Trigger>
							{#if mainItem.items?.length}
								<Collapsible.Content>
									<Sidebar.MenuSub>
										{#each mainItem.items as item (item.title)}
											<Sidebar.MenuSubItem>
												<Sidebar.MenuSubButton isActive={item.isActive}>
													{#snippet child({ props })}
														<a href={item.url} {...props}
															>{item.title}</a
														>
													{/snippet}
												</Sidebar.MenuSubButton>
											</Sidebar.MenuSubItem>
										{/each}
									</Sidebar.MenuSub>
								</Collapsible.Content>
							{/if}
						</Sidebar.MenuItem>
					</Collapsible.Root>
				{/each}
			</Sidebar.Menu>
		</Sidebar.Group>
	</Sidebar.Content>
	<Sidebar.Footer>
		<NavUser user={data.user} />
	</Sidebar.Footer>    
	<Sidebar.Rail />
</Sidebar.Root>
