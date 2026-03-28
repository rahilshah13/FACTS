import { createSignal, onMount, For, createResource } from "solid-js";
import { load, Prolog } from 'trealla';
import { query, setQuery } from "./query";
import predicates from "./predicates.pl?raw";
import entries from "./words.pl?raw";
let pl;

export const Resolve = () => {

  const [res1, setRes1] = createSignal("")

  onMount(async () => {
    await load();
    pl = new Prolog();
    handleNext();
    location.reload();
  });

  // The next button does not work (the knowledge base isnt being reshuffled)
  const handleNext = async () => {
    let knowledgeBase = predicates + "\n" + entries.split('\n').sort(() => Math.random() - 0.5).join('\n');
    pl.fs.open("/english.pl", { write: true, create: true }).writeString(knowledgeBase);
    await pl.consult("/english.pl");
    const result = await pl.queryOnce('english:fill_template(["complete", "the", W1, "in", "a", "sensible", W2])');
    const { W1, W2 } = result.answer;
    console.log(W1, W2, "hash: ")
    let template = `complete the ${W1} in a sensible ${W2}`;
    setRes1(template);
    // await pl.queryOnce("delete_file('/english.pl')");
  };

  return (
    <div class="border border-fuchsia-800 text-xs w-full py-[2vh] px-[2vw] relative place-items-center bg-fuchsia-50">
      <span class="text-fuchsia-800">RESOLUTIONS</span>
      <div class="flex flex-col hover:cursor-pointer bg-amber-100">
        <div>QUERY: {query() || "empty"}</div>
        <div>{res1() || "loading..."}</div>
      </div>
      <button class="hover:cursor-pointer" onClick={handleNext}>NEXT</button>
    </div>
  );
};