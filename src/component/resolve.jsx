import { createSignal, onMount, For, createResource } from "solid-js";
import { load, Prolog } from 'trealla';
import { query, setQuery } from "./query";
import { DictionaryChecker, SvgGen } from "./utility";

const files = import.meta.glob("./Prolog/*.pl", { query: '?raw', import: 'default', eager: true });
let PL;

export const Resolve = () => {

  const [sentence, setSentence] = createSignal("")
  const [unitTests, setUnitTests] = createSignal("")
  
  onMount(async () => {
    await load();
    PL = new Prolog();
    handleNext();
    //location.reload();
  });

  // The next button does not work
  const handleNext = async () => {
    const [predicates, dictionary] = [files["./Prolog/predicates.pl"], files["./Prolog/words.pl"]];
    PL.fs.open("/english.pl", { write: true, create: true }).writeString(predicates + "\n" + dictionary.split('\n').sort(() => Math.random() - 0.5).join('\n'));
    await PL.consult("/english.pl");
    const res = await PL.queryOnce('english:fill_template(["complete", "the", W1, "in", "a", "sensible", W2])');
    setSentence(`complete the ${res.answer.W1} in a sensible ${res.answer.W2}`);
    await PL.queryOnce("delete_file('/english.pl')");
  };

  const handleUnitTests = async () => {
    PL.fs.open("/UnitTests.pl", { write: true, create: true }).writeString(files["./Prolog/UnitTests.pl"]);
    await PL.consult("/UnitTests.pl");
    const res = await PL.queryOnce('unit_tests:main(Results)');
    setUnitTests(res.answer.Results.map(r => ({ name: r.args[0].functor, status: r.args[1].functor, category: r.args[2].functor})));
    await PL.queryOnce("delete_file('/UnitTests.pl')");
  }

  return (
    <div class="border border-fuchsia-800 text-xs w-full py-[2vh] px-[2vw] relative place-items-center bg-fuchsia-50">
      <span class="text-fuchsia-800">RESOLUTIONS</span>
      <div class="flex flex-col hover:cursor-pointer bg-amber-100">
        <div>QUERY: { query() || "type a query..." }</div>
        <div>{ sentence() || "loading..."}</div>
      </div>

      <div class="hover:cursor-pointer w-[33vw] grid grid-cols-3 text-xs gap-2 place-items-center text-center border bg-white my-[2vh] flex-row" onclick={handleUnitTests}>
        { 
          unitTests()
          ? (() => (unitTests().flatMap(({category, name, status}) => (<><div class="">{category}</div><div class=""> {name}</div><div class="">{status === "pass" ? "✅" :"⛔"}</div></>))))
          : <div class="grid col-span-3">Click Here To Run Trealla-JS Unit Tests</div>
        }
      </div>

      <SvgGen />
      <button class="hover:cursor-pointer place-self-start" onClick={handleNext}>NEXT</button>
    </div>
  );
};
