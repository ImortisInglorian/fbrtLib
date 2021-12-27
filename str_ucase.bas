/' ucase$ function '/

#include "fb.bi"
#include "crt/ctype.bi"
#include "destruct_string.bi"

extern "C"
function fb_StrUcase2 FBCALL ( src as FBSTRING ptr, mode as long, result as FBSTRING ptr ) as FBSTRING ptr
	dim as destructable_string dst
	dim as ssize_t i = any, _len = 0
	dim as long c
	dim as ubyte ptr s, d

	DBG_ASSERT( result <> NULL )

	if ( src <> NULL andalso src->data <> NULL ) then
		_len = FB_STRSIZE( src )

		if ( fb_hStrAlloc( @dst, _len ) <> NULL) then
			s = src->data
			d = dst.data

			if ( mode = 1 ) then
				i = 0
				while( i < _len )
					c = *s
					s += 1
					if ( (c >= asc("a")) and (c <= asc("z")) ) then
						c -= 97 - 65
					end if
					*d = c
					d += 1
					i += 1				
				wend
			else
				i = 0
				while( i < _len )
					c = *s
					s += 1
					if ( islower( c ) ) then
						c = toupper( c )
					end if
					*d = c
					d += 1
					i += 1				
				wend
			end if

			/' null char '/
			*d = 0
		end if
	end if

	fb_StrSwapDesc( @dst, result )
	return result
end function
end extern