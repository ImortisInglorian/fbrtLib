#include "../fb.bi"
#include "fb_private_console.bi"

Extern "c"
Function fb_ConsoleGetY( ) As Long

	dim y as long
	fb_ConsoleGetXY( NULL, @y )
	return y
End Function

End Extern
