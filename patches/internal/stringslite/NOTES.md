# internal/stringslite patch

Upstream `Index`/`IndexByte` use `internal/bytealg` (asm + linkname constants),
which can't be bridged or interpreted on the wasm floor -- the first blocker when
interpreting `fmt`.
This overlay rewrites them as plain-Go loops, dropping the `bytealg` import.
Same exported API; `fmt` needs correctness, not bytealg's speed.
