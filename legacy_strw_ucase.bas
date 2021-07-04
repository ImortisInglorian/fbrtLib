#include "fb.bi"

extern "C"
function fb_WstrUcase FBCALL ( src as const FB_WCHAR ptr ) as FB_WCHAR ptr
	return fb_WstrUcase2( src, 0 )
end function
end extern