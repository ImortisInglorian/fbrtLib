#include "fb.bi"

extern "C"
function fb_GetMouse64 FBCALL ( x as longint ptr, y as longint ptr, z as longint ptr, buttons as longint ptr, clip as longint ptr ) as long
	dim as long res, ix, iy, iz, ibuttons, iclip

	res = fb_GetMouse( @ix, @iy, @iz, @ibuttons, @iclip )

	*x = ix
	*y = iy
	*z = iz
	*buttons = ibuttons
	*clip = iclip
	return res
end function
end extern