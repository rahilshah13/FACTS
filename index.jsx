import { render } from "https://esm.sh/solid-js@1.8.20/web";
import { createStore } from "https://esm.sh/solid-js@1.8.20/store";
import { onMount } from "https://esm.sh/solid-js@1.8.20";
import html from "https://esm.sh/solid-js@1.8.20/html";
import { load, Prolog } from "https://esm.sh/trealla@0.17.0";

const [state, setState] = createStore({
  rawInput: "",
  sentences: [],
  questionCount: 0,
  activeQuestion: null,
  allQuestionsList: [],
  ipaResult: "",
  engineReady: false,
});

let prologModule = null;

const tokenizeSentences = (text) =>
  text
    .split(/(?<=[.!?])\s+/)
    .map((s) => s.trim())
    .filter((s) => s.length > 0);

const sentenceToTokens = (sentenceText) =>
  sentenceText.toLowerCase().replace(/[.,!?;]/g, "").trim().split(/\s+/);

const queryOllamaForPos = async (word, sentence) => {
  try {
    const res = await fetch("/api/classify", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ word, sentence })
    });
    if (res.ok) {
      const data = await res.json();
      return data.pos || "n";
    }
  } catch (err) {
    console.error("Ollama query failed:", err);
  }
  return "n";
};

const getWordPosList = async (tokens, sentenceText) => {
  if (!prologModule || tokens.length === 0 || tokens[0] === "") return [];
  
  for (const token of tokens) {
    const checkQuery = `word_pos(${token}, POS).`;
    const res = await prologModule.queryOnce(checkQuery);
    if (res.status === "success" && res.answer && res.answer.POS.toString() === "unk") {
      const ollamaPos = await queryOllamaForPos(token, sentenceText);
      await prologModule.queryOnce(`assert_dynamic_pos(${token}, ${ollamaPos}).`);
    }
  }

  const queryStr = `sentence_pos_pairs([${tokens.join(", ")}], Pairs).`;
  try {
    const result = await prologModule.queryOnce(queryStr);
    if (result.status && result.answer && result.answer.Pairs) {
      const pairsRaw = result.answer.Pairs;
      const parsed = [];
      let curr = pairsRaw;
      while (curr && typeof curr === 'object' && curr.functor === '.') {
        const head = curr.args[0];
        if (head && head.functor === 'pos_pair') {
          parsed.push({ word: head.args[0].toString(), pos: head.args[1].toString() });
        }
        curr = curr.args[1];
      }
      if (parsed.length > 0) return parsed;

      if (Array.isArray(pairsRaw)) {
        return pairsRaw.map(item => {
          if (item && item.args) {
            return { word: item.args[0].toString(), pos: item.args[1].toString() };
          }
          return { word: "?", pos: "unk" };
        });
      }
    }
  } catch (err) {
    console.error("Failed to query POS pairs:", err);
  }
  return tokens.map((t) => ({ word: t, pos: "unk" }));
};

const evaluateSentence = async (tokens) => {
  if (!prologModule || tokens.length === 0 || tokens[0] === "") return false;
  const queryStr = `declarative_sentence([${tokens.join(", ")}]).`;
  try {
    const result = await prologModule.queryOnce(queryStr);
    return result.status === "success";
  } catch (err) {
    return false;
  }
};

const initProlog = async () => {
  try {
    await load();
    prologModule = new Prolog();

    const resWords = await fetch("/words.pl");
    const wordsSource = await resWords.text();
    prologModule.fs.open("/words.pl", { write: true, create: true }).writeString(wordsSource);
    await prologModule.consult("/words.pl");

    const resLogic = await fetch("/logic.pl");
    const logicSource = await resLogic.text();
    prologModule.fs.open("/logic.pl", { write: true, create: true }).writeString(logicSource);
    await prologModule.consult("/logic.pl");

    setState("engineReady", true);
  } catch (err) {
    console.error("Failed to load Prolog runtime or modules:", err);
  }
};

const updateQuestionMetrics = async () => {
  try {
    const countResult = await prologModule.queryOnce("count_questions(Count).");
    if (countResult.status && countResult.answer && countResult.answer.Count !== undefined) {
      const countVal = Number(countResult.answer.Count);
      setState("questionCount", isNaN(countVal) ? 0 : countVal);
    }

    const listResult = await prologModule.queryOnce("all_questions(Qs).");
    if (listResult.status && listResult.answer && listResult.answer.Qs) {
      const qRaw = listResult.answer.Qs;
      const qList = [];
      let curr = qRaw;
      while (curr && typeof curr === 'object' && curr.functor === '.') {
        qList.push(curr.args[0].toString());
        curr = curr.args[1];
      }
      setState("allQuestionsList", qList.length > 0 ? qList : (Array.isArray(qRaw) ? qRaw : []));
    }
  } catch (err) {
    setState("questionCount", 0);
    setState("allQuestionsList", []);
  }
};

