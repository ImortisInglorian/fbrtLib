#include "../fb.bi"

Extern "c"
Function fb_hFileResetEx( streamno as long ) As Long

	dim f as FILE ptr

	if( streamno = 0 ) then
		f = freopen( "/dev/tty", "r", stdin )
	else 
		f = freopen( "/dev/tty", "w", stdout )
	end if

	return (f <> NULL)
End Function
End Extern