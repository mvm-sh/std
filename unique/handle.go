// Package unique provides facilities for canonicalizing ("interning") values.
//
// mvm patch: upstream interns via internal/abi type maps, weak pointers, and a
// runtime cleanup queue, none interpretable on the wasm floor. This overlay is a
// plain map-based interner: correct Handle equality and Value, but it never frees
// (no weak/GC). Enough for callers like net/netip that intern small string sets.
package unique

import "sync"

// Handle is a globally unique identity for some value of type T.
type Handle[T comparable] struct {
	value *T
}

// Value returns a shallow copy of the T value that produced the Handle.
func (h Handle[T]) Value() T { return *h.value }

var (
	mu    sync.Mutex
	canon = map[any]any{} // T value (boxed) -> *T (boxed)
)

// Make returns a globally unique handle for a value of type T. Handles are equal
// iff the values used to produce them are equal.
func Make[T comparable](value T) Handle[T] {
	mu.Lock()
	defer mu.Unlock()
	if p, ok := canon[value]; ok {
		return Handle[T]{p.(*T)}
	}
	p := new(T)
	*p = value
	canon[value] = p
	return Handle[T]{p}
}
