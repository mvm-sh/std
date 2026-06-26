# mime/multipart

Interpreted only on wasm (the native bridge is dropped there); off wasm mvm uses
the bridge and never loads this source.

`readmimeheader.go` replaces upstream's `//go:linkname` to the unexported
`net/textproto.readMIMEHeader` (mvm does not parse linkname) with a call to the
exported `(*textproto.Reader).ReadMIMEHeaderLimited` shim, preserving the size
limits. See `patches/net/textproto/`.
