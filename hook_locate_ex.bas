/' locate entrypoint, default to console mode '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_LocateEx FBCALL ( row as long, col as long, cursor as long, current_pos as long ptr ) as long
    dim as long tmp_current_pos = 0
    dim as long res = fb_ErrorSetNum( FB_RTERROR_OK )
    dim as long start_y, end_y, con_width

    fb_ConsoleGetView(@start_y, @end_y)
    fb_GetSize( @con_width, NULL )

    if ( row <> 0 and (row < start_y or row > end_y) ) then
        res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
    elseif ( col <> 0 and (col < 1 or col > con_width) ) then
        res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
    else
        fb_DevScrnInit_NoOpen( )

        FB_LOCK()

        if ( __fb_ctx.hooks.locateproc <> NULL ) then
            tmp_current_pos = __fb_ctx.hooks.locateproc( row, col, cursor )
        else
            tmp_current_pos = fb_ConsoleLocate( row, col, cursor )
        end if

        if ( col <> 0 ) then
            FB_HANDLE_SCREEN->line_length = col - 1
		end if

        FB_UNLOCK()
    end if

    if ( current_pos <> NULL ) then
        *current_pos = tmp_current_pos
	end if

	return res
end function
end extern