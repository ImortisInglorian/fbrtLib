#include "../fb.bi"
#include "fb_private_console.bi"

extern "C"
function fb_hFileResetEx cdecl ( streamno as long ) as long
	dim as FILE ptr f

	fb_hConsoleResetHandles()

	if ( streamno = 0 ) then
		f = freopen( "CONIN$", "r", stdin )
	else 
		f = freopen( "CONOUT$", "w", stdout )
	end if
	/' force handles to be reinitialized now '/
	fb_hConsoleGetHandle( TRUE )

	return (f <> NULL)
end function
end extern