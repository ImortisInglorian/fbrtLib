/' mid$ function '/

#include "fb.bi"
#include "destruct_string.bi"

extern "C"
function fb_StrMid FBCALL ( src as FBSTRING ptr, start as ssize_t, _len as ssize_t, result as FBSTRING ptr ) as FBSTRING ptr
	dim as destructable_string dst
	dim as ssize_t src_len

	DBG_ASSERT( result <> NULL )

	if ( (src <> NULL) andalso (src->data <> NULL) andalso (FB_STRSIZE( src ) > 0) ) then
		src_len = FB_STRSIZE( src )

		if ( (start > 0) andalso (start <= src_len) andalso (_len <> 0) ) then
			start -= 1

			if ( _len < 0 ) then
				_len = src_len
			end if

			if ( start + _len > src_len ) then
				_len = src_len - start
			end if

			if ( fb_hStrAlloc( @dst, _len ) <> NULL ) then
				FB_MEMCPY( dst.data, src->data + start, _len )
				/' null term '/
				dst.data[_len] = 0
			end if
		end if
	end if

	fb_StrSwapDesc( @dst, result )
	return result
end function
end extern