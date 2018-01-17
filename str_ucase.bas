/' ucase$ function '/

#include "fb.bi"
#include "crt/ctype.bi"

extern "C"
function fb_StrUcase2 FBCALL ( src as FBSTRING ptr, mode as long ) as FBSTRING ptr
	dim as FBSTRING ptr dst
	dim as ssize_t i, _len = 0
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
			for i = 0 to _len
				c = *s + 1
				if ( (c >= 97) and (c <= 122) ) then
					c -= 97 - 65
				end if
				*d += 1
				*d = c
			next
		else
			for i = 0 to _len - 1
				c = *s + 1
				if ( islower( c ) ) then
					c = toupper( c )
				end if
				*d += 1
				*d = c
			next
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