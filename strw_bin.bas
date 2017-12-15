/' binw$ routines '/

#include "fb.bi"

extern "C"
function fb_WstrBin_b FBCALL ( num as ubyte ) as FB_WCHAR ptr
	return fb_WstrBinEx_l( num, 0 )
end function

function fb_WstrBin_s FBCALL ( num as ushort ) as FB_WCHAR ptr
	return fb_WstrBinEx_l( num, 0 )
end function

function fb_WstrBin_i FBCALL ( num as ulong ) as FB_WCHAR ptr
	return fb_WstrBinEx_l( num, 0 )
end function

function fb_WstrBinEx_b FBCALL ( num as ubyte, digits as long ) as FB_WCHAR ptr
	return fb_WstrBinEx_l( num, digits )
end function

function fb_WstrBinEx_s FBCALL ( num as ushort, digits as long ) as FB_WCHAR ptr
	return fb_WstrBinEx_l( num, digits )
end function

function fb_WstrBinEx_i FBCALL ( num as ulong, digits as long ) as FB_WCHAR ptr
	return fb_WstrBinEx_l( num, digits )
end function
end extern