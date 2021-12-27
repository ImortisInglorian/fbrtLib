/' oct$ routines '/

#include "fb.bi"

extern "C"
function fb_OCT_b FBCALL ( num as ubyte, result as FBSTRING ptr ) as FBSTRING ptr
	return fb_OCTEx_l( num, 0, result )
end function

function fb_OCT_s FBCALL ( num as ushort, result as FBSTRING ptr ) as FBSTRING ptr
	return fb_OCTEx_l( num, 0, result )
end function

function fb_OCT_i FBCALL ( num as ulong, result as FBSTRING ptr ) as FBSTRING ptr
	return fb_OCTEx_l( num, 0, result )
end function

function fb_OCTEx_b FBCALL ( num as ubyte, digits as long, result as FBSTRING ptr ) as FBSTRING ptr
	return fb_OCTEx_l( num, digits, result )
end function

function fb_OCTEx_s FBCALL ( num as ushort, digits as long, result as FBSTRING ptr ) as FBSTRING ptr
	return fb_OCTEx_l( num, digits, result )
end function

function fb_OCTEx_i FBCALL ( num as ulong, digits as long, result as FBSTRING ptr ) as FBSTRING ptr
	return fb_OCTEx_l( num, digits, result )
end function
end extern