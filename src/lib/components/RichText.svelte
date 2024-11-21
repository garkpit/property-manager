<!-- RichText.svelte -->
<script lang="ts">
  import { Sun } from "lucide-svelte";
  import Suneditor from "suneditor";
  import plugins from "suneditor/src/plugins";
  import "suneditor/dist/css/suneditor.min.css";
  import { onMount, onDestroy } from "svelte";
  import type { SunEditorOptions } from "suneditor/src/options";
  import SunEditorCore from "suneditor/src/lib/core";

  let editor: SunEditorCore;
  let editorElement: HTMLElement;

  // Props using new Svelte 5 syntax
  let { 
    content = $bindable(""), 
    height = "300px", 
    buttonList = [
      ["undo", "redo"],
      ["font", "fontSize", "formatBlock"],
      ["bold", "underline", "italic", "strike", "subscript", "superscript"],
      ["removeFormat"],
      ["fontColor", "hiliteColor"],
      ["outdent", "indent"],
      ["align", "horizontalRule", "list", "table"],
      ["link", "image"],
      ["fullScreen", "showBlocks", "codeView"],
    ]
  } = $props();

  $effect(() => {
    if (editor) {
      editor.setContents(content);
    }
  });

  onMount(() => {
    editor = Suneditor.create(editorElement, {
      plugins: Object.values(plugins),
      height,
      buttonList,
      defaultStyle: "font-family: Arial; font-size: 14px;",
    });
    editor.onChange = function (contents) {
      console.log("Contents changed:", contents);
      content = contents;  // This will update the bound value
    };
  });

  onDestroy(() => {
    if (editor) {
      editor.destroy();
    }
  });
</script>

<div bind:this={editorElement}></div>

<style>
  div {
    width: 100%;
  }
</style>
