/' bin$ routines '/

#include "fb.bi"

function fb_BIN_b FBCALL ( num as ubyte ) as FBSTRING ptr
	return fb_BINEx_l( num, 0 )
end function

function fb_BIN_s FBCALL ( num as ushort ) as FBSTRING ptr
	return fb_BINEx_l( num, 0 )
end function

function fb_BIN_i FBCALL ( num as uinteger ) as FBSTRING ptr
	return fb_BINEx_l( num, 0 )
end function

function fb_BINEx_b FBCALL ( num as ubyte, digits as integer ) as FBSTRING ptr
	return fb_BINEx_l( num, digits )
end function

function fb_BINEx_s FBCALL ( num as ushort, digits as integer ) as FBSTRING ptr
	return fb_BINEx_l( num, digits )
end function

function fb_BINEx_i FBCALL ( num as uinteger, digits as integer ) as FBSTRING ptr
	return fb_BINEx_l( num, digits )
end function
