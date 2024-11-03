<!-- svelte-ignore slot_element_deprecated -->
<script lang="ts">
  let { Left, Center, Right, LeftData, CenterData, RightData } = $props<{
    Left?: (data: any) => unknown;
    Center?: (data: any) => unknown;
    Right?: (data: any) => unknown;
    LeftData?: any;
    CenterData?: any;
    RightData?: any;
  }>();
  let sheetOpen = $state(false);

  function closeSheet() {
    sheetOpen = false;
  }

  // Move DOM-related logic into an effect
  const root = document.documentElement;
  const styles = getComputedStyle(root);
  // class="header-height bg-background fixed left-0 right-0 z-30 flex items-center justify-between px-4 border-b"
</script>

<header
  class="bg-background header-height border-t flex items-center justify-between px-4 absolute top-0 left-0 right-0 z-30"
  style="top: var(--safe-area-inset-top, 0px);"
>
  <div class="flex items-center space-x-2">
    {@render Left?.(LeftData)}
  </div>

  <div>
    {@render Center?.(CenterData)}
  </div>

  <div class="flex items-center">
    {@render Right?.(RightData)}
  </div>
</header>
