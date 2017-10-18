/' console CLS statement '/

#include "../fb.bi"
#include "fb_private_console.bi"

extern "C"
sub fb_ConsoleClearViewRawEx( hConsole as HANDLE, x1 as long, y1 as long, x2 as long, y2 as long )
    dim as WORD    attr = cast(WORD, fb_ConsoleGetColorAttEx( hConsole ))
    dim as long wid = x2 - x1 + 1, lines = y2 - y1 + 1

    if ( wid = 0 or lines = 0 ) then
        exit sub
	end if

    DBG_ASSERT(wid > 0)
    DBG_ASSERT(lines > 0)

    while (lines)
        dim as DWORD written
        dim as COORD _coord = type( x1, y1 + lines )
        FillConsoleOutputAttribute( hConsole, attr, wid, _coord, @written)
        FillConsoleOutputCharacter( hConsole, 32, wid, _coord, @written )
		lines -= 1
    wend

    fb_ConsoleLocateRawEx( hConsole, y1, x1, -1 )
end sub

sub fb_ConsoleClear( mode as long )
    /' This is the view in screen buffer coordinates (0-based) '/
    dim as long view_left, view_top, view_right, view_bottom

    /' This is the window in screen buffer coordinates (0-based) '/
    dim as long win_left, win_top, win_right, win_bottom

    fb_InitConsoleWindow()

    if ( FB_CONSOLE_WINDOW_EMPTY() or mode = 1 ) then
        exit sub
	end if

    win_top = __fb_con.window.Top
    win_left = __fb_con.window.Left
    win_right = __fb_con.window.Right
    win_bottom = __fb_con.window.Bottom

	if ( (mode = 2) or (mode = cast(long, &hFFFF0000)) ) then	/' same as gfxlib's DEFAULT_COLOR '/
        /' Just fill the view '/
        fb_ConsoleGetView( @view_top, @view_bottom )

        /' Translate the rows of the view to screen buffer coordinates (0-based) '/
        fb_hConvertToConsole( NULL, @view_top, NULL, @view_bottom )
        view_left = win_left
        view_right = win_right

    else
        /' Fill the whole window? '/
        view_top = win_top
        view_left = win_left
        view_right = win_right
        view_bottom = win_bottom
    end if

    DBG_ASSERT(view_left <= view_right)
    DBG_ASSERT(view_top <= view_bottom)

    fb_ConsoleClearViewRawEx( __fb_out_handle, view_left, view_top, view_right, view_bottom )
end sub
end extern