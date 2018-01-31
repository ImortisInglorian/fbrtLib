#include "fb.bi"

extern "C"
function fb_SetMouse FBCALL ( x as long, y as long, cursor as long, clip as long ) as long
	dim as long res

	FB_LOCK()

	if ( __fb_ctx.hooks.getmouseproc <> NULL ) then
		res = __fb_ctx.hooks.setmouseproc( x, y, cursor, clip )
	else
		res = fb_ConsoleSetMouse( x, y, cursor, clip )
	end if

	FB_UNLOCK()

	return res
end function
end extern