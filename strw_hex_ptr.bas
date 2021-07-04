/' whex(any ptr) function '/

#include "fb.bi"

extern "C"
function fb_WstrHex_p FBCALL ( p as const any ptr ) as FB_WCHAR ptr
#ifdef HOST_64BIT
	return fb_WstrHex_l( cast(ulongint, p) )
#else
	return fb_WstrHex_i( cast(ulong, p) )
#endif
end function

function fb_WstrHexEx_p FBCALL ( p as const any ptr, digits as long ) as FB_WCHAR ptr
#ifdef HOST_64BIT
	return fb_WstrHexEx_l( cast(ulongint, p), digits )
#else
	return fb_WstrHexEx_i( cast(ulong, p), digits )
#endif
end function
end extern