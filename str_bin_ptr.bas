/' bin(any ptr) function '/

#include "fb.bi"

function fb_BIN_p FBCALL ( p as any const ptr ) as FBSTRING ptr
#ifdef HOST_64BIT
	return fb_BIN_l( cast(ulongint, p) )
#else
	return fb_BIN_i( cast(uinteger, p) )
#endif
end function

function fb_BINEx_p FBCALL ( p as any const ptr, digits as integer ) as FBSTRING ptr
#ifdef HOST_64BIT
	return fb_BINEx_l( cast(ulongint, p), digits )
#else
	return fb_BINEx_i( cast(uinteger, p), digits )
#endif
end function
