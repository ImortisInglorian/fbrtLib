/' view print update (console, no gfx) '/

#include "../fb.bi"
#include "fb_private_console.bi"

Extern "c"
Sub fb_ConsoleViewUpdate( )

	if (__fb_con.inited = 0) then
		Exit Sub
	end if
	__fb_con.scroll_region_changed = True
	fb_hTermOut(SEQ_SCROLL_REGION, fb_ConsoleGetBotRow(), fb_ConsoleGetTopRow())
End Sub
End Extern
