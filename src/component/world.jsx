import { createMemo, createSignal, For, onMount, Show } from "solid-js";

const LAYER_DEFINITIONS = [
  { id: "wave", label: "Ocean wave height", render: (s) => window.generateWaves?.(s) },
  { id: "ocean", label: "Ocean current vectors", render: () => window.generateOceanCurrents?.() },
  { id: "wind", label: "Wind vectors", render: (s) => window.generateWind?.(s) },
  { id: "territory", label: "Territory boundaries", render: (_, g) => window.generateTerritorialBoundaries?.(g) },
];

const SEASONS = ["Current", "Winter", "Spring", "Summer", "Autumn"];

export function WorldMap() {
  const [activeLayers, setActiveLayers] = createSignal(["wave", "ocean", "wind", "territory"]);
  const [season, setSeason] = createSignal(SEASONS[0]);
  const [gridSpacing, setGridSpacing] = createSignal(80);
  const [wasmReady, setWasmReady] = createSignal(false);

  onMount(() => {
    const timer = setInterval(() => {
      if (window.generateGrid) { setWasmReady(true); clearInterval(timer); }
    }, 100);
  });

  const toggleLayer = (id) => setActiveLayers(prev => 
    prev.includes(id) ? prev.filter(l => l !== id) : [...prev, id]
  );

  const densityLabel = createMemo(() => {
    const s = gridSpacing();
    return `${s > 110 ? "Coarse" : s < 45 ? "Fine" : "Medium"} (${s}px)`;
  });

  return (
    <section class="flex flex-col gap-4 border p-4 font-sans grid gap-3 md:grid-cols-[200px_1fr]">
      
      <form class="flex flex-col gap-3 border p-2 text-xs" onSubmit={(e) => e.preventDefault()}>
        <label class="block">
          <span class="block mb-1 font-bold">Grid: {densityLabel()}</span>
          <input type="range" min="35" max="160" step="5" value={gridSpacing()} onInput={(e) => setGridSpacing(Number(e.currentTarget.value))} class="w-full h-1 appearance-none cursor-pointer" />
        </label>

        <label class="block">
          <span class="block mb-1 font-bold">Season</span>
          <select class="p-1 border w-full" value={season()} onInput={(e) => setSeason(e.currentTarget.value)}>
            <For each={SEASONS}>{(item) => <option value={item}>{item}</option>}</For>
          </select>
        </label>

        <fieldset class="flex flex-col gap-1.5 pt-1 border-t border-none p-0 m-0">
          <For each={LAYER_DEFINITIONS}>{(layer) => (
            <label class="flex items-center gap-2 cursor-pointer select-none">
              <input type="checkbox" checked={activeLayers().includes(layer.id)} onChange={() => toggleLayer(layer.id)} />
              <span>{layer.label}</span>
            </label>
          )}</For>
        </fieldset>
      </form>

      <section class="overflow-hidden border flex flex-col justify-between w-full overflow-auto">
        <Show when={wasmReady()} fallback={<p class="h-[55vh] min-h-[350px] flex items-center justify-center text-xs font-mono m-0">Rendering...</p>}>
          <svg viewBox="0 0 960 500" class="h-[55vh] min-h-[350px] w-full block" role="img">
            <g innerHTML={window.generateGrid?.(gridSpacing())} />
            <g innerHTML={window.generateLandmasses?.()} />
            <For each={LAYER_DEFINITIONS}>{(layer) => (
              <Show when={activeLayers().includes(layer.id)}>
                <g innerHTML={layer.render(season(), gridSpacing())} />
              </Show>
            )}</For>
          </svg>
        </Show>
      </section>
    </section>
  );
}