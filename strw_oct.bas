/' woct$ routines '/

#include "fb.bi"

extern "C"
function fb_WstrOct_b FBCALL ( num as ubyte ) as FB_WCHAR ptr
	return fb_WstrOctEx_l( num, 0 )
end function

function fb_WstrOct_s FBCALL ( num as ushort ) as FB_WCHAR ptr
	return fb_WstrOctEx_l( num, 0 )
end function

function fb_WstrOct_i FBCALL ( num as ulong ) as FB_WCHAR ptr
	return fb_WstrOctEx_l( num, 0 )
end function

function fb_WstrOctEx_b FBCALL ( num as ubyte, digits as long ) as FB_WCHAR ptr
	return fb_WstrOctEx_l( num, digits )
end function

function fb_WstrOctEx_s FBCALL ( num as ushort, digits as long ) as FB_WCHAR ptr
	return fb_WstrOctEx_l( num, digits )
end function

function fb_WstrOctEx_i FBCALL ( num as ulong, digits as long ) as FB_WCHAR ptr
	return fb_WstrOctEx_l( num, digits )
end function
end extern