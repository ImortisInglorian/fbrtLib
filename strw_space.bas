/' spacew$ function '/

#include "fb.bi"

extern "C"
function fb_WstrSpace FBCALL ( chars as ssize_t ) as FB_WCHAR ptr
	dim as FB_WCHAR ptr dst

	if ( chars <= 0 ) then
		return NULL
	end if

	/' alloc temp string '/
    dst = fb_wstr_AllocTemp( chars )
	if ( dst <> NULL ) then
		/' fill it '/
		fb_wstr_Fill( dst, 32, chars )
	end if

	return dst
end function
end extern