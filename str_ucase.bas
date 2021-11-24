/' ucase$ function '/

#include "fb.bi"
#include "crt/ctype.bi"

extern "C"
function fb_StrUcase2 FBCALL ( src as FBSTRING ptr, mode as long ) as FBSTRING ptr
	dim as FBSTRING ptr dst
	dim as ssize_t i = any, _len = 0
	dim as long c
	dim as ubyte ptr s, d

	if ( src = NULL ) then
		return @__fb_ctx.null_desc
	end if
	
	FB_STRLOCK()

	if ( src->data <> NULL ) then
		_len = FB_STRSIZE( src )

		/' alloc temp string '/
		dst = fb_hStrAllocTemp_NoLock( NULL, _len )
	else
		dst = NULL
	end if

	if ( dst ) then
		s = src->data
		d = dst->data

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
	else
		dst = @__fb_ctx.null_desc
	end if

	/' del if temp '/
	fb_hStrDelTemp_NoLock( src )

	FB_STRUNLOCK()

	return dst
end function
end extern