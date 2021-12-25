/' hex$ routines '/

#include "fb.bi"

extern "C"
function fb_HEX_b FBCALL ( num as ubyte, result as FBSTRING ptr ) as FBSTRING ptr
	return fb_HEXEx_l( num, 0, result )
end function

function fb_HEX_s FBCALL ( num as ushort, result as FBSTRING ptr ) as FBSTRING ptr
	return fb_HEXEx_l( num, 0, result )
end function

function fb_HEX_i FBCALL ( num as ulong, result as FBSTRING ptr ) as FBSTRING ptr
	return fb_HEXEx_l( num, 0, result )
end function

function fb_HEXEx_b FBCALL ( num as ubyte, digits as long, result as FBSTRING ptr ) as FBSTRING ptr
	return fb_HEXEx_l( num, digits, result )
end function

function fb_HEXEx_s FBCALL ( num as ushort, digits as long, result as FBSTRING ptr ) as FBSTRING ptr
	return fb_HEXEx_l( num, digits, result )
end function

function fb_HEXEx_i FBCALL ( num as ulong, digits as long, result as FBSTRING ptr ) as FBSTRING ptr
	return fb_HEXEx_l( num, digits, result )
end function
end extern