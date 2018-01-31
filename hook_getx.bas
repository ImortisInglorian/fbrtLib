/' getx entrypoint, default to console mode '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_GetX FBCALL ( ) as long
	dim as long res

	FB_LOCK()

	if ( __fb_ctx.hooks.getxproc <> NULL ) then
		res = __fb_ctx.hooks.getxproc( )
	else
		res = fb_ConsoleGetX( )
	end if

	FB_UNLOCK()

	return res
end function
end extern