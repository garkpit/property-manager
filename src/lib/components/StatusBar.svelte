<script lang="ts">
	import LanguageSelector from '$lib/components/LanguageSelector.svelte';
	import { Toaster } from '$lib/components/ui/sonner';
	import DarkModeToggle from '$lib/components/DarkModeToggle.svelte';
  
	let {
	  bottomLeft,
	  bottomCenter,
	  bottomRight,
	  footer,
	  bottomLeftData,
	  bottomCenterData,
	  bottomRightData
	} = $props<{
	  bottomLeft?: (data: any) => unknown,
	  bottomCenter?: (data: any) => unknown,
	  bottomRight?: (data: any) => unknown,
	  footer?: unknown,
	  bottomLeftData?: any,
	  bottomCenterData?: any,
	  bottomRightData?: any
	}>();
  </script>
  
	<footer 
	class="footer-height bg-background fixed left-0 right-0 z-30 flex items-center justify-between px-4 border-t"
	style="bottom: calc(max(var(--safe-area-inset-bottom, 0px) - 0.75rem, 0px))"
	>
	  <div class="flex items-center space-x-2">
		{#if bottomLeft}
		  {@render bottomLeft(bottomLeftData)}
		{:else}
		  <DarkModeToggle />
		{/if}
	  </div>
  
	  <div>
		{#if bottomCenter}
		  {@render bottomCenter(bottomCenterData)}
		{:else}
		  {__APP_TITLE__} v{__APP_VERSION__}
		{/if}
	  </div>
  
	  <div class="flex items-center space-x-2">
		{#if bottomRight}
		  {@render bottomRight(bottomRightData)}
		{:else}
		  <LanguageSelector />
		{/if}
	  </div>
	</footer>
	<Toaster richColors />
  