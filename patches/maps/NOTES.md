# maps — mvm patch notes

## Why this is patched

Upstream `maps/maps.go` implements `Clone` by delegating to an
unexported helper that is `//go:linkname`'d to a runtime intrinsic:

```go
//go:linkname clone maps.clone
func clone(m any) any
```

`maps.clone` lives in the Go runtime, which mvm does not run, so mvm
cannot provide the linkname target. With the bodiless `clone` left as
is, `Clone` returns nil and panics. This affects general use (any
`maps.Clone` call under `mvm run`), not just tests.

## What the overlay does

- **`maps.go`** (this directory) replaces upstream's `maps.go`. It drops
  the `//go:linkname clone` declaration and inlines an equivalent
  portable generic range-copy in `Clone`:

  ```go
  r := make(M, len(m))
  for k, v := range m {
      r[k] = v
  }
  return r
  ```

  Semantically identical (a shallow copy via ordinary assignment), just
  without the runtime fast path. Everything else is unchanged.

## When to revisit

If mvm ever virtualizes the runtime intrinsic entry points, the upstream
`clone` delegation could be restored. Until then this patch stays.
