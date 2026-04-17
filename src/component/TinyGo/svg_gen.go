// tinygo build -o svg_gen.wasm -target wasm ./svg_gen.go
package main

import (
	"strings"
	"syscall/js"
	"fmt"
	"github.com/ajstarks/svgo"
)

func generateSVG(this js.Value, args []js.Value) any {
	var buf strings.Builder
	s := svg.New(&buf)
	s.Start(500, 500)
	for x := 0; x < 500; x += 25 {
		for y := 0; y < 500; y += 25 {
			s.Rect(x, y, 23, 23, fmt.Sprintf("fill:rgb(%d,100,%d)", x/2, y/2))
		}
	}
	s.End()
	return js.ValueOf(buf.String())
}

func main() {
	js.Global().Set("generateSVG", js.FuncOf(generateSVG))
	select {}
}