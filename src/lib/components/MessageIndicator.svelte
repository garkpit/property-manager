<script lang="ts">
  import { Bell, Mail, Building2 } from "lucide-svelte";
  import { setMode } from "mode-watcher";
  import { Button } from "$lib/components/ui/button";
  import { Badge } from "$lib/components/ui/badge";
  import * as Popover from "$lib/components/ui/popover";
  import { t } from "$lib/i18n";
  import AnimatedBell from "$lib/components/iconbuttons/AnimatedBell.svelte";

  let open = $state(false);

  function setTheme(mode: "light" | "dark" | "system") {
    setMode(mode);
    open = false;
  }
  // Bell class="h-[1.2rem] w-[1.2rem] rotate-0 scale-100 transition-all dark:-rotate-90 dark:scale-0"
</script>

<Popover.Root bind:open>
  <Popover.Trigger>
    <Button variant="ghost" class="ml-2">
      <Badge variant="destructive">4</Badge>
      <AnimatedBell classes="h-4 w-4" fill="transparent" />
      <span class="sr-only">Message Indicator</span>
    </Button>
  </Popover.Trigger>
  <Popover.Content class="w-56">
    <div class="grid gap-4 text-center">
      <h4 class="font-medium leading-none">Waiting Messages</h4>
      <Button
        variant="outline"
        class="flex items-center gap-2 w-full justify-start"
      >
        <Badge variant="destructive">1</Badge>
        <Building2 class="h-4 w-4" /> new invitation
      </Button>
      <Button
        variant="outline"
        class="flex items-center gap-2 w-full justify-start"
      >
        <Badge variant="destructive">3</Badge>
        <Mail class="h-4 w-4" /> new messages
      </Button>
    </div>
  </Popover.Content>
</Popover.Root>
