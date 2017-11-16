/' oct(any ptr) function '/

#include "fb.bi"

extern "C"
function fb_OCT_p FBCALL ( p as any const ptr ) as FBSTRING ptr
	#ifdef HOST_64BIT
	return fb_OCT_l( cast(ulongint, p) )
	#else
	return fb_OCT_i( cast(ulong, p) )
	#endif
end function

function fb_OCTEx_p FBCALL ( p as any const ptr, digits as long ) as FBSTRING ptr
	#ifdef HOST_64BIT
	return fb_OCTEx_l( cast(ulongint, p), digits )
	#else
	return fb_OCTEx_i( cast(ulong, p), digits )
	#endif
end function
end extern