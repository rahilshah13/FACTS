import { createSignal, onMount, For, createResource } from "solid-js";
import { load, Prolog } from 'trealla';
import { query, setQuery } from "./query";
import predicates from "./prolog/predicates.pl?raw";
import entries from "./prolog/words.pl?raw";
import unit_tests from "./prolog/unit_test.pl?raw";

let english;
let unitTests;

export const Resolve = () => {

  const [res1, setRes1] = createSignal("")
  const [res2, setRes2] = createSignal("")
  const unitTestResultTable = () => (res2() ? (res2().flatMap(({category, name, status}) => (<><div class="">{category}</div><div class=""> {name}</div><div class="">{status === "pass" ? "✅" :"⛔"}</div></>))) : "");
   
  onMount(async () => {
    await load();
    english = new Prolog();
    unitTests = new Prolog();
    handleNext();
    //location.reload();
  });

  // The next button does not work
  const handleNext = async () => {
    english.fs.open("/english.pl", { write: true, create: true }).writeString(predicates + "\n" + entries.split('\n').sort(() => Math.random() - 0.5).join('\n'));
    await english.consult("/english.pl");
    const res = await english.queryOnce('english:fill_template(["complete", "the", W1, "in", "a", "sensible", W2])');
    setRes1(`complete the ${res.answer.W1} in a sensible ${res.answer.W2}`);
    // await pl.queryOnce("delete_file('/english.pl')");
  };

  const handleBuiltinsUnitTest = async () => {
    unitTests.fs.open("/unit_tests.pl", { write: true, create: true }).writeString(unit_tests);
    await unitTests.consult("/unit_tests.pl");
    const res = await unitTests.queryOnce('unit_test:main(Results)');
    const formattedRes = res.answer.Results.map(r => ({ name: r.args[0].functor, status: r.args[1].functor, category: r.args[2].functor}));
    setRes2(formattedRes);
  }

  return (
    <div class="border border-fuchsia-800 text-xs w-full py-[2vh] px-[2vw] relative place-items-center bg-fuchsia-50">
      <span class="text-fuchsia-800">RESOLUTIONS</span>
      <div class="flex flex-col hover:cursor-pointer bg-amber-100">
        <div>QUERY: {query() || "empty"}</div>
        <div>{ res1() || "loading..."}</div>
      </div>
      <div class="hover:cursor-pointer w-[20vw] grid grid-cols-3 text-xs gap-2 place-items-center text-center border bg-white" onclick={handleBuiltinsUnitTest}>
        { 
          res2()
          ? unitTestResultTable
          : "Built-ins Unit Test..."
        }
      </div>
      <button class="hover:cursor-pointer" onClick={handleNext}>NEXT</button>
    </div>
  );
};