<script lang="ts">
	let { children } = $props<{ children: () => unknown }>()
</script>

<main class="h-fit overflow-y-auto">
    <div class="container mx-auto relative"
    style="margin-top: calc(var(--safe-area-inset-top, 0px) + 3.5rem); margin-bottom: calc(var(--safe-area-inset-bottom, 0px) + 3.5rem);"
    >
        <div class="fixed top-0 left-0 right-0 h-[var(--safe-area-inset-top,0px)] bg-background z-20"></div>
        
        <div class="fixed bottom-0 left-0 right-0 h-[var(--safe-area-inset-bottom,0px)] bg-background z-20"></div>
        
        <div class="relative">
            {@render children()}
        </div>
    </div>
</main>

<style>
  main {
    scrollbar-width: thin;
    scrollbar-color: var(--scrollbar) var(--scrollbar-bg);
  }

  main::-webkit-scrollbar {
    width: 8px;
  }

  main::-webkit-scrollbar-track {
    background: var(--scrollbar-bg);
  }

  main::-webkit-scrollbar-thumb {
    background-color: var(--scrollbar);
    border-radius: 4px;
  }
</style>
