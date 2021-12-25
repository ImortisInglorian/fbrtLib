/' trim$ function '/

#include "fb.bi"
#include "destruct_string.bi"

extern "C"
function fb_TRIM FBCALL ( src as FBSTRING ptr, result as FBSTRING ptr ) as FBSTRING ptr
	dim as destructable_string dst
	dim as ssize_t _len = 0
	dim as ubyte ptr src_ptr

	DBG_ASSERT( result <> NULL )

	if ( src <> NULL andalso src->data <> NULL ) then
		_len = FB_STRSIZE( src )
		if ( _len > 0 ) then
			src_ptr = fb_hStrSkipCharRev( src->data, _len, 32 )
			_len = cast(ssize_t, (src_ptr - src->data) + 1)
		end if
	end if

	if ( _len > 0 ) then
		src_ptr = fb_hStrSkipChar( src->data, FB_STRSIZE( src ), 32 )
		_len -= cast(ssize_t, (src_ptr - src->data))
		if ( _len > 0 ) then
			if ( fb_hStrAlloc( @dst, _len ) <> NULL ) then
				/' simple copy '/
				fb_hStrCopy( dst.data, src_ptr, _len )
			end if
		end if
	end if

	fb_StrSwapDesc( @dst, result )
	return result
end function
end extern