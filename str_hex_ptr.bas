/' hex(any ptr) function '/

#include "fb.bi"

extern "C"
function fb_HEX_p FBCALL ( p as const any ptr ) as FBSTRING ptr
	#ifdef HOST_64BIT
	return fb_HEX_l( cast(ulongint, p) )
	#else
	return fb_HEX_i( cast(ulong, p) )
	#endif
end function

function fb_HEXEx_p FBCALL ( p as const any ptr, digits as long ) as FBSTRING ptr
	#ifdef HOST_64BIT
	return fb_HEXEx_l( cast(ulongint, p), digits )
	#else
	return fb_HEXEx_i( cast(ulong, p), digits )
	#endif
end function
end extern