/' LSET for non-strings '/

#include "fb.bi"

extern "C"
sub  fb_MemCopyClear FBCALL ( dst as ubyte ptr, dstlen as ssize_t, src as ubyte ptr, srclen as ssize_t )
	dim as ssize_t bytes

	if ( (dst = NULL) or (src = NULL) or (dstlen <= 0) or (srclen <= 0) ) then
		exit sub
	end if

	bytes = iif(dstlen <= srclen, dstlen, srclen)
	
	/' move '/
	memcpy( dst, src, bytes )

	/' clear remainder '/
	dstlen -= bytes
	if ( dstlen > 0 ) then
		memset( @dst[bytes], 0, dstlen )
	end if
end sub
end extern