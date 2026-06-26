// Copyright 2023 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package textproto

// ReadMIMEHeaderLimited reads a MIME header with explicit limits on the total
// header size and count. Upstream exposes this to mime/multipart through a
// //go:linkname on the unexported readMIMEHeader, which mvm does not parse;
// the exported method lets the interpreted multipart call it directly.
func (r *Reader) ReadMIMEHeaderLimited(maxMemory, maxHeaders int64) (MIMEHeader, error) {
	return readMIMEHeader(r, maxMemory, maxHeaders)
}
