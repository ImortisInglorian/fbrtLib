/' input/ouput redirection check '/

#include "fb.bi"

extern "C"
function fb_IsRedirected FBCALL ( is_input as long ) as long
	dim as long result

	FB_LOCK( )

	if ( __fb_ctx.hooks.isredirproc <> NULL ) then
		result = __fb_ctx.hooks.isredirproc( is_input )
	else
		result = fb_ConsoleIsRedirected( is_input )
	end if

	FB_UNLOCK( )

	return result
end function
end extern