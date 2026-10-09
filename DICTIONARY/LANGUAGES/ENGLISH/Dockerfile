# --- Stage 1: Build SolidJS Frontend ---
FROM node:20-alpine AS builder
WORKDIR /app

RUN npm init -y && \
    npm pkg set type="module" && \
    npm install solid-js@1.8.15 vite@5.1.0 vite-plugin-solid terser trealla@0.10.0

RUN mkdir -p src public

# Create index.html (Light Mode)
RUN cat << 'EOF' > index.html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Wikipedia NLP Analyzer</title>
    <script src="https://cdn.tailwindcss.com"></script>
  </head>
  <body class="bg-slate-50 text-slate-900 min-h-screen">
    <div id="root"></div>
    <script type="module" src="/src/index.jsx"></script>
  </body>
</html>
EOF

# Create SolidJS App (src/index.jsx) with filtered stop words / common lexicon filter for missing words table
RUN cat << 'EOF' > src/index.jsx
import { render } from 'solid-js/web';
import { createSignal, onMount, For } from 'solid-js';
import { load, Prolog } from 'https://esm.sh/trealla@0.10.0';

const COMMON_STOP_WORDS = new Set([
  "the", "in", "and", "of", "a", "is", "to", "for", "on", "with", "as", "by", 
  "an", "at", "from", "it", "its", "that", "this", "are", "was", "were", "be", 
  "or", "not", "which", "he", "she", "they", "we", "you", "his", "her", "their", 
  "our", "has", "have", "had", "do", "does", "did", "but", "all", "one", "two"
]);

