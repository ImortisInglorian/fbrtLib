/' rtrim$ ANY function '/

#include "fb.bi"
#include "destruct_string.bi"

extern "C"
function fb_RTrimAny FBCALL ( src as FBSTRING ptr, pattern as FBSTRING ptr, result as FBSTRING ptr ) as FBSTRING ptr
	dim as destructable_string dst
	dim as ssize_t _len = 0

	DBG_ASSERT( result <> NULL )

	if ( src <> NULL andalso src->data <> NULL ) then
		dim as ubyte ptr pachText = src->data
		dim as ssize_t len_pattern = iif((pattern <> NULL) andalso (pattern->data <> NULL), FB_STRSIZE( pattern ), 0)
		_len = FB_STRSIZE( src )
		if ( len_pattern <> 0 ) then
			while ( _len <> 0 )
				_len -= 1
				if ( FB_MEMCHR( pattern->data, pachText[_len], len_pattern ) = NULL ) then
					_len += 1
					exit while
				end if
			wend
		end if
	end if

	if ( _len > 0 ) then
		if ( fb_hStrAlloc( @dst, _len ) <> NULL ) then
			/' simple copy '/
			fb_hStrCopy( dst.data, src->data, _len )
		end if
	end if

	fb_StrSwapDesc( @dst, result )
	return result
end function
end extern