# net/textproto

Interpreted only on wasm (the native bridge is dropped there); off wasm mvm uses
the bridge and never loads this source.

`textproto.go` drops the `net` import and the `Dial` function, because wasm has
no net bridge to resolve `net.Dial`.
`dial.go` restores `Dial` under `//go:build !wasm` so a non-wasm interpretation
(via MVM_INTERP) stays complete.

`mimeheader.go` adds the exported `(*Reader).ReadMIMEHeaderLimited`.
mime/multipart reaches the unexported `readMIMEHeader` through a `//go:linkname`,
which mvm does not parse; the exported method replaces that link.
See `patches/mime/multipart/`.
