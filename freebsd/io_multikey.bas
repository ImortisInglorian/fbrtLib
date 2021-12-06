/' console multikey() '/

#include "../fb.bi"

Extern "c"
Function fb_ConsoleMultikey( scancode as long ) as long

	fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	return FB_FALSE
End Function
End Extern