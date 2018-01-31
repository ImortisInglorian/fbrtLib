/' view print helpers (console, no gfx) '/

#include "fb.bi"

dim shared as long view_toprow = -1, view_botrow = -1

extern "C"
/':::::'/
function fb_ConsoleGetTopRow( ) as long
    if ( view_toprow = -1 ) then
        view_toprow = 0
    end if
	return view_toprow
end function

/':::::'/
function fb_ConsoleGetBotRow( ) as long
    if ( view_botrow = -1 ) then
        fb_GetSize( NULL, @view_botrow )
        if ( view_botrow <> 0 ) then
			view_botrow -= 1
        else
            view_botrow = FB_SCRN_DEFAULT_HEIGHT - 1
        end if
    end if

	return view_botrow
end function

/':::::'/
sub fb_ConsoleSetTopBotRows( top as long, bot as long )
    view_toprow = top
    view_botrow = bot
end sub

/':::::'/
sub fb_ConsoleGetView( toprow as long ptr, botrow as long ptr )
	*toprow = fb_ConsoleGetTopRow( ) + 1
    *botrow = fb_ConsoleGetBotRow( ) + 1
end sub
end extern