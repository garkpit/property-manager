<script lang="ts">
  import Button from "$lib/components/ui/button/button.svelte";
  import { Trash2 } from "lucide-svelte";

  let { onclick } = $props<{ onclick: () => void }>();
</script>

<Button variant="ghost" size="icon" {onclick} class="h-9 w-9">
  <Trash2 class="h-5 w-5 text-destructive" />
  <span class="sr-only">Save changes</span>
</Button>
