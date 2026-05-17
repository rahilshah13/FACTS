// tinygo build -o svg_gen.wasm -target wasm ./svg_gen.go
package main

import (
	"fmt"
	"strings"
	"syscall/js"
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

var continents = []struct {
	name string
	d    string
}{
	{"North America", "M60 80 L220 70 L340 80 L300 120 L380 140 L340 180 L280 180 L240 230 L220 230 L210 190 L170 190 L130 140 L60 120 Z"},
	{"South America", "M240 235 L280 235 L330 270 L340 320 L290 410 L270 430 L260 410 L260 330 L230 270 Z"},
	{"Europe", "M430 80 L520 70 L560 90 L580 130 L550 150 L500 160 L450 160 L410 130 Z"},
	{"Africa", "M410 165 L480 160 L540 180 L570 210 L560 250 L530 320 L500 370 L480 370 L460 300 L420 260 L390 200 Z"},
	{"Asia", "M540 70 L860 65 L900 110 L860 180 L840 230 L780 250 L750 210 L700 240 L640 230 L570 210 L590 140 L550 110 Z"},
	{"Australia", "M760 290 L840 280 L870 320 L840 360 L780 360 L750 320 Z"},
	{"Antarctica", "M40 450 L920 450 L900 470 L60 470 Z"},
}

// 1. Grid Background Layout Fragment
func generateGrid(this js.Value, args []js.Value) any {
	gridSpacing := args[0].Int()
	var buf strings.Builder
	s := svg.New(&buf)
	s.Rect(0, 0, 960, 480, "fill:#e0f2fe")

	for x := gridSpacing; x < 960; x += gridSpacing {
		if x > 32 && x < 928 && x != 480 {
			s.Line(x, 12, x, 468, "stroke:#1e293b;stroke-width:1;stroke-dasharray:2 4")
			deg := (x - 480) * 180 / 480
			lbl := fmt.Sprintf("%d°E", deg)
			if deg < 0 { lbl = fmt.Sprintf("%d°W", -deg) }
			s.Text(x, 476, lbl, "fill:#475569;font-size:9px;font-family:monospace;font-weight:bold;text-anchor:middle")
		}
	}
	for y := gridSpacing; y < 480; y += gridSpacing {
		if y > 24 && y < 456 && y != 240 {
			s.Line(20, y, 940, y, "stroke:#1e293b;stroke-width:1;stroke-dasharray:2 4")
			deg := (240 - y) * 90 / 240
			lbl := fmt.Sprintf("%d°N", deg)
			if deg < 0 { lbl = fmt.Sprintf("%d°S", -deg) }
			s.Text(12, y+3, lbl, "fill:#475569;font-size:9px;font-family:monospace;font-weight:bold;text-anchor:start")
		}
	}

	// Reference Overlays
	s.Line(20, 240, 940, 240, "stroke:#f43f5e;stroke-width:1.2")
	s.Line(480, 12, 480, 468, "stroke:#f59e0b;stroke-width:1.2")
	s.Line(20, 177, 940, 177, "stroke:#94a3b8;stroke-width:1.2;stroke-dasharray:4 4")
	s.Text(25, 236, "Equator (0°)", "fill:#94a3b8;font-size:9px;font-family:monospace;opacity:0.8")
	s.Text(486, 22, "Prime Meridian (0°)", "fill:#94a3b8;font-size:9px;font-family:monospace;opacity:0.8")
	s.Text(25, 173, "Tropic of Cancer (~23.5°N)", "fill:#94a3b8;font-size:9px;font-family:monospace;opacity:0.8")
	return js.ValueOf(buf.String())
}

func generateLandmasses(this js.Value, args []js.Value) any {
	var buf strings.Builder
	s := svg.New(&buf)
	for _, c := range continents {
		s.Path(c.d, "fill:#334155;stroke:#64748b;stroke-width:2;opacity:0.95")
	}
	return js.ValueOf(buf.String())
}

func generateWaves(this js.Value, args []js.Value) any {
	season := args[0].String()
	var buf strings.Builder
	s := svg.New(&buf)

	waveOpacity, waveColor := 0.55, "#38bdf8"
	if season == "Winter" { waveOpacity, waveColor = 0.55*1.0, "#7dd3fc"
	} else if season == "Summer" { waveOpacity, waveColor = 0.55*0.3, "#fde047"
	} else if season == "Autumn" { waveOpacity, waveColor = 0.55*0.7, "#fb923c"
	} else if season == "Spring" { waveOpacity, waveColor = 0.55*0.5, "#4ade80" }

	s.Path("M42 332 C156 286 235 364 351 322 S587 279 722 324 884 350 930 316", fmt.Sprintf("fill:none;stroke:%s;stroke-width:6;opacity:%f", waveColor, waveOpacity))
	s.Path("M48 382 C178 344 249 413 388 373 S596 340 742 382 879 412 932 374", fmt.Sprintf("fill:none;stroke:%s;stroke-width:6;opacity:%f", waveColor, waveOpacity))
	return js.ValueOf(buf.String())
}

func generateOceanCurrents(this js.Value, args []js.Value) any {
	var buf strings.Builder
	s := svg.New(&buf)
	style := "fill:none;stroke:#2563eb;stroke-width:5;opacity:0.45;stroke-linecap:round"
	s.Path("M118 310 l54 -18 l-14 -8 m14 8 l-8 14", style)
	s.Path("M438 295 l62 16 l-14 -8 m14 8 l-8 14", style)
	s.Path("M706 116 l76 -8 l-14 -8 m14 8 l-8 14", style)
	s.Path("M838 334 l-66 20 l-14 -8 m14 8 l-8 14", style)
	return js.ValueOf(buf.String())
}

func generateWind(this js.Value, args []js.Value) any {
	season := args[0].String()
	var buf strings.Builder
	s := svg.New(&buf)

	windModifier := 1.0
	if season == "Winter" { windModifier = 0.9
	} else if season == "Summer" { windModifier = 0.2
	} else if season == "Autumn" { windModifier = 0.6
	} else if season == "Spring" { windModifier = 0.5 }

	style := fmt.Sprintf("fill:none;stroke:#22c55e;stroke-width:4;opacity:%f;stroke-linecap:round", 0.4*windModifier)
	s.Path("M156 92 l92 10 l-13 -9 m13 9 l-10 12", style)
	s.Path("M358 86 l82 24 l-13 -9 m13 9 l-10 12", style)
	s.Path("M565 83 l92 -18 l-13 -9 m13 9 l-10 12", style)
	s.Path("M245 420 l85 -18 l-13 -9 m13 9 l-10 12", style)
	s.Path("M580 423 l100 10 l-13 -9 m13 9 l-10 12", style)
	return js.ValueOf(buf.String())
}

func generateTerritorialBoundaries(this js.Value, args []js.Value) any {
	gridSpacing := args[0].Int()
	var buf strings.Builder
	s := svg.New(&buf)

	ratio := float64(gridSpacing) / 80.0
	strokeW := 1.5
	if 3.5*ratio > strokeW { strokeW = 3.5 * ratio }
	dashA := fmt.Sprintf("%.1f,%.1f", 10.0*ratio, 6.0*ratio)

	for _, c := range continents {
		s.Path(c.d, fmt.Sprintf("fill:none;stroke:#f97316;stroke-width:%f;stroke-dasharray:%s;opacity:0.85", strokeW, dashA))
	}
	return js.ValueOf(buf.String())
}

func main() {
	// Register distinct function handles directly inside JS environment
	js.Global().Set("generateGrid", js.FuncOf(generateGrid))
	js.Global().Set("generateLandmasses", js.FuncOf(generateLandmasses))
	js.Global().Set("generateWaves", js.FuncOf(generateWaves))
	js.Global().Set("generateOceanCurrents", js.FuncOf(generateOceanCurrents))
	js.Global().Set("generateWind", js.FuncOf(generateWind))
	js.Global().Set("generateTerritorialBoundaries", js.FuncOf(generateTerritorialBoundaries))
	js.Global().Set("generateSVG", js.FuncOf(generateSVG))
	select {}
}