<script lang="ts">
	let { children } = $props<{ children: () => unknown }>()
// style="margin-top: calc(var(--safe-area-inset-top, 0px) + 3.5rem);"

</script>

<main class="h-fit">
    <div class="container mx-auto mb-16"
    style="margin-top: calc(var(--safe-area-inset-top, 0px) + 3.5rem);"
    >
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
