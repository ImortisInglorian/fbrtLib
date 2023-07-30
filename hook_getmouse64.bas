#include "fb.bi"

extern "C"
function fb_GetMouse64 FBCALL ( x as longint ptr, y as longint ptr, z as longint ptr, buttons as longint ptr, clip as longint ptr ) as long
	dim as long res, ix = -1, iy = -1, iz = -1, ibuttons = -1, iclip = -1

	res = fb_GetMouse( @ix, @iy, @iz, @ibuttons, @iclip )

	if (x) then *x = ix
	if (y) then *y = iy
	if (z) then *z = iz
	if (buttons) then *buttons = ibuttons
	if (clip) then *clip = iclip
	return res
end function
end extern