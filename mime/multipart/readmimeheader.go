// Copyright 2023 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package multipart

import "net/textproto"

// readMIMEHeader calls into net/textproto. Upstream links the unexported
// textproto.readMIMEHeader via //go:linkname, which mvm does not parse, so this
// uses the exported ReadMIMEHeaderLimited shim instead. See patches/net/textproto/.
func readMIMEHeader(r *textproto.Reader, maxMemory, maxHeaders int64) (textproto.MIMEHeader, error) {
	return r.ReadMIMEHeaderLimited(maxMemory, maxHeaders)
}
