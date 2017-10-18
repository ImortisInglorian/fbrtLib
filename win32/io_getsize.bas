#include "../fb.bi"
#include "fb_private_console.bi"

extern "C"
sub fb_ConsoleGetSize FBCALL ( cols as long ptr, rows as long ptr )
    dim as long nrows, ncols

    fb_InitConsoleWindow()

    if ( FB_CONSOLE_WINDOW_EMPTY() ) then
        ncols = FB_SCRN_DEFAULT_WIDTH
        nrows = FB_SCRN_DEFAULT_HEIGHT
    else
        fb_hConsoleGetWindow( NULL, NULL, @ncols, @nrows )
    end if

    if( cols <> NULL ) then
        *cols = ncols
	end if
    if( rows <> NULL ) then
        *rows = nrows
	end if
end sub
end extern