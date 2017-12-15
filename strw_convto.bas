/' strw$ routines for int, uint '/

#include "fb.bi"

extern "C"
function fb_IntToWstr FBCALL ( num as long ) as FB_WCHAR ptr
	dim as FB_WCHAR ptr dst

	/' alloc temp string '/
    dst = fb_wstr_AllocTemp( sizeof( long ) * 3 )
	if ( dst <> NULL ) then
		/' convert '/
        FB_WSTR_FROM_INT( dst, num )
	end if

	return dst
end function

function fb_UIntToWstr FBCALL ( num as ulong ) as FB_WCHAR ptr
	dim as FB_WCHAR ptr dst

	/' alloc temp string '/
    dst = fb_wstr_AllocTemp( sizeof( long ) * 3 )
	if ( dst <> NULL ) then
		/' convert '/
        FB_WSTR_FROM_UINT( dst, num )
	end if

	return dst
end function
end extern