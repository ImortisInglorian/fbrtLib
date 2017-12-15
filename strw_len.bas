/' wstring length function '/

#include "fb.bi"

extern "C"
function fb_WstrLen FBCALL ( _str as FB_WCHAR ptr ) as ssize_t
	if ( _str = NULL ) then
		return 0
	end if

	return fb_wstr_Len( _str )
end function
end extern