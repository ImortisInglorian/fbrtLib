/' midw$ function '/

#include "fb.bi"

extern "C"
function fb_WstrMid FBCALL ( src as const FB_WCHAR ptr, start as ssize_t, _len as ssize_t ) as FB_WCHAR ptr
    dim as FB_WCHAR ptr dst
	dim as ssize_t src_len

    if ( src = NULL ) then
    	return NULL
	end if

    src_len = fb_wstr_Len( src )
    if ( src_len = 0 ) then
    	return NULL
	end if

    if ( (start <= 0) or (start > src_len) or (_len = 0) ) then
    	return NULL
	end if

    start -= 1

    if ( _len < 0 ) then
    	_len = src_len
	end if
	
    if ( start + _len > src_len ) then
    	_len = src_len - start
	end if

	/' alloc temp string '/
    dst = fb_wstr_AllocTemp( _len )
	if ( dst <> NULL ) then
		fb_wstr_Copy( dst, @src[start], _len )
	end if

	return dst
end function
end extern