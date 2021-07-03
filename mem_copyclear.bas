/' LSET for non-strings '/

#include "fb.bi"

extern "C"
sub  fb_MemCopyClear FBCALL ( dst as ubyte ptr, dstlen as size_t, src as ubyte ptr, srclen as size_t )
	dim as size_t bytes

	if ( (dst = NULL) or (src = NULL) or (dstlen = 0) ) then
		exit sub
	end if

	bytes = iif(dstlen <= srclen, dstlen, srclen)
	
	/' move '/
	if( bytes > 0 ) then
		memcpy( dst, src, bytes )
	end if

	/' clear remainder '/
	dstlen -= bytes
	if ( dstlen > 0 ) then
		memset( @dst[bytes], 0, dstlen )
	end if
end sub
end extern
