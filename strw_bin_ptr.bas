/' wbin(any ptr) function '/

#include "fb.bi"

extern "C"
function fb_WstrBin_p FBCALL ( p as const any ptr ) as FB_WCHAR ptr
#ifdef HOST_64BIT
	return fb_WstrBin_l( cast(ulongint, p) )
#else
	return fb_WstrBin_i( cast(ulong, p) )
#endif
end function

function fb_WstrBinEx_p FBCALL ( p as const any ptr, digits as long ) as FB_WCHAR ptr
#ifdef HOST_64BIT
	return fb_WstrBinEx_l( cast(ulongint, p), digits )
#else
	return fb_WstrBinEx_i( cast(ulong, p), digits )
#endif
end function
end extern