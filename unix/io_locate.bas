/' console LOCATE statement '/

#include "../fb.bi"
#include "fb_private_console.bi"

Extern "C"
Function fb_ConsoleLocate( row as Long, col as Long, cursor as Long ) As Long

	dim as Long x, y
	static visible as Long = &H10000

	if (__fb_con.inited = 0) then
		return 0
	end if

	if ((row <= 0) orelse (col <= 0)) then
		fb_ConsoleGetXY(@x, @y)
	end if

	BG_LOCK()

	if (col > 0) then x = col
	if (row > 0) then y = row

	fb_hRecheckConsoleSize( TRUE )

	if (x <= __fb_con.w) then
		__fb_con.cur_x = x
	else
		__fb_con.cur_x = __fb_con.w
	end if
	if (y <= __fb_con.h) then
		__fb_con.cur_y = y
	else
		__fb_con.cur_y = __fb_con.h
	end if
	fb_hTermOut(SEQ_LOCATE, x-1, y-1)
	if (cursor = 0) then
		fb_hTermOut(SEQ_HIDE_CURSOR, 0, 0)
		visible = 0

	elseif (cursor = 1) then
		fb_hTermOut(SEQ_SHOW_CURSOR, 0, 0)
		visible = &H10000
	end if

	BG_UNLOCK()

	return (x And &HFF) Or ((y And &HFF) shl 8) Or visible
End Function
End Extern
