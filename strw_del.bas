/' wstring deletion function '/

#include "fb.bi"

extern "C"
sub fb_WstrDelete FBCALL ( _str as FB_WCHAR ptr )
    if ( _str = NULL ) then
    	exit sub
	end if

    fb_wstr_Del( _str )
end sub
end extern