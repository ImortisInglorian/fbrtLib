#include "../fb.bi"
#include "fb_private_console.bi"

Extern "c"
Function fb_ConsoleGetX( ) As Long

	dim x as long
	fb_ConsoleGetXY( @x, NULL )
	return x
End Function
End Extern