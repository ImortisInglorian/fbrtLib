/' console 'screen , pg, pg' function '/

#include "../fb.bi"
#include "fb_private_console.bi"

Extern "c"
Function fb_ConsolePageSet( active As Long, visible As Long ) As Long

	return -1
End Function
End Extern
