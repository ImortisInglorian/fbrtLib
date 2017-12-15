/' woct(any ptr) function '/

#include "fb.bi"

extern "C"
function fb_WstrOct_p FBCALL ( p as any const ptr ) as FB_WCHAR ptr
#ifdef HOST_64BIT
	return fb_WstrOct_l( cast(ulongint, p) )
#else
	return fb_WstrOct_i( cast(ulong, p) )
#endif
end function

function fb_WstrOctEx_p FBCALL ( p as any const ptr, digits as long ) as FB_WCHAR ptr
#ifdef HOST_64BIT
	return fb_WstrOctEx_l( cast(ulongint, p), digits )
#else
	return fb_WstrOctEx_i( cast(ulong, p), digits )
#endif
end function
end extern