# net/mail

Interpreted only on wasm (the native bridge is dropped under the `net` WasmDrop
prefix); off wasm mvm uses the bridge and never loads this source.

`message.go` is a full-file overlay differing from upstream by two lines: the
`net` import becomes `net/netip`, and the domain-literal IP check
`net.ParseIP(dtext) == nil` becomes `netip.ParseAddr(dtext)` erroring or
carrying a zone. wasm has no `net` bridge, and modern `net.ParseIP` is exactly
`netip.ParseAddr` minus zones, so behavior is unchanged. net/netip is mirrored.

On a Go upgrade re-check this file against upstream message.go (`make
diff-upstream`); only those two lines should differ.
