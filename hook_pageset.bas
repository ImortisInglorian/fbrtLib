/' 'screen , pg, pg' entrypoint, default to console mode '/

#include "fb.bi"

extern "C"
function fb_PageSet FBCALL ( active as long, visible as long ) as long
	dim as long res

	fb_DevScrnInit_NoOpen( )

	FB_LOCK()

	if ( __fb_ctx.hooks.pagesetproc <> NULL ) then
		res = __fb_ctx.hooks.pagesetproc( active, visible )
	else
		if ( (active >= FB_CONSOLE_MAXPAGES) or (visible >= FB_CONSOLE_MAXPAGES) ) then
			res = -1
		else
			res = fb_ConsolePageSet( active, visible )
		end if
	end if

	FB_UNLOCK()

	return res
end function
end extern