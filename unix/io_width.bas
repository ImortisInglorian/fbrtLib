/' console width() function '/

#include "../fb.bi"
#include "fb_private_console.bi"

Extern "c"
Function fb_ConsoleWidth( cols as long, rows as long ) as long

	if( __fb_con.inited = 0 ) then
		return (80 Or (25 Shl 16))
	end if

	BG_LOCK( )
	fb_hRecheckConsoleSize( TRUE )
	BG_UNLOCK( )

	dim cur as long = __fb_con.w Or (__fb_con.h Shl 16)

	if ((cols > 0) orelse (rows > 0)) then
		BG_LOCK()

		if (cols <= 0) then
			cols = __fb_con.w
		end if
		if (rows <= 0) then
			rows = __fb_con.h
		end if
		fb_hTermOut(SEQ_WINDOW_SIZE, rows, cols)

		BG_UNLOCK()

		fb_ConsoleClear( 0 )
	end if

	return cur
End Function
End Extern
