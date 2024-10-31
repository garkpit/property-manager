<script lang="ts">
	let { children } = $props<{ children: () => unknown }>()
</script>

<main class="h-fit">
    <div class="container mx-auto mt-14 mb-14">
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
