#include "fb.bi"

extern "C"
function fb_GetMouse FBCALL ( x as long ptr, y as long ptr, z as long ptr, buttons as long ptr, clip as long ptr ) as long
	dim as long res

	FB_LOCK()

	if ( __fb_ctx.hooks.getmouseproc <> NULL ) then
		res = __fb_ctx.hooks.getmouseproc( x, y, z, buttons, clip )
	else
		res = fb_ConsoleGetMouse( x, y, z, buttons, clip )
	end if

	FB_UNLOCK()

	return res
end function
end extern