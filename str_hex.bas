/' hex$ routines '/

#include "fb.bi"

extern "C"
function fb_HEX_b FBCALL ( num as ubyte ) as FBSTRING ptr
	return fb_HEXEx_l( num, 0 )
end function

function fb_HEX_s FBCALL ( num as ushort ) as FBSTRING ptr
	return fb_HEXEx_l( num, 0 )
end function

function fb_HEX_i FBCALL ( num as ulong ) as FBSTRING ptr
	return fb_HEXEx_l( num, 0 )
end function

function fb_HEXEx_b FBCALL ( num as ubyte, digits as long ) as FBSTRING ptr
	return fb_HEXEx_l( num, digits )
end function

function fb_HEXEx_s FBCALL ( num as ushort, digits as long ) as FBSTRING ptr
	return fb_HEXEx_l( num, digits )
end function

function fb_HEXEx_i FBCALL ( num as ulong, digits as long ) as FBSTRING ptr
	return fb_HEXEx_l( num, digits )
end function
end extern