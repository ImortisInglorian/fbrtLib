/' hexw$ routines '/

#include "fb.bi"

extern "C"
function fb_WstrHex_b FBCALL ( num as ubyte ) as FB_WCHAR ptr
	return fb_WstrHexEx_l( num, 0 )
end function

function fb_WstrHex_s FBCALL ( num as ushort ) as FB_WCHAR ptr
	return fb_WstrHexEx_l( num, 0 )
end function

function fb_WstrHex_i FBCALL ( num as ulong ) as FB_WCHAR ptr
	return fb_WstrHexEx_l( num, 0 )
end function

function fb_WstrHexEx_b FBCALL ( num as ubyte, digits as long ) as FB_WCHAR ptr
	return fb_WstrHexEx_l( num, digits )
end function

function fb_WstrHexEx_s FBCALL ( num as ushort, digits as long ) as FB_WCHAR ptr
	return fb_WstrHexEx_l( num, digits )
end function

function fb_WstrHexEx_i FBCALL ( num as ulong, digits as long ) as FB_WCHAR ptr
	return fb_WstrHexEx_l( num, digits )
end function
end extern