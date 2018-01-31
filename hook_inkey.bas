/' inkey$ entrypoint, default to console mode '/

#include "fb.bi"

extern "C"
function fb_Inkey FBCALL ( ) as FBSTRING ptr
	dim as FBSTRING ptr res

	FB_LOCK()

	if ( __fb_ctx.hooks.inkeyproc <> NULL ) then
		res = __fb_ctx.hooks.inkeyproc( )
	else
		res = fb_ConsoleInkey( )
	end if

	FB_UNLOCK()

	return res
end function

function fb_Getkey FBCALL ( ) as long
	dim as FB_GETKEYPROC getkeyproc

	/' getkey() is blocking, thus we shouldn't hold the FB_LOCK() for the
	   whole duration, but only when needed, as short as possible, to allow
	   other hooks to be called in the meantime. This of course requires
	   the fb_ConsoleGetkey/fb_GfxGetkey to take care of synchronization
	   themselves. '/
	FB_LOCK()
	if ( __fb_ctx.hooks.getkeyproc <> NULL ) then
		getkeyproc = __fb_ctx.hooks.getkeyproc
	else
		getkeyproc = @fb_ConsoleGetkey
	end if
	FB_UNLOCK()

	return getkeyproc( )
end function

function fb_KeyHit FBCALL ( ) as long
	dim as long res

	FB_LOCK()

	if ( __fb_ctx.hooks.keyhitproc <> NULL ) then
		res = __fb_ctx.hooks.keyhitproc( )
	else
		res = fb_ConsoleKeyHit( )
	end if

	FB_UNLOCK()

	return res
end function
end extern