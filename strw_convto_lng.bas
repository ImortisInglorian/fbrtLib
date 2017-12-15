/' strw$ routines for longint, ulongint '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_LongintToWstr FBCALL ( num as longint ) as FB_WCHAR ptr
	dim as FB_WCHAR ptr dst

	/' alloc temp string '/
    dst = fb_wstr_AllocTemp( sizeof( longint ) * 3 )
	if ( dst <> NULL ) then
		/' convert '/
        FB_WSTR_FROM_INT64( dst, num )
	end if

	return dst
end function

/':::::'/
function fb_ULongintToWstr FBCALL ( num as ulongint ) as FB_WCHAR ptr
	dim as FB_WCHAR ptr dst

	/' alloc temp string '/
    dst = fb_wstr_AllocTemp( sizeof( longint ) * 3 )
	if ( dst <> NULL ) then
        /' convert '/
        FB_WSTR_FROM_UINT64( dst, num )
	end if

	return dst
end function
end extern