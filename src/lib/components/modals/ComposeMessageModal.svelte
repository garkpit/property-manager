<script lang="ts">
  import * as Dialog from "$lib/components/ui/dialog";
  import { Button } from "$lib/components/ui/button";
  import CreateMessage from "../../../routes/messages/compose/CreateMessage.svelte";

  export let open = false;
</script>

<Dialog.Root bind:open>
  <Dialog.Content class="sm:max-w-[600px]">
    <Dialog.Header>
      <Dialog.Title>Compose Message</Dialog.Title>
    </Dialog.Header>

    <div class="py-4">
      <CreateMessage />
    </div>

    <Dialog.Footer>
      <Button variant="outline" on:click={() => (open = false)}>Cancel</Button>
    </Dialog.Footer>
  </Dialog.Content>
</Dialog.Root>
