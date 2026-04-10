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

export const DictionaryChecker = () => {
  
  const [fileName, setFileName] = createSignal("");
  const [ready, setReady] = createSignal(false);
  const [results, setResults] = createSignal([]);

  onMount(async () => {
    if (!window.Go) {
      const script = document.createElement("script");
      script.src = wasmExecUrl;
      document.head.appendChild(script);
      await new Promise((resolve) => (script.onload = resolve));
    }
    const go = new window.Go();
    const { instance } = await WebAssembly.instantiateStreaming(
      fetch(wasmUrl),
      go.importObject
    );
    go.run(instance);
    setReady(true);
  });

  const handleFile = async (e) => {
    const file = e.target.files[0];
    const fn = window.processDictionary;
    if (file && ready() && fn) {
      setFileName(file.name);
      const data = fn(file.name, await file.text());
      setResults(data); 
    }
  };

  return (
    <div class="p-2 border border-dashed text-center">
      <p class="mb-2 font-bold">{ready() ? "Upload Dictionary" : "Initializing..."}</p>
      <input 
        type="file" 
        accept=".pl" 
        disabled={!ready()} 
        onChange={handleFile}
        class="block w-full text-sm disabled:opacity-50"
      />
      {fileName() && <div class="mt-2 text-xs italic">{fileName()}</div>}

      {results() && (
        <div class="grid grid-cols-3 gap-1 mt-4 text-xs font-mono border-t pt-2">
          {results().flatMap(({word, lang, confidence}) => (
            <><div class="truncate">{word}</div><div>{lang}</div><div>{confidence.toFixed(2)}</div></>
          ))}
        </div>
      )}
    </div>
  );
};
