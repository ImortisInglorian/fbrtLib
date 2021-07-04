/' ltrimw$ function '/

#include "fb.bi"

extern "C"
function fb_WstrLTrim FBCALL ( src as const FB_WCHAR ptr ) as FB_WCHAR ptr
	dim as FB_WCHAR ptr dst
	dim as const FB_WCHAR ptr p
	dim as ssize_t _len

	if ( src = NULL ) then
		return NULL
	end if

	_len = fb_wstr_Len( src )
	p = fb_wstr_SkipChar( src, _len, asc(" ") )

	_len -= fb_wstr_CalcDiff( src, p )
	if ( _len <= 0 ) then
		return NULL
	end if

	/' alloc temp string '/
    dst = fb_wstr_AllocTemp( _len )
	if ( dst <> NULL ) then
		fb_wstr_Copy( dst, p, _len )
	end if

	return dst
end function
end extern