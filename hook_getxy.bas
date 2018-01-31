/' getxy entrypoint, default to console mode '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_GetXY FBCALL ( col as long ptr, row as long ptr )
	FB_LOCK()

	if ( __fb_ctx.hooks.getxyproc <> NULL ) then
		__fb_ctx.hooks.getxyproc( col, row )
	else
		fb_ConsoleGetXY( col, row )
	end if
	FB_UNLOCK()
end sub
end extern