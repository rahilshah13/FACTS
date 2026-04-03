// tinygo build -o svg_gen.wasm -target wasm ./svg_gen.go
package main

import (
	"strings"
	"syscall/js"
	"github.com/ajstarks/svgo"
)

func generateSVG(this js.Value, args []js.Value) any {
	var buf strings.Builder
	s := svg.New(&buf)
	s.Start(500, 500)
	s.Circle(250, 250, 125, "fill:none;stroke:black")
	s.End()
	return js.ValueOf(buf.String())
}

func main() {
	js.Global().Set("generateSVG", js.FuncOf(generateSVG))
	select {}
}