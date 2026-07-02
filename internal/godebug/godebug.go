// Package godebug reads GODEBUG settings.
//
// mvm patch: upstream wires into internal/bisect, internal/godebugs, and runtime
// linknames to observe live GODEBUG changes. The interpreter has none of that;
// this overlay reads the GODEBUG env on each Value() call. A setting absent from
// GODEBUG reports "" (the toolchain default the consumer then applies); a present
// one reports its value, including changes made at runtime via os.Setenv.
package godebug

import (
	"os"
	"strings"
)

type Setting struct{ name string }

func New(name string) *Setting { return &Setting{name} }

func (s *Setting) Name() string { return s.name }

func (s *Setting) Undocumented() bool { return len(s.name) > 0 && s.name[0] == '#' }

func (s *Setting) String() string { return "Setting(" + s.name + ")" }

func (s *Setting) IncNonDefault() {}

// Value returns s's setting from GODEBUG, or "" if absent. GODEBUG is a
// comma-separated list of name=value; the last entry for a name wins.
func (s *Setting) Value() string {
	val := ""
	for _, kv := range strings.Split(os.Getenv("GODEBUG"), ",") {
		if k, v, ok := strings.Cut(kv, "="); ok && k == s.name {
			val = v
		}
	}
	return val
}
