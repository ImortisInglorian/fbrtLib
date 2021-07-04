#include "fb.bi"

extern "C"
function fb_WstrLcase FBCALL ( src as const FB_WCHAR ptr ) as FB_WCHAR ptr
	return fb_WstrLcase2( src, 0 )
end function
end extern
