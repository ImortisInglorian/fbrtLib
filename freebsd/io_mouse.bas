/' console mode mouse functions '/

#include "../fb.bi"

Extern "c"
Function fb_ConsoleGetMouse( x as long ptr, y as long ptr, z as long ptr, buttons as long ptr, clip as long ptr ) as long

	if (x) then *x = -1
	if (y) then *y = -1
	if (z) then *z = -1
	if (buttons) then *buttons = -1

	if (clip) *clip = -1;	return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
End Function

Function fb_ConsoleSetMouse( x as long, y as long, cursor as long, clip as long ) as long

	return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
End Function
End Extern