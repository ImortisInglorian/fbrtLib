/' trimw$ function '/

#include "fb.bi"

extern "C"
function fb_WstrTrim FBCALL ( src as const FB_WCHAR ptr ) as FB_WCHAR ptr
	dim as FB_WCHAR ptr dst
	dim as const FB_WCHAR ptr p
	dim as ssize_t chars

	if ( src = NULL ) then
		return NULL
	end if

	chars = fb_wstr_Len( src )
	if ( chars <= 0 ) then
		return NULL
	end if

	p = fb_wstr_SkipCharRev( src, chars, asc(" ") )
	chars = fb_wstr_CalcDiff( src, p ) + 1
	if ( chars <= 0 ) then
		return NULL
	end if

	p = fb_wstr_SkipChar( src, chars, asc(" ") )
	chars -= fb_wstr_CalcDiff( src, p )
	if ( chars <= 0 ) then
		return NULL
	end if

	/' alloc temp string '/
    dst = fb_wstr_AllocTemp( chars )
	if ( dst <> NULL ) then
		/' simple copy '/
		fb_wstr_Copy( dst, p, chars )
	end if

	return dst
end function
end extern