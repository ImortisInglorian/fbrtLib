/' console SCREEN() function (character/color query) '/

#include "../fb.bi"
#include "fb_private_console.bi"

Extern "c"
Function fb_ConsoleReadXY FBCALL( x as long, y as long, colorflag as long ) as Ulong

	dim buffer as ubyte ptr

	if( __fb_con.inited = 0 ) then
		return 0
	end if

	BG_LOCK( )
	fb_hRecheckConsoleSize( TRUE )
	BG_UNLOCK( )

	if ((x < 1) orelse (x > __fb_con.w) orelse (y < 1) orelse (y > __fb_con.h)) then
		return 0
	end if

	if (colorflag <> 0) then
		buffer = __fb_con.attr_buffer
	else
		buffer = __fb_con.char_buffer
	end if

	return buffer[((y - 1) * __fb_con.w) + x - 1]
End Function
End Extern