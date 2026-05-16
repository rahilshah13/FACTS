import { createSignal, createMemo, createResource, For, useContext, createEffect } from "solid-js"; 
import { Query } from "./component/query";
import { Facts } from "./component/facts"
import { StaticElements } from "./component/static";
import { Resolve } from "./component/resolve";
import { WorldMap } from "./component/world";

export const [toggleMap, setToggleMap] = createSignal(false);

const App = () => {
  const [facts, setFacts] = createSignal(0);
  const [storageMeter, setStorageMeter] = createResource({});
  const [modal, setModal] = createResource({});
  // -->[{ X: {"label": "", "pcs": ""} }, {Y: { "price" : 0, "budget": 0 }}, { T: { "duration": "", "rate": ""}}]
  // const GENERATOR(QUERY, FACTS) = createMemo(() => JSON.parse(localStorage.getItem("prolog_benchmarks") || "[]"), []);

  return (
    <div class="w-screen py-[8vh] px-[2vw] static scroll-auto flex flex-col text-xs gap-4">
      <StaticElements />
      {/* <span class="text-[10px]">CONTAINER(w: 100vw, h: 77vh, px: 2vw, py: 2vh)</span> */}
      <Query P />
      <Facts />
      { toggleMap() ? <WorldMap/> : <Resolve /> }
    </div>
  );

};

export default App;