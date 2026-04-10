import { createSignal, onMount, For, createResource } from "solid-js";
import { load, Prolog } from 'trealla';
import { query, setQuery } from "./query";
import { DictionaryChecker, SvgGen } from "./utils";
// files["./Prolog/predicates.pl"]
const files = import.meta.glob("./Prolog/*.pl", { query: '?raw', import: 'default', eager: true });
let PrologInstance;

export const Resolve = () => {

  const [sentence, setSentence] = createSignal("")
  const [unitTests, setUnitTests] = createSignal([])
  const ResultsTable = () => (res2() ? (res2().flatMap(({category, name, status}) => (<><div class="">{category}</div><div class=""> {name}</div><div class="">{status === "pass" ? "✅" :"⛔"}</div></>))) : "");
  
  onMount(async () => {
    await load();
    PrologInstance = new Prolog());
    handleNext();
    //location.reload();
  });

  // The next button does not work
  const handleNext = async () => {
    const [predicates, entries] = [files["./Prolog/predicates.pl"], files["./Prolog/predicates.pl"];
    PrologInstance.fs.open("/english.pl", { write: true, create: true }).writeString(predicates + "\n" + entries.split('\n').sort(() => Math.random() - 0.5).join('\n'));
    await PrologInstance.consult("/english.pl");
    const res = await PrologInstance.queryOnce('english:fill_template(["complete", "the", W1, "in", "a", "sensible", W2])');
    setSentence(`complete the ${res.answer.W1} in a sensible ${res.answer.W2}`);
    await PrologInstance.queryOnce("delete_file('/english.pl')");
  };

  const handleUnitTests = async () => {
    unitTests.fs.open("/UnitTests.pl", { write: true, create: true }).writeString(unit_tests);
    await unitTests.consult("/UnitTests.pl");
    const res = await unitTests.queryOnce('unit_tests:main(Results)');
    setUnitTests(res.answer.Results.map(r => ({ name: r.args[0].functor, status: r.args[1].functor, category: r.args[2].functor})));
  }

  return (
    <div class="border border-fuchsia-800 text-xs w-full py-[2vh] px-[2vw] relative place-items-center bg-fuchsia-50">
      <span class="text-fuchsia-800">RESOLUTIONS</span>
      <div class="flex flex-col hover:cursor-pointer bg-amber-100 gap-y-4">
        <div>QUERY: { query() || "type a query..." }</div>
        <div>{ sentence() || "loading..."}</div>
      </div>
      <div class="hover:cursor-pointer w-[33vw] grid grid-cols-3 text-xs gap-2 place-items-center text-center border bg-white" onclick={handleUnitTests}>
        { 
          unitTests()
          ? ResultsTable
          : "TreallaJs Built-in Predicates & Libraries Unit Test..."
        }
      </div>
      <DictionaryChecker />
      <SvgGen />
      <button class="hover:cursor-pointer" onClick={handleNext}>NEXT</button>
    </div>
  );
};
