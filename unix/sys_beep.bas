/' beep function '/

#include "../fb.bi"
#include "fb_private_console.bi"

Extern "c"
Sub fb_Beep FBCALL( )

	fb_hTermOut(SEQ_BEEP, 0, 0)
End Sub
End Extern
