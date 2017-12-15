/' leftw$ function '/

#include "fb.bi"

extern "C"
function fb_WstrLeft FBCALL ( src as FB_WCHAR const ptr, chars as ssize_t ) as FB_WCHAR ptr
	dim as FB_WCHAR ptr dst
	dim as ssize_t _len

	if ( src = NULL ) then
		return NULL
	end if

	_len = fb_wstr_Len( src )
	if ( (chars <= 0) or (_len = 0) ) then
		return NULL
	end if

	if ( chars < _len ) then
		_len = chars
	end if

	/' alloc temp string '/
    dst = fb_wstr_AllocTemp( _len )
	if ( dst <> NULL ) then
		fb_wstr_Copy( dst, src, _len )
	end if

	return dst
end function
end extern