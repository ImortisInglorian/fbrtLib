/' console pcopy function '/

#include "../fb.bi"
#include "fb_private_console.bi"

Extern "c"
Function fb_ConsolePageCopy( src as long, dst as long ) As Long

	return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
End Function
End Extern