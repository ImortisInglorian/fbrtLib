/' console scrolling for when VIEW is used '/

#include "../fb.bi"
#include "../unix/fb_private_console.bi"

Extern "c"
Sub fb_ConsoleScroll(nrows as long)

	fb_hTermOut(SEQ_SCROLL, 0, nrows)
End Sub
End Extern
