import { createSignal, onMount, createResource } from "solid-js";
import svgWASM from "./TinyGo/svg_gen.wasm?url";
import translationWASM from "./TinyGo/translation_checker.wasm?url";
import trieWASM from "./TinyGo/trie.wasm?url";
import wasmExecUrl from "./TinyGo/wasm_exec.js?url";


export function SvgGen() {
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
    const { instance } = await WebAssembly.instantiateStreaming(fetch(svgWASM), go.importObject);
    go.run(instance);    
    setReady(true);
    if (window.generateSVG) setSvg(window.generateSVG());
  });

  return (
    <div class="border p-2 text-center">
      <div class="font-bold mb-2">TinyGo SVG Gen Example</div>
      { !ready() ? (<p>Initializing...</p>) : (<div class="flex justify-center" innerHTML={svg()} />)}
    </div>
  );
}

export function DictionaryChecker() {
  
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
      fetch(translationWASM),
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
      <p class="mb-2 font-bold">{ready() ? "Upload Dictionary (.pl)" : "Initializing..."}</p>
      <input 
        type="file" 
        accept=".pl" 
        disabled={!ready()} 
        onChange={handleFile}
        class="block w-full text-sm disabled:opacity-50"
      />
      {fileName() && <div class="mt-2 text-xs italic">{fileName()}</div>}
      {results() && 
        <div class="grid grid-cols-3 gap-1 mt-4 text-xs font-mono border-t pt-2">
          {results().flatMap(({word, lang, confidence}) => (<><div class="truncate">{word}</div><div>{lang}</div><div>{confidence.toFixed(2)}</div></>))}
        </div>
      }
    </div>
  );
}

export async function makeTrie() {
  if (!window.Go) {
    const script = document.createElement("script");
    script.src = wasmExecUrl;
    document.head.appendChild(script);
    await new Promise((resolve) => (script.onload = resolve));
  }

  const go = new window.Go();
  const { instance } = await WebAssembly.instantiateStreaming(
    fetch(trieWASM),
    go.importObject
  );
  go.run(instance);

  const pl_dictionary = Object.values(import.meta.glob("../../DICTIONARY/LANGUAGES/ENGLISH/words.pl", { 
    query: '?raw', 
    import: 'default', 
    eager: true 
  }))[0];

  if (pl_dictionary && window.initDictionary && window.matchSubstring) {
    window.initDictionary(pl_dictionary);
    console.log("Matches for 'aa':", window.matchSubstring("aa")); 
    console.log("Matches for 'ba':", window.matchSubstring("ba")); 
    console.log("Matches for 'don':", window.matchSubstring("don")); 
  } else {
    console.error("Dictionary file missing or WASM hooks failed to bind onto global window.");
  }
}

export function WebsocketService() {
  const AUDIT_LOG = ""
  const [connected, setConnected] = createSignal(false);
  const [userQueue, setUQ] = createSignal(["user queue"]);
  const [adminQueue, setAQ] = createSignal(["admin queue"]);

  async function streamFacts() {
    console.log("STREAM FACTS!");
    return {hi: "hi"};
  };

  const [facts, { refetch: rf, mutate: mf }] = createResource(streamFacts, { initialValue: {hi: "ddd"}, name: "facts", onHydrated: () => {},});
  return (<div>WebsocketService</div>)
}


export function UvViewer() {
  const [imageUrl, setImageUrl] = createSignal('');
  const [isLoading, setIsLoading] = createSignal(true);
  const [ready, setReady] = createSignal(false);
  const [error, setError] = createSignal('');

  onMount(async () => {
    try {
      const dartModule = await import(/* @vite-ignore */ new URL("./Dart/bin/uv_rasterizer.mjs", import.meta.url).href);
      const wasmSourceStream = fetch(/* @vite-ignore */ new URL("./Dart/bin/uv_rasterizer.wasm", import.meta.url).href);

      const compiledApp = await dartModule.compileStreaming(wasmSourceStream);
      const instantiatedApp = await compiledApp.instantiate({});
      
      instantiatedApp.invokeMain();    
      
      setReady(true);
      setIsLoading(false);
    } catch (err) {
      console.error("Failed to boot Dart Wasm:", err);
      setError(`Failed to boot Dart Wasm: ${err.message || err}`);
      setIsLoading(false);
    }
  });

  const generateMeshUvMap = () => {
    if (!ready() || typeof window.generateUVMapWasm !== 'function') {
      setError('Wasm module is not ready yet.');
      return;
    }

    try {
      setError('');

      const mockUvBuffer = new Float32Array([
        0.5, 1.0,
        0.0, 0.0,
        1.0, 0.0,
        0.5, 0.3
      ]);

      const mockIndexBuffer = new Int32Array([
        0, 1, 3,
        0, 3, 2,
        1, 2, 3
      ]);

      const imageSize = 512;
      
      const pngUint8Array = window.generateUVMapWasm(mockUvBuffer, mockIndexBuffer, imageSize);
      const blob = new Blob([pngUint8Array], { type: 'image/png' });
      const url = URL.createObjectURL(blob);    
      
      if (imageUrl()) URL.revokeObjectURL(imageUrl());
      setImageUrl(url);
    } catch (execError) {
      setError(`Execution crash: ${execError.message}`);
    }
  };

  return (
    <div class="border border-4 border-red-300" style={{ padding: '20px', "font-family": 'sans-serif' }}>
      <h2>Dart Wasm UV Map Generator</h2>
      
      <Show when={isLoading()}>
        <p>Compiling and spinning up Dart WebAssembly environment...</p>
      </Show>

      <Show when={error()}>
        <p style={{ color: 'red', "font-weight": 'bold' }}>{error()}</p>
      </Show>

      <Show when={!isLoading()}>
        <div style={{ "margin-bottom": '15px' }}>
          <button 
            onClick={generateMeshUvMap}
            style={{
              padding: '10px 15px',
              background: '#2563eb',
              color: 'white',
              border: 'none',
              "border-radius": '4px',
              cursor: 'pointer'
            }}
          >
            Rasterize Mesh Buffers
          </button>
        </div>
      </Show>

      <Show when={imageUrl()}>
        <div>
          <h3>Output PNG Layout Target:</h3>
          <img 
            src={imageUrl()} 
            alt="Generated UV Map Wireframe" 
            style={{ border: '2px solid #444', "background-color": '#1e1e1e', "max-width": '100%' }}
          />
        </div>
      </Show>
    </div>
  );
}