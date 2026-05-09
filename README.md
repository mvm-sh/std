# std

A curated subset of the Go standard library, re-published as a Go module
so that the [mvm](https://github.com/mvm-sh/mvm) interpreter can load it
through the Go module proxy like any other dependency.

## Why this exists

mvm interprets Go source. For packages that are pure Go (no assembly, no
syscalls, no compiler intrinsics), it is more flexible to interpret the
upstream source than to expose a hand-written native bridge:

- Bridges have to track upstream behavior across Go versions; source
  *is* upstream behavior.
- Source can be fetched lazily and version-pinned without rebuilding mvm.
- The mvm playground (WASM) embeds a frozen snapshot of this module as
  its offline floor and pulls anything else on demand from
  `proxy.golang.org`.

This module is a **deliberately partial mirror**: performance-critical
or hard-to-interpret packages (`fmt`, `runtime`, `reflect`, `sync`,
`time`, `crypto/*` with assembly fast paths, etc.) stay as pre-compiled
native bridges inside mvm and are intentionally not listed here. mvm's
import resolver checks native bindings before consulting any source FS,
so the choice of which packages to publish here is policy, not a
shadowing concern.

## Layout

The `Makefile` copies a curated list of stdlib packages from
`$GOROOT/src` into the repo root, one directory per package. Test files
(`*_test.go`) are kept so mvm's `mvm test <pkg>` runner can exercise
them.

Subdirectories of upstream packages (e.g. `crypto/internal`, `testdata/`)
are not copied. Multi-directory packages have to be added explicitly,
one entry per directory.

## Updating

After installing or upgrading a Go toolchain:

```
make update
```

This refreshes every listed package from `$(go env GOROOT)/src`.
Override `GOROOT` to sync from a specific install:

```
make update GOROOT=/path/to/go
```

Then commit, tag, and push:

```
git add -A
git commit -m "sync from $(go version | awk '{print $3}')"
git tag v0.X.Y
git push --follow-tags
```

Note that `go build ./...` is *not* the right validation here: upstream
packages routinely import `internal/*` (e.g. `errors/wrap.go` pulls
`internal/reflectlite`), which the standard Go toolchain refuses outside
the std tree. The meaningful check is whether mvm can interpret each
package -- run `mvm test github.com/mvm-sh/std/<pkg>` and address the
failures by extending mvm (resolving `internal/*` imports, handling
unsupported syntax, adding missing native bridges) rather than by
mutating the upstream source.

Bump the matching `Version` constant in mvm
(`stdlib/stdmod/stdmod.go`) and regenerate the embedded zip:

```
go generate ./stdlib/...
```

## Adding a package

1. Append the import path to `PACKAGES` in the `Makefile`.
2. `make update`.
3. Run mvm against the package (`mvm test github.com/mvm-sh/std/<pkg>`
   from a directory outside this module, or wire it as a local replace)
   and fix any interpreter bugs the new source exposes.

If a package needs subdirectory contents (e.g. `path/filepath`), add the
subdirectory as its own `Makefile` entry instead of recursing -- this
keeps the imported set explicit and reviewable.

## Patching upstream

Some upstream packages cannot be interpreted by mvm without local
adjustment -- typically because they reach into `internal/race`,
`unsafe`, or `//go:linkname` runtime entry points that mvm has no way
to provide. When a small surgical change to the upstream source is the
cleaner fix than a broad mvm extension, commit a `patches/<pkg>/`
overlay rather than mutating the synced tree by hand (which `make
update` would wipe).

Patching only applies to stdlib packages mirrored into this repo from
`$GOROOT`. Third-party modules fetched via the Go proxy are never
patched -- mvm adapts to those through native bridges or interpreter
fixes.

### Layout

```
patches/
  <pkg>/
    *.go        # full-file overrides; same name overwrites upstream,
                #   new name adds a sibling file
    .delete     # newline-separated relative paths to remove after sync
                #   (lines starting with # and blank lines are ignored)
    NOTES.md    # human rationale; not copied into the package
```

The Makefile applies `.delete` first, then drops the `*.go` overrides
on top. Anything not listed is left as the upstream copy.

### Worked example: `iter`

Upstream `iter/iter.go` (~470 lines in go1.26) defines `Seq`, `Seq2`
and the `Pull`/`Pull2` push-to-pull adapters. The adapters use
linkname'd runtime coroutine primitives (`newcoro`, `coroswitch`) plus
`internal/race` -- none available to mvm.

`patches/iter/` reduces the package to just the type declarations:

- `iter.go` -- 21-line replacement keeping `Seq` and `Seq2`, dropping
  Pull/Pull2 and their imports.
- `.delete` -- removes `pull_test.go`, which exercises only the dropped
  functions and would no longer compile.
- `NOTES.md` -- explains why and what mvm users should do instead
  (range-over-func is interpreted natively, so `for v := range seq`
  works without `iter.Pull`).

### Reviewing drift

After a Go upgrade, run

```
make diff-upstream
```

to see every mvm-specific delta against a fresh upstream sync. Use it
before tagging a new version to confirm patches still mean what they
meant.

## License

The packages here are copies of upstream Go sources and remain under
their original BSD-3-Clause license; see `LICENSE`.
