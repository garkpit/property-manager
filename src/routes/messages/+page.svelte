<script lang="ts">
  import PageTemplate from "$lib/components/PageTemplate.svelte";
  import Inbox from "./Inbox.svelte";
  import Outbox from "./Outbox.svelte";
  import CreateMessage from "./CreateMessage.svelte";
  /*
  const actionItems: any[] = [
    {
      groupName: "Group Header Here",
      groupItems: [
        {
          icon: IconFromLucide,
          label: "Item Label Here",
          onClick: () => {console.log("item was clicked")},
        },
      ],
    }
  ];
  */
</script>

<!-- <PageTemplate {actionItems} /> -->
<PageTemplate>
  <!--{#snippet TopLeft()}{/snippet}-->
  {#snippet TopCenter()}
    Messages
  {/snippet}
  <!--{#snippet TopRight()}{/snippet}-->

  {#snippet Middle()}
    <h2>Inbox</h2>
    <Inbox />

    <h2>Outbox</h2>
    <Outbox />

    <h2>Create Message</h2>
    <CreateMessage />
  {/snippet}

  <!--{#snippet BottomLeft()}{/snippet}-->
  <!--{#snippet BottomCenter()}{/snippet}-->
  <!--{#snippet BottomRight()}{/snippet}-->
</PageTemplate>
