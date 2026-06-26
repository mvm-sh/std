# go/doc

Interpreted on wasm (the native bridge is dropped under the `go` WasmDrop
prefix); off wasm mvm uses the bridge.

`headscan.go` is removed via `.delete`: it is a `//go:build ignore` command
(`package main`) that self-imports `go/doc`, used only to tune comment
heuristics. It is not part of the library.

Depends on `internal/lazyregexp` (mirrored).
