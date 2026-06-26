# Sync a curated subset of the Go standard library into this module.
# Run `make update` after upgrading the Go toolchain to refresh sources.
#
# Override GOROOT on the command line to sync from a specific install:
#   make update GOROOT=/path/to/go

GOROOT ?= $(shell go env GOROOT)
GOSRC  := $(GOROOT)/src

all: update

# Stdlib packages mvm interprets from source.
# Native still bridges these (the bridge wins); they are mirrored
# so the wasm floor can interpret dispatchers instead of trapping.
PACKAGES := \
	cmp \
	iter \
	maps \
	slices \
	errors \
	path \
	log \
	log/internal \
	log/slog \
	log/slog/internal \
	log/slog/internal/buffer \
	fmt \
	internal/fmtsort \
	internal/stringslite \
	strconv \
	internal/strconv \
	strings \
	bytes \
	bufio \
	sort \
	unicode \
	unicode/utf8 \
	unicode/utf16 \
	internal/bytealg \
	internal/byteorder \
	internal/godebug \
	io \
	io/fs \
	io/ioutil \
	context \
	internal/oserror \
	internal/saferio \
	internal/singleflight \
	internal/nettrace \
	encoding \
	encoding/ascii85 \
	encoding/csv \
	encoding/json \
	encoding/binary \
	encoding/hex \
	encoding/base32 \
	encoding/base64 \
	encoding/pem \
	encoding/asn1 \
	encoding/gob \
	encoding/xml \
	unique \
	net/netip \
	net/url \
	net/textproto \
	net/mail \
	net/http \
	net/http/internal \
	net/http/internal/ascii \
	net/http/internal/httpcommon \
	net/http/httptrace \
	regexp \
	regexp/syntax \
	text/scanner \
	text/tabwriter \
	html \
	html/template \
	mime \
	mime/quotedprintable \
	mime/multipart \
	internal/gover \
	internal/lazyregexp \
	go/token \
	go/version \
	go/build/constraint \
	go/doc \
	go/doc/comment \
	go/internal/scannerhooks \
	go/scanner \
	go/ast \
	go/parser \
	go/constant \
	go/printer \
	go/format \
	container/heap \
	container/list \
	container/ring \
	index/suffixarray \
	compress/flate \
	compress/gzip \
	compress/zlib \
	compress/bzip2 \
	compress/lzw \
	archive/tar \
	archive/zip \
	flag \
	text/template \
	text/template/parse \
	database/sql \
	database/sql/driver

.PHONY: all update clean info diff-upstream apply-patches LICENSE $(PACKAGES)

update: go.mod info $(PACKAGES) LICENSE
	@echo "synced $(words $(PACKAGES)) packages from $(GOROOT)"

$(PACKAGES):
	@echo "  $@"
	@rm -rf ./$@
	@mkdir -p ./$@
	@cp $(GOSRC)/$@/*.go ./$@/
	@$(MAKE) --no-print-directory apply-patches PKG=$@

apply-patches:
	@if [ -f patches/$(PKG)/.delete ]; then \
	  grep -v '^[[:space:]]*\(#\|$$\)' patches/$(PKG)/.delete | \
	    while read -r f; do rm -f ./$(PKG)/$$f; done; \
	fi
	@if [ -d patches/$(PKG) ]; then \
	  find patches/$(PKG) -maxdepth 1 -name '*.go' -exec cp {} ./$(PKG)/ \; ; \
	fi

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
