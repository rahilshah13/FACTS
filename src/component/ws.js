import { createSignal, createResource } from "solid-js";

const AUDIT_LOG = ""
export const [connected, setConnected] = createSignal(false);
export const [UQ, setUQ] = createSignal(["hiiii"]);
export const [AQ, setAQ] = createSignal(["hiiiiiiiii"]);

async function streamFacts() {
  console.log("STREAM FACTS!");
  return {hi: "hi"};
};

export const [facts, { refetch: rf, mutate: mf }] = createResource(streamFacts, { initialValue: {hi: "ddd"}, name: "facts", onHydrated: () => {},});