export const updateInput = async (text) => {
  setState("rawInput", text);
  setState("ipaResult", "");
  const rawList = tokenizeSentences(text);

  const evaluated = await Promise.all(
    rawList.map(async (sentenceText) => {
      const tokens = sentenceToTokens(sentenceText);
      const posPairs = await getWordPosList(tokens, sentenceText);
      const isDeclarative = await evaluateSentence(tokens);
      return { text: sentenceText, tokens, isDeclarative, posPairs };
    })
  );

  setState("sentences", evaluated);

  if (prologModule) {
    const validTokenLists = evaluated.filter((s) => s.isDeclarative).map((s) => s.tokens);
    if (validTokenLists.length > 0) {
      const plListStr = `[${validTokenLists.map((t) => `[\${t.join(", ")}]`).join(", ")}].`;
      await prologModule.queryOnce(`register_declarations(${plListStr})`);
      await updateQuestionMetrics();
    } else {
      await prologModule.queryOnce("retractall(current_declaration(_, _, _)).");
      setState({ questionCount: 0, activeQuestion: null, allQuestionsList: [] });
    }
  }
};

export const generateRandomQuestion = async () => {
  if (!prologModule || state.questionCount === 0) return;
  try {
    const result = await prologModule.queryOnce("random_question(Q).");
    if (result.status && result.answer && result.answer.Q) {
      setState("activeQuestion", result.answer.Q.toString());
    }
  } catch (err) {
    console.error("Failed to generate question:", err);
  }
};

