/' reads color valoe or character from X/Y position '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_ReadXY FBCALL ( col as long, row as long, colorflag as long ) as ulong
    dim as ulong res

    FB_LOCK()

    if ( __fb_ctx.hooks.readxyproc <> NULL ) then
        res = __fb_ctx.hooks.readxyproc( col, row, colorflag )
    else
        res = fb_ConsoleReadXY( col, row, colorflag )
    end if

    FB_UNLOCK()

	return res
end function
end extern