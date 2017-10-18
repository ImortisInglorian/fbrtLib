#include "../fb.bi"
#include "fb_private_console.bi"

extern "C"
function fb_ConsoleGetRawXEx( hConsole as HANDLE ) as long
    dim as CONSOLE_SCREEN_BUFFER_INFO info
    if( GetConsoleScreenBufferInfo( hConsole, @info ) = 0 ) then
        return 0
	end if
    return info.dwCursorPosition.X
end function

function fb_ConsoleGetRawX( ) as long
    return fb_ConsoleGetRawXEx( __fb_out_handle )
end function

function fb_ConsoleGetX( ) as long
    dim as long x = fb_ConsoleGetRawX()
    fb_hConvertFromConsole( @x, NULL, NULL, NULL )
    return x
end function
end extern