/' color entrypoint, default to console mode '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_Color FBCALL ( fc as long, bc as long, flags as long ) as long
	dim as long cur

	FB_LOCK()

	if ( __fb_ctx.hooks.colorproc <> NULL ) then
		cur = __fb_ctx.hooks.colorproc( fc, bc, flags )
	else
		cur = fb_ConsoleColor( fc, bc, flags )
	end if

	FB_UNLOCK()

	return cur
end function
end extern