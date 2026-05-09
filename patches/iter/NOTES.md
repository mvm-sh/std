# iter — mvm patch notes

## Why this is patched

Upstream `iter/iter.go` (~470 lines in go1.26) defines four exported
symbols: the `Seq` and `Seq2` iterator types, and the `Pull` and
`Pull2` push-to-pull adapters. The two adapters are unimplementable
under mvm: they drive coroutines through compiler-linked runtime
primitives accessed via

```go
//go:linkname newcoro
//go:linkname coroswitch
```

and use `internal/race` plus `unsafe` for race annotations. mvm cannot
provide the linkname targets (those entry points live inside the Go
runtime, which mvm doesn't run) and `internal/race` is forbidden across
module boundaries.

Patching upstream is the right call here — extending mvm to fake
coroutines would be substantial and serve only this one API.

## What the overlay does

- **`iter.go`** (this directory) replaces upstream's `iter.go`. It
  keeps the package doc, the copyright, and the `Seq`/`Seq2` type
  declarations. Pull/Pull2 and their supporting state machinery are
  dropped along with the `internal/race`, `runtime`, and `unsafe`
  imports.
- **`.delete`** removes upstream's `pull_test.go`, which exercises
  Pull/Pull2 exclusively and would no longer compile.

## What mvm users do instead

`for v := range seq` is interpreted natively (range-over-func is
handled by the compiler/interpreter, not by `iter.Pull`). Code that
needs explicit pull semantics can write a small adapter without
coroutines, but the common case — wanting to consume an iterator in a
loop — works unchanged.

## When to revisit

If mvm ever virtualizes the runtime coroutine entry points
(`newcoro`/`coroswitch`) the Pull/Pull2 implementations could be
re-enabled with light tweaks. Until then this patch stays.
