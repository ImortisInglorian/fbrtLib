/' bin(any ptr) function '/

#include "fb.bi"

extern "C"
function fb_BIN_p FBCALL ( p as const any ptr, result as FBSTRING ptr ) as FBSTRING ptr
#ifdef HOST_64BIT
	return fb_BIN_l( cast(ulongint, p), result )
#else
	return fb_BIN_i( cast(uinteger, p), result )
#endif
end function

function fb_BINEx_p FBCALL ( p as const any ptr, digits as long, result as FBSTRING ptr ) as FBSTRING ptr
#ifdef HOST_64BIT
	return fb_BINEx_l( cast(ulongint, p), digits, result )
#else
	return fb_BINEx_i( cast(uinteger, p), digits, result )
#endif
end function
end extern