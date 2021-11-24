/' ucasew$ function '/

#include "fb.bi"

extern "C"
function fb_WstrUcase2 FBCALL ( src as const FB_WCHAR ptr, mode as long ) as FB_WCHAR ptr
	dim as FB_WCHAR ptr dst, d
	dim as const FB_WCHAR ptr s
	dim as FB_WCHAR c
	dim as ssize_t chars, i = any

	if ( src = NULL ) then
		return NULL
	end if

	chars = fb_wstr_Len( src )

	/' alloc temp string '/
	dst = fb_wstr_AllocTemp( chars )
	if ( dst = NULL ) then
		return NULL
	end if

	s = src
	d = dst

	if ( mode = 1 ) then
		i = 0
		while( i < chars )		
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
		while( i < chars )		
			c = *s
			s += 1
			if ( fb_wstr_IsLower( c ) ) then
				c = fb_wstr_ToUpper( c )
			end if
			*d = c
			d += 1
			i += 1
		wend
	end if

	/' null char '/
	*d = 0

	return dst
end function
end extern