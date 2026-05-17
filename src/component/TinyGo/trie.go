package main

import (
	"regexp"
	"strings"
	"syscall/js"

	"github.com/derekparker/trie"
)

var wordTrie *trie.Trie

func parsePrologAndIndex(prologData string) {
	wordTrie = trie.New()

	re := regexp.MustCompile(`entry\s*\(\s*([a-zA-Z]+)\s*,`)
	matches := re.FindAllStringSubmatch(prologData, -1)

	for _, match := range matches {
		if len(match) < 2 {
			continue
		}
		word := strings.ToLower(match[1])

		for i := 0; i < len(word); i++ {
			suffix := word[i:]
			
			var existingWords []string
			// FIXED: Call Meta() as a method to get the interface value
			if node, found := wordTrie.Find(suffix); found && node.Meta() != nil {
				existingWords = node.Meta().([]string)
			}
			
			if !contains(existingWords, word) {
				wordTrie.Add(suffix, append(existingWords, word))
			}
		}
	}
}

func contains(slice []string, item string) bool {
	for _, s := range slice {
		if s == item {
			return true
		}
	}
	return false
}

func matchSubstring(this js.Value, args []js.Value) any {
	if len(args) < 1 {
		return js.ValueOf([]any{})
	}

	query := strings.ToLower(args[0].String())
	if query == "" {
		return js.ValueOf([]any{})
	}

	keys := wordTrie.PrefixSearch(query)
	
	resultSet := make(map[string]bool)
	for _, key := range keys {
		// FIXED: Call Meta() as a method here as well
		if node, found := wordTrie.Find(key); found && node.Meta() != nil {
			words := node.Meta().([]string)
			for _, w := range words {
				resultSet[w] = true
			}
		}
	}

	jsResults := make([]any, 0, len(resultSet))
	for w := range resultSet {
		jsResults = append(jsResults, w)
	}

	return js.ValueOf(jsResults)
}

func initDictionary(this js.Value, args []js.Value) any {
	if len(args) > 0 {
		parsePrologAndIndex(args[0].String())
	}
	return nil
}

func main() {
	js.Global().Set("initDictionary", js.FuncOf(initDictionary))
	js.Global().Set("matchSubstring", js.FuncOf(matchSubstring))

	select {}
}