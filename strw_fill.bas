/' stringw$ function '/

#include "fb.bi"

extern "C"
function fb_WstrFill1 FBCALL ( chars as ssize_t, c as long ) as FB_WCHAR ptr
	dim as FB_WCHAR ptr dst

	if( chars <= 0 ) then
		return NULL
	end if

	/' alloc temp string '/
    dst = fb_wstr_AllocTemp( chars )
	if ( dst <> NULL ) then
		/' fill it '/
		fb_wstr_Fill( dst, c, chars )
	end if

	return dst
end function

function fb_WstrFill2 FBCALL ( chars as ssize_t, src as FB_WCHAR const ptr ) as FB_WCHAR ptr
	dim as FB_WCHAR ptr dst

	if ( (chars > 0) and (src <> NULL) and (fb_wstr_Len( src ) > 0) ) then
		dst = fb_WstrFill1( chars, src[0] )
	else
		dst = NULL
	end if

	return dst
end function
end extern