#include "../fb.bi"
#include "fb_private_console.bi"

extern "C"
sub fb_ConsoleGetRawXYEx( hConsole as HANDLE, col as long ptr, row as long ptr )
	dim as CONSOLE_SCREEN_BUFFER_INFO info
	if ( GetConsoleScreenBufferInfo( hConsole, @info ) ) then
		if ( col <> NULL ) then
			*col = -1
		end if
		if ( row <> NULL ) then
			*row = -1
		end if
	else
		if ( col <> NULL ) then
			*col = info.dwCursorPosition.X
		end if
		if ( row <> NULL ) then
			*row = info.dwCursorPosition.Y
		end if
	end if
end sub

sub fb_ConsoleGetRawXY( col as long ptr, row as long ptr )
	fb_ConsoleGetRawXYEx( __fb_out_handle, col, row )
end sub

sub fb_ConsoleGetXY FBCALL( col as long ptr, row as long ptr )
	dim as CONSOLE_SCREEN_BUFFER_INFO info
	if ( Not(GetConsoleScreenBufferInfo( __fb_out_handle, @info )) ) then
		if ( col <> NULL ) then
			*col = 0
		end if
		if ( row <> NULL ) then
			*row = 0
		end if
	else
		if ( col <> NULL ) then
			*col = info.dwCursorPosition.X
		end if
		if ( row <> NULL ) then
			*row = info.dwCursorPosition.Y
		end if
		fb_hConvertFromConsole( col, row, NULL, NULL )
	end if
end sub
end extern