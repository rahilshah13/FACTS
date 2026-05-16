import { createMemo, createSignal, For } from "solid-js";

const layerDefinitions = [
  { id: "wave", label: "Ocean wave height", color: "#38bdf8", opacity: 0.55 },
  { id: "ocean", label: "Ocean current vectors", color: "#2563eb", opacity: 0.45 },
  { id: "wind", label: "Wind vectors", color: "#22c55e", opacity: 0.4 },
  { id: "territory", label: "Territory boundaries", color: "#f97316", opacity: 0.75 },
];

const seasons = ["Current", "Winter", "Spring", "Summer", "Autumn"];
const tileSizes = ["Coarse", "Medium", "Fine"];

export function GlobalMapLayers() {
  const [activeLayers, setActiveLayers] = createSignal(layerDefinitions.map((layer) => layer.id));
  const [season, setSeason] = createSignal(seasons[0]);
  const [tileSize, setTileSize] = createSignal(tileSizes[1]);

  const layerSummary = createMemo(() =>
    layerDefinitions
      .filter((layer) => activeLayers().includes(layer.id))
      .map((layer) => layer.label)
      .join(", ") || "No layers selected"
  );

  const toggleLayer = (layerId) => {
    setActiveLayers((current) =>
      current.includes(layerId)
        ? current.filter((id) => id !== layerId)
        : [...current, layerId]
    );
  };

  return (
    <section class="flex flex-col gap-4 border border-sky-800 bg-slate-950 p-4 text-slate-100">
      <div class="sr-only">current weather global ocean wind territory map layers</div>
      <div class="flex flex-col gap-1">
        <span class="text-xs font-bold uppercase tracking-[0.3em] text-sky-300">Global map</span>
        <h2 class="text-lg font-bold">Area preserving climate and territory layers</h2>
        <p class="text-xs text-slate-300">
          Explore an equal-area world view with tile granularity, seasonal context, ocean and wind vector overlays,
          and international territory boundaries.
        </p>
      </div>

      <div class="grid gap-3 md:grid-cols-[220px_1fr]">
        <aside class="flex flex-col gap-3 border border-slate-700 bg-slate-900 p-3 text-xs">
          <label class="flex flex-col gap-1">
            <span class="font-bold text-slate-300">Tile granularity</span>
            <select class="bg-slate-950 p-2 text-slate-100" value={tileSize()} onInput={(event) => setTileSize(event.currentTarget.value)}>
              <For each={tileSizes}>{(size) => <option value={size}>{size}</option>}</For>
            </select>
          </label>

          <label class="flex flex-col gap-1">
            <span class="font-bold text-slate-300">Time of year</span>
            <select class="bg-slate-950 p-2 text-slate-100" value={season()} onInput={(event) => setSeason(event.currentTarget.value)}>
              <For each={seasons}>{(item) => <option value={item}>{item}</option>}</For>
            </select>
          </label>

          <div class="flex flex-col gap-2">
            <span class="font-bold text-slate-300">Visible layers</span>
            <For each={layerDefinitions}>
              {(layer) => (
                <label class="flex items-center gap-2">
                  <input
                    type="checkbox"
                    checked={activeLayers().includes(layer.id)}
                    onChange={() => toggleLayer(layer.id)}
                  />
                  <span>{layer.label}</span>
                </label>
              )}
            </For>
          </div>
        </aside>

        <div class="overflow-hidden border border-slate-700 bg-slate-900">
          <svg viewBox="0 0 960 480" role="img" aria-label={`Area preserving global map showing ${layerSummary()}`} class="h-[52vh] min-h-[320px] w-full">
            <rect width="960" height="480" fill="#020617" />
            <g stroke="#1e293b" stroke-width="1">
              <For each={[120, 240, 360, 480, 600, 720, 840]}>{(x) => <line x1={x} y1="24" x2={x} y2="456" />}</For>
              <For each={[80, 160, 240, 320, 400]}>{(y) => <line x1="32" y1={y} x2="928" y2={y} />}</For>
            </g>

            <g fill="#334155" stroke="#64748b" stroke-width="2" opacity="0.95">
              <path d="M92 154 178 110 277 126 330 188 286 244 173 234 113 206Z" />
              <path d="M236 279 311 262 359 318 331 398 274 376Z" />
              <path d="M404 133 516 108 614 142 637 225 568 264 468 236 386 199Z" />
              <path d="M627 177 760 140 861 184 829 263 722 277 643 238Z" />
              <path d="M681 312 798 301 860 365 792 417 696 390Z" />
            </g>

            {activeLayers().includes("wave") && (
              <g fill="none" stroke={layerDefinitions[0].color} stroke-width="6" opacity={layerDefinitions[0].opacity}>
                <path d="M42 332 C156 286 235 364 351 322 S587 279 722 324 884 350 930 316" />
                <path d="M48 382 C178 344 249 413 388 373 S596 340 742 382 879 412 932 374" />
              </g>
            )}

            {activeLayers().includes("ocean") && (
              <g stroke={layerDefinitions[1].color} stroke-width="5" opacity={layerDefinitions[1].opacity} stroke-linecap="round">
                <For each={[[118,310,54,-18],[438,295,62,16],[706,116,76,-8],[838,334,-66,20]]}>
                  {([x, y, dx, dy]) => <path d={`M${x} ${y} l${dx} ${dy} l-14 -8 m14 8 l-8 14`} fill="none" />}
                </For>
              </g>
            )}

            {activeLayers().includes("wind") && (
              <g stroke={layerDefinitions[2].color} stroke-width="4" opacity={layerDefinitions[2].opacity} stroke-linecap="round">
                <For each={[[156,92,92,10],[358,86,82,24],[565,83,92,-18],[245,420,85,-18],[580,423,100,10]]}>
                  {([x, y, dx, dy]) => <path d={`M${x} ${y} l${dx} ${dy} l-13 -9 m13 9 l-10 12`} fill="none" />}
                </For>
              </g>
            )}

            {activeLayers().includes("territory") && (
              <g fill="none" stroke={layerDefinitions[3].color} stroke-width="2" opacity={layerDefinitions[3].opacity} stroke-dasharray="8 6">
                <path d="M188 126 207 232" />
                <path d="M472 126 548 256" />
                <path d="M718 151 740 274" />
                <path d="M744 310 783 409" />
              </g>
            )}
          </svg>
          <div class="border-t border-slate-700 p-3 text-xs text-slate-300">
            <span class="font-bold text-slate-100">{tileSize()}</span> tiles · <span class="font-bold text-slate-100">{season()}</span> weather context · {layerSummary()}
          </div>
        </div>
      </div>
    </section>
  );
}
