/' lcasew$ function '/

#include "fb.bi"

extern "C"
function fb_WstrLcase2 FBCALL ( src as FB_WCHAR const ptr, mode as long ) as FB_WCHAR ptr
	dim as FB_WCHAR ptr dst, d
	dim as FB_WCHAR ptr s
	dim as FB_WCHAR c
	dim as ssize_t chars, i

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
		for i = 0 to chars - 1
			c = *s + 1
			if ( (c >= 65) and (c <= 90) ) then
				c += 97 - 65
			end if
			*d += 1
			*d = c
		next
	else
		for i = 0 to chars - 1
			c = *s + 1
			if ( fb_wstr_IsUpper( c ) ) then
				c = fb_wstr_ToLower( c )
			end if
			*d += 1
			*d = c
		next
	end if

	/' null char '/
	*d = 0

	return dst
end function
end extern