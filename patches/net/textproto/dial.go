// Copyright 2010 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

//go:build !wasm

// Dial lives in its own file so the wasm build of the mirror, which has no net
// bridge, can interpret the rest of textproto. mvm uses the native bridge off
// wasm, so this only matters when textproto is interpreted via MVM_INTERP.
package textproto

import "net"

// Dial connects to the given address on the given network using [net.Dial]
// and then returns a new [Conn] for the connection.
func Dial(network, addr string) (*Conn, error) {
	c, err := net.Dial(network, addr)
	if err != nil {
		return nil, err
	}
	return NewConn(c), nil
}
