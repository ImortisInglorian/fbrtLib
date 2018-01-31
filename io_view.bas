/' view print (console, no gfx) '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_ConsoleViewEx( toprow as long, botrow as long, set_cursor as long ) as long
    dim as long do_update = FALSE
    dim as long maxrow, minrow

    minrow = 1
    fb_GetSize( NULL, @maxrow )
    if ( maxrow = 0 ) then
        maxrow = FB_SCRN_DEFAULT_HEIGHT
	end if

    if ( toprow > 0 ) then
        do_update = TRUE
    elseif ( toprow = 0 ) then
        do_update = TRUE
        toprow = minrow
    else
        toprow = fb_ConsoleGetTopRow() + 1
    end if

    if ( botrow > 0 ) then
        do_update = TRUE
    elseif ( botrow = 0 ) then
        do_update = TRUE
        botrow = maxrow
    else
        botrow = fb_ConsoleGetBotRow() + 1
    end if

    if ( toprow > botrow _
        or toprow < 1 _
        or botrow < 1 _
        or toprow > maxrow _
        or botrow > maxrow ) then
        /' This is an error ... '/
        do_update = FALSE
        botrow = 0
		toprow = 0
    end if

    if ( do_update = TRUE ) then
        fb_ConsoleSetTopBotRows( toprow - 1, botrow - 1 )
        fb_ViewUpdate( )
        if ( set_cursor = TRUE ) then
            /' set cursor to top row '/
            fb_Locate( toprow, 1, -1, 0, 0 )
        end if
    end if

    return toprow + (botrow shl 16)
end function

/':::::'/
function fb_ConsoleView FBCALL ( toprow as long, botrow as long ) as long
    return fb_ConsoleViewEx( toprow, botrow, TRUE )
end function
end extern