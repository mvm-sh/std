# net/http (interpreted on wasm)

Mirrored so wasm interprets net/http instead of bridging it (native keeps the
bridge). HTTP/1.1 only:

- mvm sets the `nethttpomithttp2` build tag by default (goparser defaultTags), so
  upstream's `omithttp2.go` (the HTTP/2-omitted stub file, `//go:build
  nethttpomithttp2`) is included and `h2_bundle.go`/`h2_error.go`
  (`//go:build !nethttpomithttp2`) are excluded by their own constraints -- no
  overlay needed.
- `.delete` still removes `h2_bundle.go` (the ~12k-line bundled HTTP/2 stack,
  which also inlines golang.org/x/net/http2/hpack) and `h2_error.go` so they are
  not embedded in src.zip (the build tag would exclude them at load anyway, but
  shipping 12k unused lines bloats the zip).
- `triv.go` is a `//go:build ignore` `package main` demo; dropped explicitly.

The `//go:linkname badRoundTrip`/`badServeHTTP` bodyless decls are kept as-is:
mvm tolerates bodyless funcs and never calls them (they are linkname targets for
external packages).

golang.org/x/net + golang.org/x/text are pulled from source; the wasm binary
embeds a trimmed subset (see stdlib/gen_vendorzip.go).
