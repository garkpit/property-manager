<script lang="ts">
  import Button from "$lib/components/ui/button/button.svelte";
  import { Check } from "lucide-svelte";

  let { onclick } = $props<{ onclick: () => void }>();
</script>

<Button variant="ghost" size="icon" {onclick} class="h-9 w-9">
  <Check class="h-5 w-5" />
  <span class="sr-only">Save changes</span>
</Button>
