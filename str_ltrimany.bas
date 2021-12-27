/' ltrim$ ANY function '/

#include "fb.bi"
#include "destruct_string.bi"

extern "C"
function fb_LTrimAny FBCALL ( src as FBSTRING ptr, pattern as FBSTRING ptr, result as FBSTRING ptr ) as FBSTRING ptr
	dim as const ubyte ptr pachText = NULL
	dim as destructable_string dst
	dim as ssize_t _len = 0

	DBG_ASSERT( result <> NULL )

	if ( src <> NULL andalso src->data <> NULL ) then
		dim as ssize_t len_pattern = iif((pattern <> NULL) andalso (pattern->data <> NULL), FB_STRSIZE( pattern ), 0)
		pachText = src->data
		_len = FB_STRSIZE( src )
		if ( len_pattern <> 0 ) then
			while ( _len <> 0 )
				if ( FB_MEMCHR( pattern->data, *pachText, len_pattern ) = NULL ) then
					exit while
				end if

				_len -= 1
				pachText += 1
			wend
		end if
	end if

	if ( _len > 0 ) then
		if ( fb_hStrAlloc( @dst, _len ) <> NULL ) then
			/' simple copy '/
			fb_hStrCopy( dst.data, pachText, _len )
		end if
	end if

	fb_StrSwapDesc( @dst, result )
	return result
end function
end extern