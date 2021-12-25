/' right$ function '/

#include "fb.bi"
#include "destruct_string.bi"

extern "C"
function fb_RIGHT FBCALL ( src as FBSTRING ptr, chars as ssize_t, result as FBSTRING ptr ) as FBSTRING ptr
	dim as destructable_string dst
	dim as ssize_t _len, src_len

	DBG_ASSERT( result <> NULL )

	if ( src <> NULL ) then
		src_len = FB_STRSIZE( src )
		if ( (src->data <> NULL) andalso (chars > 0) andalso (src_len > 0) ) then
			if ( chars > src_len ) then
				_len = src_len
			else
				_len = chars
			end if
		
			if ( fb_hStrAlloc( @dst, _len ) <> NULL ) then
				/' simple rev copy '/
				fb_hStrCopy( dst.data, src->data + src_len - _len, _len )
			end if
		end if
	end if

	fb_StrSwapDesc( @dst, result )
	return result
end function
end extern