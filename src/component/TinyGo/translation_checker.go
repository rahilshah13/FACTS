// tinygo build -o translation_checker.wasm -target wasm ./translation_checker.go
package main

import (
	"strings"
	"syscall/js"
	"unicode"
)

func detect(text string) (best string) {
	counts, max := make(map[string]int), 0
	best = "Unknown"
	for _, r := range text {
		for name, table := range unicode.Scripts {
			if unicode.Is(table, r) {
				if counts[name]++; counts[name] > max { best, max = name, counts[name] }
				break
			}
		}
	}
	return
}

func main() {
	js.Global().Set("processDictionary", js.FuncOf(func(_ js.Value, args []js.Value) any {
		if len(args) < 2 { return nil }
		res := []any{}
		for _, l := range strings.Split(args[1].String(), "\n") {
			if p := strings.Split(l, "\""); strings.HasPrefix(l, "entry(") && len(p) > 1 {
				res = append(res, map[string]any{"word": strings.Split(l[6:], ",")[0], "lang": detect(p[1]), "confidence": 1.0})
			}
		}
		return res
	}))
	select {}
}