function App() {
  const [pl, setPl] = createSignal(null);
  const [status, setStatus] = createSignal('Loading Trealla WebAssembly Runtime & Dictionaries...');
  const [downloading, setDownloading] = createSignal(false);
  const [paused, setPaused] = createSignal(false);
  const [batchCountInput, setBatchCountInput] = createSignal('10');
  
  const [targetArticleCount, setTargetArticleCount] = createSignal(50);
  const [downloadedCount, setDownloadedCount] = createSignal(0);
  const [downloadQueue, setDownloadQueue] = createSignal([]);
  const [stats, setStats] = createSignal({
    totalExtracted: 0,
    validCount: 0,
    validQuestionCount: 0,
    validDeclarativeCount: 0,
    distinctUnknownCount: 0,
    wordFrequencies: [],
    missingWordsList: []
  });

  let wordFreqMap = {};
  let wordToArticlesMap = {};
  let unknownWordsMap = {};
  let allSentencesList = [];
  let activeEngine = null;

  onMount(async () => {
    try {
      await load();
      const p = new Prolog();
      activeEngine = p;
      
      const wordsRes = await fetch('/words.pl');
      await p.consultText(await wordsRes.text(), 'words.pl');

      const decRes = await fetch('/declarative.pl');
      await p.consultText(await decRes.text(), 'declarative.pl');

      const qRes = await fetch('/question.pl');
      await p.consultText(await qRes.text(), 'question.pl');

      setPl(p);
      setStatus('Engine Ready. Starting random Wikipedia article download pipeline...');
      startDownloadLoop(p);
    } catch (err) {
      setStatus(`Failed to initialize: ${err.message}`);
    }
  });

  const addBatchTarget = () => {
    const n = parseInt(batchCountInput(), 10);
    if (isNaN(n) || n <= 0) return;
    setTargetArticleCount(prev => prev + n);
    setStatus(`Expanded download target to ${targetArticleCount() + n} total articles.`);
  };

  const startDownloadLoop = async (engine) => {
    setDownloading(true);

    while (true) {
      if (paused() || downloadedCount() >= targetArticleCount()) {
        await new Promise(r => setTimeout(r, 500));
        continue;
      }

      setStatus(`Fetching random Wikipedia article ID and content (${downloadedCount() + 1}/${targetArticleCount()})...`);

      try {
        const randRes = await fetch(`https://en.wikipedia.org/w/api.php?action=query&list=random&rnnamespace=0&rnlimit=1&format=json&origin=*`);
        const randData = await randRes.json();
        const randomItem = randData.query.random[0];
        const pageId = randomItem.id;
        const title = randomItem.title;

        const url = `https://en.wikipedia.org/w/api.php?action=query&prop=extracts&explaintext=true&pageids=${pageId}&format=json&origin=*`;
        const res = await fetch(url);
        const data = await res.json();
        const pages = data.query.pages;
        const pageObj = pages[pageId];

        let statusText = "Success";
        if (pageObj && pageObj.extract) {
          processArticleText(engine, title, pageObj.extract);
        } else {
          statusText = "Empty Extract";
        }

        setDownloadedCount(c => c + 1);
        setDownloadQueue(prev => [{ title: `${title} (ID: ${pageId})`, status: statusText, time: new Date().toLocaleTimeString() }, ...prev.slice(0, 9)]);
      } catch (err) {
        setDownloadQueue(prev => [{ title: `Error fetching random article`, status: `${err.message}`, time: new Date().toLocaleTimeString() }, ...prev.slice(0, 9)]);
      }

      await new Promise(r => setTimeout(r, 600));
    }
  };

  const processArticleText = async (engine, title, text) => {
    const rawSentences = text.match(/[^.?!]+[.?!]+["']?|[^.?!]+\$/g) || [];

    for (const raw of rawSentences) {
      const cleaned = raw.trim().replace(/\n/g, ' ');
      if (cleaned.length < 3) continue;

      const words = cleaned.toLowerCase().match(/\b[a-z'-]+\b/g) || [];
      if (words.length === 0) continue;

      for (const w of words) {
        wordFreqMap[w] = (wordFreqMap[w] || 0) + 1;
        if (!wordToArticlesMap[w]) wordToArticlesMap[w] = new Set();
        wordToArticlesMap[w].add(title);

        let isKnown = false;
        try {
          for await (const ans of engine.query(`entry('${w}', _, _, _).`)) {
            if (ans !== false) { isKnown = true; break; }
          }
          if (!isKnown) {
            for await (const ans of engine.query(`aux_word('${w}').`)) {
              if (ans !== false) { isKnown = true; break; }
            }
          }
          if (!isKnown) {
            for await (const ans of engine.query(`prep_word('${w}').`)) {
              if (ans !== false) { isKnown = true; break; }
            }
          }
        } catch (e) {}

        // Filter out common closed-class stop words from the "missing words" tracker
        if (!isKnown && !COMMON_STOP_WORDS.has(w)) {
          unknownWordsMap[w] = (unknownWordsMap[w] || 0) + 1;
        }
      }

      let isDec = false;
      let isQ = false;
      const escaped = cleaned.replace(/"/g, '\\"').replace(/'/g, "\\'");

      try {
        for await (const ans of engine.query(`is_declarative("${escaped}").`)) {
          if (ans !== false) { isDec = true; break; }
        }
        for await (const ans of engine.query(`is_question("${escaped}").`)) {
          if (ans !== false) { isQ = true; break; }
        }
      } catch (e) {}

      allSentencesList.push({ text: cleaned, isDec, isQ, isValid: isDec || isQ });
    }

    recalculateStats();
  };

  const recalculateStats = () => {
    let totalExtracted = allSentencesList.length;
    let validCount = 0;
    let validDeclarativeCount = 0;
    let validQuestionCount = 0;

    for (const s of allSentencesList) {
      if (s.isValid) {
        validCount++;
        if (s.isDec) validDeclarativeCount++;
        if (s.isQ) validQuestionCount++;
      }
    }

    const sortedWords = Object.entries(wordFreqMap).sort((a, b) => b[1] - a[1]);
    const sortedMissingWords = Object.entries(unknownWordsMap).sort((a, b) => b[1] - a[1]);

    setStats({
      totalExtracted,
      validCount,
      validDeclarativeCount,
      validQuestionCount,
      distinctUnknownCount: sortedMissingWords.length,
      wordFrequencies: sortedWords,
      missingWordsList: sortedMissingWords
    });
  };

  const togglePause = () => setPaused(!paused());

  return (
    <div class="max-w-5xl mx-auto p-6 space-y-6">
      <header class="border-b border-slate-200 pb-4 flex flex-col md:flex-row justify-between items-start md:items-center gap-4 bg-white p-4 rounded-xl shadow-sm">
        <div>
          <h1 class="text-2xl font-bold tracking-tight text-indigo-600">Wikipedia NLP Workbench</h1>
          <p class="text-sm text-slate-500 mt-1">{status()}</p>
        </div>
        <div class="flex items-center gap-3">
          <div class="flex items-center gap-2 bg-slate-50 p-1.5 rounded-lg border border-slate-200">
            <input 
              type="number" 
              min="1" 
              value={batchCountInput()} 
              onInput={(e) => setBatchCountInput(e.target.value)}
              class="w-16 bg-white border border-slate-300 rounded px-2 py-1 text-sm text-slate-800 text-center font-medium focus:outline-none focus:border-indigo-500"
            />
            <button 
              onClick={addBatchTarget}
              class="bg-indigo-600 hover:bg-indigo-500 text-white px-3 py-1.5 rounded text-sm font-medium transition shadow-sm"
            >
              Add N Articles
            </button>
          </div>
          <button 
            onClick={togglePause}
            class={`px-4 py-2 rounded-lg font-medium text-white transition shadow-sm ${paused() ? 'bg-emerald-600 hover:bg-emerald-500' : 'bg-amber-600 hover:bg-amber-500'}`}
          >
            {paused() ? 'Resume Downloading' : 'Pause Downloading'}
          </button>
        </div>
      </header>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div class="bg-white border border-slate-200 rounded-xl p-5 shadow-sm flex flex-col justify-between">
          <div>
            <div class="text-sm font-medium text-slate-500">Articles Downloaded</div>
            <div class="text-3xl font-bold text-indigo-600 mt-2">{downloadedCount()} / {targetArticleCount()}</div>
          </div>
          <div class="w-full bg-slate-100 rounded-full h-2.5 mt-4 overflow-hidden">
            <div class="bg-indigo-600 h-2.5 rounded-full transition-all duration-300" style={`width: ${(downloadedCount() / targetArticleCount()) * 100}%`}></div>
          </div>
        </div>

        <div class="md:col-span-2 bg-white border border-slate-200 rounded-xl p-5 shadow-sm space-y-3">
          <h2 class="text-sm font-semibold text-slate-700 uppercase tracking-wider">Recent Random Wikipedia Downloads</h2>
          <div class="overflow-x-auto max-h-36">
            <table class="w-full text-left border-collapse text-sm">
              <thead class="bg-slate-50 border-b border-slate-200 text-slate-500">
                <tr>
                  <th class="p-2">Article Title & ID</th>
                  <th class="p-2">Status</th>
                  <th class="p-2">Time</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-slate-100">
                <For each={downloadQueue()}>
                  {(item) => (
                    <tr class="hover:bg-slate-50/80">
                      <td class="p-2 font-medium text-slate-800">{item.title}</td>
                      <td class="p-2 text-emerald-600">{item.status}</td>
                      <td class="p-2 text-slate-400 text-xs">{item.time}</td>
                    </tr>
                  )}
                </For>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div class="bg-white border border-slate-200 rounded-xl p-6 shadow-sm space-y-6">
        <h2 class="text-lg font-semibold text-slate-800">Automated Corpus & Grammar Metrics</h2>
        
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <div class="bg-slate-50 p-4 rounded-lg border border-slate-200">
            <div class="text-xs font-semibold text-slate-500 uppercase">1. Valid / Total Sentences</div>
            <div class="text-xl font-bold text-indigo-600 mt-1">
              {stats().validCount} / {stats().totalExtracted}
            </div>
          </div>

          <div class="bg-slate-50 p-4 rounded-lg border border-slate-200">
            <div class="text-xs font-semibold text-slate-500 uppercase">2. Valid Questions / Total Valid</div>
            <div class="text-xl font-bold text-indigo-600 mt-1">
              {stats().validQuestionCount} / {stats().validCount || 1}
            </div>
          </div>

          <div class="bg-slate-50 p-4 rounded-lg border border-slate-200">
            <div class="text-xs font-semibold text-slate-500 uppercase">3. Valid Declarative / Total Valid</div>
            <div class="text-xl font-bold text-indigo-600 mt-1">
              {stats().validDeclarativeCount} / {stats().validCount || 1}
            </div>
          </div>

          <div class="bg-slate-50 p-4 rounded-lg border border-slate-200">
            <div class="text-xs font-semibold text-slate-500 uppercase">4. Distinct Missing Words</div>
            <div class="text-xl font-bold text-rose-600 mt-1">
              {stats().distinctUnknownCount}
            </div>
          </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 pt-2">
          <div class="space-y-3">
            <h3 class="text-md font-semibold text-slate-700">5. Word Frequencies (Pulled from Wikipedia)</h3>
            <div class="max-h-80 overflow-y-auto border border-slate-200 rounded-lg">
              <table class="w-full text-left border-collapse">
                <thead class="bg-slate-50 sticky top-0 border-b border-slate-200 text-slate-600 text-sm">
                  <tr>
                    <th class="p-3">Word</th>
                    <th class="p-3">Frequency</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-slate-100 font-mono text-sm">
                  <For each={stats().wordFrequencies}>
                    {([word, freq]) => (
                      <tr class="hover:bg-slate-50">
                        <td class="p-3 text-slate-700">{word}</td>
                        <td class="p-3 text-indigo-600 font-semibold">{freq}</td>
                      </tr>
                    )}
                  </For>
                </tbody>
              </table>
            </div>
          </div>

          <div class="space-y-3">
            <h3 class="text-md font-semibold text-slate-700">Missing Words (Not in words.pl)</h3>
            <div class="max-h-80 overflow-y-auto border border-slate-200 rounded-lg">
              <table class="w-full text-left border-collapse">
                <thead class="bg-slate-50 sticky top-0 border-b border-slate-200 text-slate-600 text-sm">
                  <tr>
                    <th class="p-3">Missing Word</th>
                    <th class="p-3">Frequency</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-slate-100 font-mono text-sm">
                  <For each={stats().missingWordsList}>
                    {([word, freq]) => (
                      <tr class="hover:bg-slate-50">
                        <td class="p-3 text-slate-700">{word}</td>
                        <td class="p-3 text-rose-600 font-semibold">{freq}</td>
                      </tr>
                    )}
                  </For>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

render(() => <App />, document.getElementById('root'));
EOF

RUN cat << 'EOF' > vite.config.js
import { defineConfig } from 'vite';
import solidPlugin from 'vite-plugin-solid';

export default defineConfig({
  plugins: [solidPlugin()],
  server: { port: 3000 }
});
EOF

RUN npx vite build

# --- Stage 2: Serve via Nginx ---
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY words.pl declarative.pl question.pl /usr/share/nginx/html/

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
