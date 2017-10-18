#include "../fb.bi"
#include "fb_private_console.bi"

extern "C"
function fb_ConsoleGetRawYEx( hConsole as HANDLE ) as long
    dim as CONSOLE_SCREEN_BUFFER_INFO info
    if ( GetConsoleScreenBufferInfo( hConsole, @info ) = 0 ) then
        return 0
	end if
    return info.dwCursorPosition.Y
end function

function fb_ConsoleGetRawY( ) as long
    return fb_ConsoleGetRawYEx( __fb_out_handle )
end function

function fb_ConsoleGetY( ) as long
    dim as long y = fb_ConsoleGetRawY()
    fb_hConvertFromConsole( NULL, @y, NULL, NULL )
    return y
end function
end extern