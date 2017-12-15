/' strw$ routines for boolean '/

#include "fb.bi"

extern "C"
dim shared as FB_WCHAR ptr false_string = sadd("false")
dim shared as FB_WCHAR ptr true_string =  sadd("true")

/':::::'/
function fb_hBoolToWstr FBCALL ( num as ubyte ) as FB_WCHAR ptr
	return iif(num <> 0, true_string, false_string)
end function

/':::::'/
function fb_BoolToWstr FBCALL ( num as ubyte ) as FB_WCHAR ptr
	dim as FB_WCHAR ptr dst

	/' alloc temp string '/
    dst = fb_wstr_AllocTemp( 5 )

	if ( dst <> NULL ) then
		dim as FB_WCHAR ptr src = fb_hBoolToWstr(num)
		fb_wstr_Copy( dst, src, fb_wstr_Len(src) )
	end if

	return dst
end function
end extern