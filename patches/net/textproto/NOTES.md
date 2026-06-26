# net/textproto

Interpreted only on wasm (the native bridge is dropped there); off wasm mvm uses
the bridge and never loads this source. net (used by Dial) is a native bridge on
wasm (WasmKeepExact), so upstream textproto.go is used unchanged.

`mimeheader.go` adds the exported `(*Reader).ReadMIMEHeaderLimited`.
mime/multipart reaches the unexported `readMIMEHeader` through a `//go:linkname`,
which mvm does not parse; the exported method replaces that link.
See `patches/mime/multipart/`.
