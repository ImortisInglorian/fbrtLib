/' multikey entrypoint, default to console mode '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_Multikey FBCALL ( scancode as long ) as long
	dim as long res
	
	FB_LOCK()
	
	if ( __fb_ctx.hooks.multikeyproc <> NULL ) then
		res = __fb_ctx.hooks.multikeyproc( scancode )
	else
		res = fb_ConsoleMultikey( scancode )
	end if
	FB_UNLOCK()
	
	return res
end function
end extern