/' getsize entrypoint, default to console mode '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_GetSize FBCALL ( cols as long ptr, rows as long ptr )
	FB_LOCK()

	if ( __fb_ctx.hooks.getsizeproc <> NULL ) then
		__fb_ctx.hooks.getsizeproc( cols, rows )
	else
		fb_ConsoleGetSize( cols, rows )
	end if

	FB_UNLOCK()
end sub
end extern