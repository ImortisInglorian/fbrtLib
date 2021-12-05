#include "../fb.bi"
#include "fb_private_console.bi"

Extern "c"
Sub fb_ConsoleGetXY FBCALL( col as long ptr, row as long ptr )

	dim as long x, y

	if (__fb_con.inited <> 0) then
		BG_LOCK()

		/' We always want to requery the cursor position here, because
		   the cursor position could have been changed since the last
		   update (and there is no signal to tell us when the cursor
		   position changed except if we ourselves do it).
		   Thus, we're disabling fb_hRecheckConsoleSize()'s own cursor
		   position update (which it would only do in case a SIGWINCH
		   happened, but not always like we want to do here), to avoid
		   unnecessary duplicate updates. '/
		fb_hRecheckConsoleSize( FALSE )
		fb_hRecheckCursorPos( )

		x = __fb_con.cur_x
		y = __fb_con.cur_y

		BG_UNLOCK()
	else
		x = 1
		y = 1
	end if

	if (col <> Null) then *col = x
	if (row <> Null) then *row = y
End Sub
End Extern
