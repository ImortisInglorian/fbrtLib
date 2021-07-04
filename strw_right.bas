/' rightw$ function '/

#include "fb.bi"

extern "C"
function fb_WstrRight FBCALL ( src as const FB_WCHAR ptr, chars as ssize_t ) as FB_WCHAR ptr
	dim as FB_WCHAR ptr dst
	dim as ssize_t _len, src_len

	if ( src = NULL ) then
		return NULL
	end if

	src_len = fb_wstr_Len( src )
	if ( (chars <= 0) or (src_len = 0) ) then
		return NULL
	end if

	if ( chars > src_len ) then
		_len = src_len
	else
		_len = chars
	end if

	/' alloc temp string '/
    dst = fb_wstr_AllocTemp( _len )
	if ( dst <> NULL ) then
		/' simple rev copy '/
		fb_wstr_Copy( dst, @src[src_len - _len], _len )
	end if

	return dst
end function
end extern