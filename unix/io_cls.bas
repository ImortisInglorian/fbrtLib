/' console CLS statement '/

#include "../fb.bi"
#include "fb_private_console.bi"

Extern "c"
Sub fb_ConsoleClear( mode as long )

	dim as long start, end_, i

	if (__fb_con.inited = 0 orelse mode=1) then
		exit sub
	end if

	BG_LOCK( )
	fb_hRecheckConsoleSize( TRUE )
	BG_UNLOCK( )

	fb_ConsoleGetView(@start, @end_)
	if ((mode <> 2) andalso (mode <> &HFFFF0000)) then
		start = 1
		end_ = fb_ConsoleGetMaxRow()
	end if
	if (start > __fb_con.h) then
		start = __fb_con.h
	end if
	if (end_ > __fb_con.h) then
		end_ = __fb_con.h
	end if
	for i = start to end_
		memset(__fb_con.char_buffer + ((i - 1) * __fb_con.w), asc(" "), __fb_con.w)
		memset(__fb_con.attr_buffer + ((i - 1) * __fb_con.w), __fb_con.fg_color or (__fb_con.bg_color shl 4), __fb_con.w)
		fb_hTermOut(SEQ_LOCATE, 0, i-1)
		fb_hTermOut(SEQ_CLEOL, 0, 0)
	next
	fb_hTermOut(SEQ_LOCATE, 0, start-1)
	__fb_con.cur_y = start
	__fb_con.cur_x = 1
End Sub
End Extern
