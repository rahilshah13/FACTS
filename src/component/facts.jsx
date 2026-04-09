import { createResource, createSignal } from "solid-js";
import { UQ, AQ, setUQ, setAQ } from "./ws";
const loadWasm = async () => {return await import("./Scala/target/scala-3.8.3/scalajs-fastopt/main")};
export const [scalaRes, setScalaRes] = createSignal([]);

export const Facts = () => {
  
  const [wasm] = createResource(loadWasm);

  return(
    <div class="flex flex-col border border-emerald-800 px-[2vw] py-[2vh] place-items-center gap-4 bg-emerald-50">
      <span class="place-self-start text-emerald-800 text-xs">FACTS</span>
      <span>time, context?, fact, type, sources</span>
      <span>user queue: {UQ()}</span>
      <span>admin queue: {AQ()}</span>
      <span>scala-wasm: { ( wasm.state === "ready") ? scalaRes() : "nothing" }</span>
      
      <div class="grid grid-cols-3 items-stretch w-full text-center text-white">
        <div class="bg-indigo-200 hover:bg-black border border-black">upload</div>
        <div class="bg-red-200 hover:bg-black border border-black">record</div>
        <div class=" bg-slate-200 hover:bg-black border border-black">pipe</div>
      </div>
    </div>
  );
}