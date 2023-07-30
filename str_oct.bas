/' oct$ routines '/

#include "fb.bi"

extern "C"
function fb_OCT_b FBCALL ( num as ubyte ) as FBSTRING ptr
	return fb_OCTEx_l( num, 0 )
end function

function fb_OCT_s FBCALL ( num as ushort ) as FBSTRING ptr
	return fb_OCTEx_l( num, 0 )
end function

function fb_OCT_i FBCALL ( num as ulong ) as FBSTRING ptr
	return fb_OCTEx_l( num, 0 )
end function

function fb_OCTEx_b FBCALL ( num as ubyte, digits as long ) as FBSTRING ptr
	return fb_OCTEx_l( num, digits )
end function

function fb_OCTEx_s FBCALL ( num as ushort, digits as long ) as FBSTRING ptr
	return fb_OCTEx_l( num, digits )
end function

function fb_OCTEx_i FBCALL ( num as ulong, digits as long ) as FBSTRING ptr
	return fb_OCTEx_l( num, digits )
end function
end extern