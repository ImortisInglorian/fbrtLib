/' console LOCATE statement '/

#include "../fb.bi"
#include "fb_private_console.bi"

extern "C"
function fb_ConsoleLocate( row as long, col as long, cursor as long ) as long
    dim as long ret_val
    dim as CONSOLE_CURSOR_INFO info

    if ( col < 1 ) then
        col = fb_ConsoleGetX()
	end if
    if ( row < 1 ) then
        row = fb_ConsoleGetY()
	end if

    GetConsoleCursorInfo( __fb_out_handle, @info )
    ret_val = (col and &hFF) or ((row and &hFF) shl 8) or iif(info.bVisible, &h10000, 0)

    fb_hConvertToConsole( @col, @row, NULL, NULL )

    fb_ConsoleLocateRawEx( __fb_out_handle, row, col, cursor )

    return ret_val
end function

sub fb_ConsoleLocateRawEx( hConsole as HANDLE, row as long, col as long, cursor as long )
	dim as COORD c

    if ( col < 0 ) then
        col = fb_ConsoleGetRawXEx( hConsole )
	end if
    if( row < 0 ) then
        row = fb_ConsoleGetRawYEx( hConsole )
	end if

    c.X = cast(short, col)
    c.Y = cast(short, row)

  	if ( cursor >= 0 ) then
        dim as CONSOLE_CURSOR_INFO info
        GetConsoleCursorInfo( __fb_out_handle, @info )
  		info.bVisible = iif( cursor, TRUE, FALSE )
  		SetConsoleCursorInfo( hConsole, @info )
  	end if

    __fb_con.scrollWasOff = FALSE
    SetConsoleCursorPosition( hConsole, c )
end sub

sub fb_ConsoleLocateRaw FBCALL ( row as long, col as long, cursor as long )
	fb_ConsoleLocateRawEx( __fb_out_handle, row, col, cursor )
end sub
end extern