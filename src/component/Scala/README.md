## sbt project compiled with Scala 3
- `sbt compile`, `sbt run`
- `sbt fastLinkJs`
- [scala3-example-project](https://github.com/scala/scala3-example-project/blob/main/README.md).
- "TODO: sbt plugin to 'patch' main.js"
```
// main.js
import { load as __load } from "./__loader.js";
import { scalaRes, setScalaRes } from "../../../../facts.jsx";

(await __load("./main.wasm", ({}), ({}), ({}), ({
  "0": ((x) => x.toString(16)),
  "1": (() => Object.prototype),
  "2": ((x) => x.toString),
  "3": ((x, x1) => x.call(x1)),
  "4": (() => Error.captureStackTrace),
  "5": ((x) => Object.isSealed(x)),
  "6": (() => new Error()),
  "7": ((x) => Error.captureStackTrace(x)),
  "8": ((x) => x.indexOf("\n")),
  "9": (() => (typeof console)),
  "10": (() => console.error),
  "11": ((x) => (!x)),
  "12": ((x) => (!x)),
  "13": ((x) => console.error(x)),
  "14": (x) => {
    const msg = String(x);
    if (msg.startsWith("RESULT:")) {
      setScalaRes(results => [...results, msg.replace("RESULT:", "")]);
    } else {
      console.log(msg);
    }
  },
}), ({})));
```