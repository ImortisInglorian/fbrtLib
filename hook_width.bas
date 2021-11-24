/' width entrypoint, default to console mode '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_Width FBCALL ( cols as long, rows as long ) as long
	dim as long cur

	fb_DevScrnInit_NoOpen( )

	FB_LOCK()

	if ( __fb_ctx.hooks.widthproc <> NULL ) then
		cur = __fb_ctx.hooks.widthproc( cols, rows )
	else
        cur = fb_ConsoleWidth( cols, rows )
	end if

    if ( cols>0 ) then
        FB_HANDLE_SCREEN->width = cols
	end if

    /' Reset VIEW PRINT '/
    if ( (cols > 0) orelse (rows > 0) ) then
    	fb_ConsoleView( 0, 0 )
	end if

	FB_UNLOCK()

    return iif((cols < 1 andalso rows < 1), cur, 0)
end function
end extern