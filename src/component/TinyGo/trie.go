func main() {
	js.Global().Set("processDictionary", js.FuncOf(processDictionary))
	select {}
}