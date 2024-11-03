<script lang="ts">
  import { Button } from "$lib/components/ui/button/index.js";
  import DarkModeToggle from "$lib/components/DarkModeToggle.svelte";
  import LanguageSelector from "$lib/components/LanguageSelector.svelte";
</script>

<div class="min-h-screen flex flex-col">
  <!-- Hero Section -->
  <main class="flex-1 container mx-auto px-4 py-16">
    <div class="text-center max-w-3xl mx-auto">
      <h1 class="text-4xl font-bold tracking-tight sm:text-6xl mb-6">
        Welcome to Our Demo App
      </h1>
      <p class="text-xl text-muted-foreground mb-8">
        Experience the power of SvelteKit with our feature-rich demonstration
        application
      </p>
      <div class="flex justify-center gap-4">
        <a href="/dashboard">
          <Button size="lg">Get Started</Button>
        </a>
      </div>
    </div>

    <!-- Features Grid -->
    <div class="mt-24 grid grid-cols-1 md:grid-cols-3 gap-8">
      <div class="text-center p-6">
        <h2 class="text-xl font-semibold mb-4">Dark Mode Support</h2>
        <p class="text-muted-foreground">
          Seamlessly switch between light and dark themes for comfortable
          viewing in any environment
        </p>
      </div>
      <div class="text-center p-6">
        <h2 class="text-xl font-semibold mb-4">Internationalization</h2>
        <p class="text-muted-foreground">
          Multi-language support to make our app accessible to users worldwide
        </p>
      </div>
      <div class="text-center p-6">
        <h2 class="text-xl font-semibold mb-4">Modern UI</h2>
        <p class="text-muted-foreground">
          Beautiful, responsive design built with modern web technologies
        </p>
      </div>
    </div>
  </main>

  <!-- Footer with toggles -->
  <div class="fixed bottom-4 right-4 flex gap-2">
    <DarkModeToggle />
    <LanguageSelector />
  </div>
</div>
