// tinygo build -o translation_checker.wasm -target wasm ./translation_checker.go
package main

import (
	"strings"
	"syscall/js"
	"unicode"
)

// Mapping the 47 languages to their Unicode Script Tables
var scriptMap = map[string]*unicode.RangeTable{
	// 1. Latin (Covers: Spanish, French, Portuguese, Indonesian, German, Nigerian Pidgin, 
	// Turkish, Vietnamese, Tagalog, Hausa, Swahili, Javanese, Italian, Sundanese, 
	// Polish, Uzbek (Latin), Azerbaijani, Romanian)
	"Latin":      unicode.Latin,      
	// 2. Ethiopic (Covers: Amharic, Oromo)
	"Ethiopic":   unicode.Ethiopic,   
	// 3. Han (Covers: Mandarin, Yue, Wu, Hakka Chinese, Japanese Kanji)
	"Han":        unicode.Han,        
	// 4. Devanagari (Covers: Hindi, Marathi, Bhojpuri, Maithili)
	"Devanagari": unicode.Devanagari, 
	// 5. Arabic (Covers: Arabic, Urdu, Iranian Persian, Pashto, Sindhi, Western Punjabi (Shahmukhi))
	"Arabic":     unicode.Arabic,     
	// 6. Bengali (Covers: Bengali)
	"Bengali":    unicode.Bengali,    
	// 7. Cyrillic (Covers: Russian, Ukrainian, Uzbek (Cyrillic))
	"Cyrillic":   unicode.Cyrillic,   
	// 8. South & SE Asian Specifics
	"Telugu":     unicode.Telugu,     // Telugu
	"Tamil":      unicode.Tamil,      // Tamil
	"Kannada":    unicode.Kannada,    // Kannada
	"Gujarati":   unicode.Gujarati,   // Gujarati
	"Malayalam":  unicode.Malayalam,  // Malayalam
	"Thai":       unicode.Thai,       // Thai
	"Myanmar":    unicode.Myanmar,    // Burmese
	"Gurmukhi":   unicode.Gurmukhi,   // Western Punjabi (Gurmukhi variant)
	// 9. East Asian Specifics
	"Hangul":     unicode.Hangul,     // Korean
	"Hiragana":   unicode.Hiragana,   // Japanese
	"Katakana":   unicode.Katakana,   // Japanese
}
func detect(text string) string {
	counts := make(map[string]int)
	for _, r := range text {
		found := false
		for name, table := range scriptMap {
			if unicode.Is(table, r) {
				counts[name]++
				found = true
				break
			}
		}
		if !found && (unicode.Is(unicode.Latin, r) || unicode.IsDigit(r)) {
			counts["Latin/Common"]++
		}
	}
	
	best, max := "Unknown", 0
	for name, count := range counts {
		if count > max {
			best, max = name, count
		}
	}
	return best
}

func processDictionary(this js.Value, args []js.Value) any {
	if len(args) < 2 { return nil }
	var res []any
	for _, line := range strings.Split(args[1].String(), "\n") {
		if !strings.HasPrefix(line, "entry(") { continue }
		p := strings.Split(line, "\"")
		if len(p) < 2 { continue }
		
		res = append(res, map[string]any{
			"word":       strings.Split(line[6:], ",")[0],
			"lang":       detect(p[1]),
			"confidence": 1.0,
		})
	}
	return res
}

func main() {
	js.Global().Set("processDictionary", js.FuncOf(processDictionary))
	select {}
}