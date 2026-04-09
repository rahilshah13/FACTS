import { createSignal, onMount } from "solid-js";
import wasmUrl from "../TinyGo/svg_gen.wasm?url";
import wasmExecUrl from "../TinyGo/wasm_exec.js?url";

export const SvgGen = () => {
  const [ready, setReady] = createSignal(false);
  const [svg, setSvg] = createSignal("");

  onMount(async () => {
    if (!window.Go) {
      const script = document.createElement("script");
      script.src = wasmExecUrl;
      document.head.appendChild(script);
      await new Promise((resolve) => (script.onload = resolve));
    }
    const go = new window.Go();
    const { instance } = await WebAssembly.instantiateStreaming(fetch(wasmUrl), go.importObject);
    go.run(instance);
    
    setReady(true);
    // Call the Go function and store the SVG string
    if (window.generateSVG) setSvg(window.generateSVG());
  });

  return (
    <div class="border p-2 text-center">
      <div class="font-bold mb-2">TinyGo SVG Gen Example</div>
      {!ready() ? (
        <p>Initializing...</p>
      ) : (
        <div class="flex justify-center" innerHTML={svg()} />
      )}
    </div>
  );
};