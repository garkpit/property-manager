<!-- svelte-ignore slot_element_deprecated -->
<script lang="ts">
    import { Menu } from 'lucide-svelte';
    import { Button } from "$lib/components/ui/button/index.js";
    import * as Sheet from "$lib/components/ui/sheet/index.js";
	let {
	  topLeft,
	  title,
	  topRight,
      topLeftData,
      titleData,
      topRightData
	} = $props<{
	  topLeft?: (data: any) => unknown,
	  title?: (data: any) => unknown,
	  topRight?: (data: any) => unknown,
	  topLeftData?: any,
	  titleData?: any,
	  topRightData?: any      
	}>();
    let sheetOpen = $state(false);

    function closeSheet() {
        sheetOpen = false;
    }

    // Move DOM-related logic into an effect
    const root = document.documentElement;
    const styles = getComputedStyle(root);
    let hh = $state(styles.getPropertyValue('--header-height').trim());

    $effect(() => {
        const updateInsets = () => {
            hh = styles.getPropertyValue('--header-height').trim();
        }

        updateInsets();
        setTimeout(updateInsets, 500);
        setTimeout(updateInsets, 1000);
        setTimeout(updateInsets, 3000);

        const observer = new MutationObserver(updateInsets);
        observer.observe(root, { attributes: true, attributeFilter: ['style'] });

        return () => observer.disconnect();
    });
</script>

  
<div class="flex flex-col h-screen">
	<header class="header-height bg-background fixed top-0 left-0 right-0 z-30 flex items-center justify-between px-4 border-b">
	  <!--<div class="flex items-center space-x-2">-->
        <div class="flex items-center space-x-2">
            {@render topLeft?.(topLeftData)}
        </div>

        <div>
            {@render title?.(titleData)}
        </div>

        <div class="flex items-center">
            {@render topRight?.(topRightData)}
        </div>

      <!--</div>-->
	</header>
  </div>
  


<!--
<main class="bg-background header-height fixed top-0 left-0 right-0 z-30 border-b">
    <div class="container mx-auto px-4 flex items-center justify-between">
        <div class="flex items-center space-x-4">
            {@render topLeft?.(topLeftData)}
        </div>

        <div class="flex-1 flex justify-center">
            {@render title?.(titleData)}
        </div>

        <div class="flex items-center">
            {@render topRight?.(topRightData)}
        </div>
    </div>
</main>
-->
