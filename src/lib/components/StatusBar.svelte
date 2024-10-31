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
  
  <div class="flex flex-col h-screen">
	<footer class="footer-height bg-background fixed bottom-0 left-0 right-0 z-30 flex items-center justify-between px-4 border-t">
	  <div class="flex items-center space-x-2">
		{#if bottomLeft}
		  {@render bottomLeft(bottomLeftData)}
		{:else}
		  <DarkModeToggle />
		  <LanguageSelector />
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
		{/if}
	  </div>
	</footer>
	<Toaster richColors />
  </div>
  