export const convertToIPA = async () => {
  if (!prologModule || !state.rawInput.trim()) return;
  try {
    const escapedInput = state.rawInput.replace(/"/g, '\\"');
    const queryStr = `ipa_string("${escapedInput}", IPA).`;
    const result = await prologModule.queryOnce(queryStr);
    if (result.status && result.answer && result.answer.IPA) {
      setState("ipaResult", result.answer.IPA.toString());
    } else {
      setState("ipaResult", "Could not serialize IPA.");
    }
  } catch (err) {
    console.error("Failed to convert to IPA:", err);
    setState("ipaResult", "Error computing IPA.");
  }
};

export const playAudio = () => {
  if (!state.rawInput.trim() || !("speechSynthesis" in window)) return;
  window.speechSynthesis.cancel();
  const utterance = new SpeechSynthesisUtterance(state.rawInput);
  utterance.rate = 1.0;
  window._speechUtterance = utterance;
  window.speechSynthesis.speak(utterance);
};

const createPosBadgesElement = (posPairs) => {
  const container = document.createElement("div");
  container.className = "flex flex-wrap gap-2 mt-3 pt-3 border-t border-slate-200/60";
  posPairs.forEach((p) => {
    const badge = document.createElement("div");
    badge.className = "bg-white border border-slate-300 text-slate-800 px-2.5 py-1 rounded text-xs shadow-2xs flex flex-col items-center";
    
    const wordSpan = document.createElement("span");
    wordSpan.className = "font-bold";
    wordSpan.textContent = p.word;
    
    const posSpan = document.createElement("span");
    posSpan.className = "text-[10px] text-indigo-600 uppercase font-mono tracking-wider";
    posSpan.textContent = p.pos;
    
    badge.appendChild(wordSpan);
    badge.appendChild(posSpan);
    container.appendChild(badge);
  });
  return container;
};

const renderSentenceItem = (sentence) => {
  const containerClass = sentence.isDeclarative 
    ? "p-4 rounded-lg border transition-colors bg-emerald-50 border-emerald-300 text-emerald-950 shadow-2xs" 
    : "p-4 rounded-lg border transition-colors bg-rose-50 border-rose-300 text-rose-950 shadow-2xs";
    
  const badgeClass = sentence.isDeclarative 
    ? "text-xs px-2.5 py-1 rounded-md font-bold uppercase tracking-wide bg-emerald-200 text-emerald-900" 
    : "text-xs px-2.5 py-1 rounded-md font-bold uppercase tracking-wide bg-rose-200 text-rose-900";
    
  const badgeText = sentence.isDeclarative 
    ? "✓ Valid Declarative Sentence" 
    : "✗ Non-Declarative (Highlighted Red)";

  const el = html`
    <div class=${containerClass}>
      <div class="flex justify-between items-center mb-1">
        <span class="font-semibold text-base">${sentence.text}</span>
        <span class=${badgeClass}>${badgeText}</span>
      </div>
    </div>
  `;

  const badgesEl = createPosBadgesElement(sentence.posPairs);
  el.appendChild(badgesEl);
  return el;
};

const renderAllQuestions = () => {
  if (state.allQuestionsList.length === 0) return null;
  return html`
    <div class="mt-4 pt-3 border-t border-sky-200">
      <h3 class="text-xs font-bold text-sky-800 uppercase tracking-wider mb-2">All Generated Questions:</h3>
      <ul class="list-disc list-inside space-y-1 text-xs text-sky-950">
        ${state.allQuestionsList.map(q => html`<li>\${q}</li>`)}
      </ul>
    </div>
  `;
};

function App() {
  onMount(() => {
    initProlog();
  });

  return html`
    <main class="max-w-3xl mx-auto p-6 font-sans">
      <h1 class="text-2xl font-bold mb-2 text-slate-900">Declarative Deliverable Parser</h1>
      <p class="text-sm text-slate-600 mb-6">
        Powered by Trealla-js (Client-side Prolog DCG with 30k Lexicon) & Ollama Gemma 2b
      </p>

      <div class="mb-6">
        <label class="block text-sm font-medium text-slate-700 mb-2">
          Type sentences (Declarative sentences highlight green with validation indicator; non-declarative highlight red):
        </label>
        <textarea
          class="w-full p-3 border rounded-lg shadow-sm focus:ring-2 focus:ring-indigo-500 outline-none bg-white text-slate-900"
          rows="4"
          placeholder="e.g., We need to build an electric catamaran. What is the status?"
          value=${state.rawInput}
          onInput=${(e) => updateInput(e.target.value)}
        />
        <div class="flex gap-3 mt-3">
          <button
            class="px-4 py-2 bg-indigo-600 text-white rounded-md text-sm font-medium hover:bg-indigo-700 disabled:opacity-50 transition-colors shadow-sm"
            disabled=${!state.engineReady || !state.rawInput.trim()}
            onClick=${convertToIPA}
          >
            Convert to IPA
          </button>
          <button
            class="px-4 py-2 bg-emerald-600 text-white rounded-md text-sm font-medium hover:bg-emerald-700 disabled:opacity-50 transition-colors shadow-sm"
            disabled=${!state.rawInput.trim()}
            onClick=${playAudio}
          >
            🔊 Play Audio Playback
          </button>
        </div>
      </div>

      ${() =>
        state.ipaResult
          ? html`
              <section class="mb-6 p-4 bg-indigo-50 rounded-lg border border-indigo-200 shadow-sm">
                <h2 class="text-xs font-bold text-indigo-800 uppercase tracking-wider mb-1">
                  IPA Serialization
                </h2>
                <p class="font-mono text-indigo-950 text-sm bg-white p-2.5 rounded border border-indigo-200">
                  \${state.ipaResult}
                </p>
              </section>
            `
          : null}

      <section class="mb-6 p-4 bg-white rounded-lg border border-slate-200 shadow-sm">
        <h2 class="text-xs font-bold text-slate-500 uppercase tracking-wider mb-3">
          Sentence Analysis, Validity & Part-of-Speech Tags
        </h2>
        <div class="flex flex-col gap-3">
          ${() =>
            state.sentences.length > 0
              ? state.sentences.map(renderSentenceItem)
              : html`<span class="text-slate-400 text-sm italic">Awaiting input sentences...</span>`}
        </div>
      </section>

      <section class="p-4 bg-sky-50 rounded-lg border border-sky-200 shadow-sm">
        <div class="flex justify-between items-center mb-3">
          <h2 class="text-xs font-bold text-sky-800 uppercase tracking-wider">
            Derived Questions (${() => state.questionCount} valid generated)
          </h2>
          <button
            class="px-4 py-2 bg-sky-600 text-white rounded-md text-sm font-medium hover:bg-sky-700 disabled:opacity-50 transition-colors shadow-sm"
            disabled=${state.questionCount === 0 || !state.engineReady}
            onClick=${generateRandomQuestion}
          >
            Generate Random Question
          </button>
        </div>
        ${() =>
          state.activeQuestion
            ? html`
                <p class="mt-3 p-3 bg-white rounded border border-sky-300 text-sky-950 font-medium text-sm">
                  "\${state.activeQuestion}"
                </p>
              `
            : null}
        
        ${renderAllQuestions}
      </section>
    </main>
  `;
}

render(() => html`<${App} />`, document.getElementById("app"));