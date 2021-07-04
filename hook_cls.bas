/' cls entrypoint, default to console mode '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_Cls FBCALL ( mode as long )
	fb_DevScrnInit_NoOpen( )

	FB_LOCK()

	if ( __fb_ctx.hooks.clsproc <> NULL ) then
		__fb_ctx.hooks.clsproc( mode )
	else
        fb_ConsoleClear( mode )
	end if

    FB_HANDLE_SCREEN->line_length = 0

	FB_UNLOCK()

end sub
end extern