/' bin$ routines '/

#include "fb.bi"

extern "C"
function fb_BIN_b FBCALL ( num as ubyte, result as FBSTRING ptr ) as FBSTRING ptr
	return fb_BINEx_l( num, 0, result )
end function

function fb_BIN_s FBCALL ( num as ushort, result as FBSTRING ptr ) as FBSTRING ptr
	return fb_BINEx_l( num, 0, result )
end function

function fb_BIN_i FBCALL ( num as ulong, result as FBSTRING ptr ) as FBSTRING ptr
	return fb_BINEx_l( num, 0, result )
end function

function fb_BINEx_b FBCALL ( num as ubyte, digits as long, result as FBSTRING ptr ) as FBSTRING ptr
	return fb_BINEx_l( num, digits, result )
end function

function fb_BINEx_s FBCALL ( num as ushort, digits as long, result as FBSTRING ptr ) as FBSTRING ptr
	return fb_BINEx_l( num, digits, result )
end function

function fb_BINEx_i FBCALL ( num as ulong, digits as long, result as FBSTRING ptr ) as FBSTRING ptr
	return fb_BINEx_l( num, digits, result )
end function
end extern