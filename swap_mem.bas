/' swap for non-strings '/

#include "fb.bi"

extern "C"
sub fb_MemSwap FBCALL ( dst as ubyte ptr, src as ubyte ptr, bytes as ssize_t )
	dim as ssize_t i
	dim as ulong ti
	dim as ubyte tb

	if ( (dst = NULL) orelse (src = NULL) orelse (bytes <= 0) ) then
		exit sub
	end if

	FB_LOCK()
	
	/' words '/
	for i = 0 to (bytes shr 2) - 1
		ti = *cast(ulong ptr, src)
		*cast(ulong ptr, src) = *cast(ulong ptr, dst)
		*cast(ulong ptr, dst) = ti

		src += sizeof(ulong)
		dst += sizeof(ulong)
	next

	/' remainder '/
	for i = 0 to (bytes and 3) - 1
		tb = *src
		*src = *dst
		src += 1
		*dst = tb
		dst += 1
	next
	
	FB_UNLOCK()
end sub
end extern