/' ltrim$ function '/

#include "fb.bi"
#include "destruct_string.bi"

extern "C"
function fb_LTRIM FBCALL ( src as FBSTRING ptr, result as FBSTRING ptr ) as FBSTRING ptr
	dim as destructable_string dst
	dim as ssize_t _len
	dim as ubyte ptr src_ptr = NULL

	DBG_ASSERT( result <> NULL )

	if ( src <> NULL andalso src->data <> NULL) then
		src_ptr = fb_hStrSkipChar( src->data, FB_STRSIZE( src ), asc(" ") )
		_len = FB_STRSIZE( src ) - cast(ssize_t, (src_ptr - src->data))

		if ( _len > 0 andalso fb_hStrAlloc( @dst, _len ) <> NULL ) then
			/' simple copy '/
			fb_hStrCopy( dst.data, src_ptr, _len )
		end if
	end if

	fb_StrSwapDesc( @dst, result )
	return result
end function
end extern