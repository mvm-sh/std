# index/suffixarray

Interpreted on wasm (the native bridge is dropped via WasmDropExact); off wasm
mvm uses the bridge.

`gen.go` is removed via `.delete`: it is a `//go:build ignore` command
(`package main`) that regenerates `sais2.go` from `sais.go`, not part of the
library.
