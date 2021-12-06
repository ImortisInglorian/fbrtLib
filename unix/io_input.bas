/' console input helpers '/

#include "../fb.bi"
#include "fb_private_console.bi"

Extern "c"
Function fb_hConsoleInputBufferChanged( ) As Long
	return fb_KeyHit()
End Function
End Extern