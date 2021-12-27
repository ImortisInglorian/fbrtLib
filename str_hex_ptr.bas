/' hex(any ptr) function '/

#include "fb.bi"

extern "C"
function fb_HEX_p FBCALL ( p as const any ptr, result as FBSTRING ptr ) as FBSTRING ptr
	#ifdef HOST_64BIT
	return fb_HEX_l( cast(ulongint, p), result )
	#else
	return fb_HEX_i( cast(ulong, p), result )
	#endif
end function

function fb_HEXEx_p FBCALL ( p as const any ptr, digits as long, result as FBSTRING ptr ) as FBSTRING ptr
	#ifdef HOST_64BIT
	return fb_HEXEx_l( cast(ulongint, p), digits, result )
	#else
	return fb_HEXEx_i( cast(ulong, p), digits, result )
	#endif
end function
end extern