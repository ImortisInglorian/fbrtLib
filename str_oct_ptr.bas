/' oct(any ptr) function '/

#include "fb.bi"

extern "C"
function fb_OCT_p FBCALL ( p as const any ptr, result as FBSTRING ptr ) as FBSTRING ptr
	#ifdef HOST_64BIT
	return fb_OCT_l( cast(ulongint, p), result )
	#else
	return fb_OCT_i( cast(ulong, p), result )
	#endif
end function

function fb_OCTEx_p FBCALL ( p as const any ptr, digits as long, result as FBSTRING ptr ) as FBSTRING ptr
	#ifdef HOST_64BIT
	return fb_OCTEx_l( cast(ulongint, p), digits, result )
	#else
	return fb_OCTEx_i( cast(ulong, p), digits, result )
	#endif
end function
end extern