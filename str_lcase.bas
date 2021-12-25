/' lcase$ function '/

#include "fb.bi"
#include "destruct_string.bi"
#include "crt/ctype.bi"

extern "C"
function fb_StrLcase2 FBCALL ( src as FBSTRING ptr, mode as long, result as FBSTRING ptr ) as FBSTRING ptr
	dim as destructable_string dst
	dim as long i, c
	dim as ssize_t _len = 0
	dim as ubyte ptr s, d

	DBG_ASSERT( result <> NULL )

	if ( src <> NULL andalso src->data <> NULL ) then
		_len = FB_STRSIZE( src )
		if( fb_hStrAlloc( @dst, _len ) <> NULL ) then

			s = src->data
			d = dst.data

			if( mode = 1 ) then
				for  i = 0 to _len - 1
					c = *s
					s += 1
					if ( (c >= asc("A")) and (c <= asc("Z")) ) then
						c += 97 - 65
					end if
					*d = c
					d += 1
				next
			else
				for i = 0 to _len - 1
					c = *s
					s += 1
					if ( isupper( c ) ) then
						c = tolower( c )
					end if
					*d = c
					d += 1
				next
			end if

			/' null char '/
			*d = 0
		end if
	end if

	fb_StrSwapDesc( @dst, result )
	return result
end function
end extern