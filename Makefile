# Sync a curated subset of the Go standard library into this module.
# Run `make update` after upgrading the Go toolchain to refresh sources.
#
# Override GOROOT on the command line to sync from a specific install:
#   make update GOROOT=/path/to/go

GOROOT ?= $(shell go env GOROOT)
GOSRC  := $(GOROOT)/src

# Curated list of stdlib packages mvm interprets from source. This list
# is deliberately partial -- performance-critical or hard-to-interpret
# packages (fmt, runtime, reflect, sync, time, crypto/* with asm fast
# paths, etc.) stay as native bridges in mvm and are intentionally
# omitted here. Add a package by appending a line and running `make
# update`; remove by deleting both the line and its directory.
# Subdirectories of upstream packages are NOT copied automatically --
# list each one explicitly (e.g. "path" and "path/filepath" as separate
# entries).
PACKAGES := \
	cmp \
	iter \
	maps \
	slices \
	errors \
	path

.PHONY: all update clean info diff-upstream apply-patches LICENSE $(PACKAGES)

all: update

update: go.mod info $(PACKAGES) LICENSE
	@echo "synced $(words $(PACKAGES)) packages from $(GOROOT)"

# Per-package rule: wipe the destination, recreate it, copy top-level
# .go files (including *_test.go so mvm's test runner can exercise them),
# then layer any mvm-specific overrides from patches/<pkg>/. Upstream
# subdirectories such as testdata/ and internal/ are intentionally
# excluded; vendor them explicitly if needed.
$(PACKAGES):
	@echo "  $@"
	@rm -rf ./$@
	@mkdir -p ./$@
	@cp $(GOSRC)/$@/*.go ./$@/
	@$(MAKE) --no-print-directory apply-patches PKG=$@

# Apply patches/$(PKG)/ overlays to ./$(PKG)/. The .delete list runs
# first (so a deleted file can be re-added by an overlay below), then
# every *.go file under patches/$(PKG)/ is copied on top, replacing or
# adding files in the synced tree. NOTES.md and .delete are not copied.
# This step is a no-op for packages without a patches/<pkg>/ directory.
apply-patches:
	@if [ -f patches/$(PKG)/.delete ]; then \
	  grep -v '^[[:space:]]*\(#\|$$\)' patches/$(PKG)/.delete | \
	    while read -r f; do rm -f ./$(PKG)/$$f; done; \
	fi
	@if [ -d patches/$(PKG) ]; then \
	  find patches/$(PKG) -maxdepth 1 -name '*.go' -exec cp {} ./$(PKG)/ \; ; \
	fi

# Show every mvm-specific delta against a fresh upstream sync. Useful
# after `make update` (especially after a Go upgrade) to confirm patches
# still apply meaningfully and no unintended drift slipped in.
diff-upstream:
	@tmp=$$(mktemp -d) ; trap "rm -rf $$tmp" EXIT ; \
	for p in $(PACKAGES); do \
	  mkdir -p $$tmp/$$p ; \
	  cp $(GOSRC)/$$p/*.go $$tmp/$$p/ 2>/dev/null || true ; \
	  diff -ruN $$tmp/$$p ./$$p || true ; \
	done

LICENSE:
	@cp $(GOROOT)/LICENSE ./LICENSE

go.mod:
	@$(GOROOT)/bin/go mod init github.com/mvm-sh/std

info:
	@echo "GOROOT=$(GOROOT)"
	@$(GOROOT)/bin/go version

clean:
	@rm -rf $(PACKAGES) LICENSE
