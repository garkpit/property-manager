<script lang="ts">
  import PageTemplate from "$lib/components/PageTemplate.svelte";
  import { Settings, CircleHelp, LogOut } from "lucide-svelte";
  const actionItems: any[] = [
    {
      groupName: "Settings",
      groupItems: [
        {
          icon: Settings,
          label: "Settings",
          onClick: () => console.log("Settings clicked"),
        },
        {
          icon: CircleHelp,
          label: "Help",
          onClick: () => console.log("Help clicked"),
        },
      ],
    },
    {
      groupName: "Information",
      groupItems: [
        {
          icon: Settings,
          label: "Info 1",
          onClick: () => console.log("Info 1 clicked"),
        },
        {
          icon: CircleHelp,
          label: "Info 2 - this is a longer label",
          onClick: () => console.log("Info 2 clicked"),
        },
      ],
    },
    {
      icon: LogOut,
      label: "Logout",
      onClick: () => console.log("Logout clicked"),
      separator: true,
    },
  ];
</script>

<PageTemplate {actionItems}>
  {#snippet TopLeft()}TL{/snippet}
  {#snippet TopCenter()}
    <div>TC</div>
  {/snippet}
  {#snippet TopRight()}TR{/snippet}

  {#snippet Middle()}
    Account
  {/snippet}

  <!--
  {#snippet BottomLeft()}<div>BL</div>{/snippet}
  {#snippet BottomCenter()}{/snippet}
  {#snippet BottomRight()}<div>BR</div>{/snippet}
  -->
</PageTemplate>
