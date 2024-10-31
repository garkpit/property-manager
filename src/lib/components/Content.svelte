<script lang="ts">
	let { children } = $props<{ children: () => unknown }>()
</script>

<main class="flex-grow overflow-y-auto h-[calc(100vh-var(--header-height))]">
  <div class="container mx-auto mt-14">
    {@render children()}
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
