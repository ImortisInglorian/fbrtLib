/' size of the screen buffer '/

#include "../fb.bi"
#include "fb_private_console.bi"

extern "C"
sub fb_ConsoleGetScreenSizeEx( hConsole as HANDLE, cols as long ptr, rows as long ptr ) 
	dim as CONSOLE_SCREEN_BUFFER_INFO info
	if ( GetConsoleScreenBufferInfo( hConsole, @info ) = 0 ) then
		if ( cols <> NULL ) then
			*cols = FB_SCRN_DEFAULT_WIDTH
		end if
		if ( rows <> NULL ) then
			*rows = FB_SCRN_DEFAULT_HEIGHT
		end if
	else
		if ( cols <> NULL ) then
			*cols = info.dwSize.X
		end if
		if ( rows <> NULL ) then
			*rows = info.dwSize.Y
		end if
	end if
end sub

sub fb_ConsoleGetScreenSize FBCALL ( cols as long ptr, rows as long ptr )
	fb_ConsoleGetScreenSizeEx( __fb_out_handle, cols, rows )
end sub
end extern