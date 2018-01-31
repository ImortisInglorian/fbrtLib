/' gety entrypoint, default to console mode '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_GetY FBCALL ( ) as long
	dim as long res

	FB_LOCK()

	if ( __fb_ctx.hooks.getyproc <> NULL ) then
		res = __fb_ctx.hooks.getyproc( )
	else
		res = fb_ConsoleGetY( )
	end if
	FB_UNLOCK()

	return res
end function
end extern