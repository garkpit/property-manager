<!-- RichText.svelte -->
<script lang="ts">
  import { Sun } from "lucide-svelte";
  import Suneditor from "suneditor";
  import plugins from "suneditor/src/plugins";
  import "suneditor/dist/css/suneditor.min.css";
  import { onMount, onDestroy } from "svelte";
  import type { SunEditorOptions } from "suneditor/src/options";
  import SunEditorCore from "suneditor/src/lib/core";

  let editor: SunEditorCore; //ExtendedSunEditorOptions;
  let editorElement: HTMLElement;

  //interface ExtendedSunEditorOptions extends SunEditorOptions {
  //  onChange?: (contents: string) => void;
  //}

  // Props using new Svelte 5 syntax
  const {
    content = "",
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
    ],
    update = (content: string) => {},
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
      update(contents);
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
