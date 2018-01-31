/' input$|line input entrypoint, default to console mode '/

#include "fb.bi"

extern "C"
function fb_ReadString( buffer as ubyte ptr, _len as ssize_t, f as FILE ptr ) as ubyte ptr
	dim as ubyte ptr result

	if ( f <> stdin ) then
		result = fgets( buffer, _len, f )
	else
		FB_LOCK( )
		if ( __fb_ctx.hooks.readstrproc <> NULL ) then
			result = __fb_ctx.hooks.readstrproc( buffer, _len )
		else
			result = fb_ConsoleReadStr( buffer, _len )
		end if
		FB_UNLOCK( )
	end if

	return result
end function
end extern