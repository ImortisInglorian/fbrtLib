/' pcopy entrypoint, default to console mode '/

#include "fb.bi"

extern "C"
function fb_PageCopy FBCALL ( src as long, dst as long ) as long
	fb_DevScrnInit_NoOpen( )

	FB_LOCK()

	dim as long res

	if ( __fb_ctx.hooks.pagecopyproc <> NULL ) then
		res = __fb_ctx.hooks.pagecopyproc( src, dst )
	else
		if( (src >= FB_CONSOLE_MAXPAGES) or (dst >= FB_CONSOLE_MAXPAGES) ) then
			return fb_ErrorSetNum(FB_RTERROR_ILLEGALFUNCTIONCALL)
		end if

		res = fb_ConsolePageCopy( src, dst )
	end if

	FB_UNLOCK()

	return res
end function
end extern