<script lang="ts">
  import LanguageSelector from "$lib/components/LanguageSelector.svelte";
  import { Toaster } from "$lib/components/ui/sonner";
  import DarkModeToggle from "$lib/components/DarkModeToggle.svelte";

  let {
    Left,
    Center,
    Right,
    FullStatusBar,
    LeftData,
    CenterData,
    RightData,
    FullStatusBarData,
  } = $props<{
    Left?: (data: any) => unknown;
    Center?: (data: any) => unknown;
    Right?: (data: any) => unknown;
    FullStatusBar?: (data: any) => unknown;
    footer?: unknown;
    LeftData?: any;
    CenterData?: any;
    RightData?: any;
    FullStatusBarData?: any;
  }>();
  // bg-background
</script>

<footer
  class="bg-background footer-height border-t flex items-center justify-between px-4 absolute bottom-0 left-0 right-0 z-30"
  style="bottom: var(--safe-area-inset-bottom, 0px)"
>
  {#if FullStatusBar}
    <div class="flex items-center justify-center w-full">
      {@render FullStatusBar(FullStatusBarData)}
    </div>
  {:else}
    <div class="flex items-center space-x-2">
      {#if Left}
        {@render Left(LeftData)}
      {:else}
        <DarkModeToggle />
      {/if}
    </div>

    <div>
      {#if Center}
        {@render Center(CenterData)}
      {:else}
        {__APP_TITLE__} v{__APP_VERSION__}
      {/if}
    </div>

    <div class="flex items-center space-x-2">
      {#if Right}
        {@render Right(RightData)}
      {:else}
        <LanguageSelector />
      {/if}
    </div>
  {/if}
</footer>
<Toaster richColors />
