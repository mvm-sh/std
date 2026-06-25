// Package godebug reads GODEBUG settings.
//
// mvm patch: upstream wires into internal/bisect, internal/godebugs, and runtime
// linknames to observe live GODEBUG changes. The interpreter has none of that;
// this overlay reports every setting as unset (""), i.e. the toolchain default,
// which is the correct behavior for the packages that consult it.
package godebug

type Setting struct{ name string }

func New(name string) *Setting { return &Setting{name} }

func (s *Setting) Name() string { return s.name }

func (s *Setting) Undocumented() bool { return len(s.name) > 0 && s.name[0] == '#' }

func (s *Setting) String() string { return "Setting(" + s.name + ")" }

func (s *Setting) IncNonDefault() {}

func (s *Setting) Value() string { return "" }
