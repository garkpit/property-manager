<script lang="ts">
	import { Button } from '$lib/components/ui/button/index.js'
	function handleClick() {
		const output = document.getElementById('output')
		if (output) {
			if (output.textContent === '') {
				output.textContent = 'Welcome to SvelteKit'
			} else {
				output.textContent = ''
			}
		}
	}
</script>

<div class="h-screen flex flex-col items-center justify-center">
	<div class="h-24 flex flex-col items-center justify-center gap-8">
		<Button onclick={handleClick}>Click me</Button>
		<div id="output" class="h-6"></div>
	</div>
</div>
