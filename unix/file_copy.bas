/' file copy '/

#include "../fb.bi"

Extern "C"
Function fb_FileCopy FBCALL ( source as const ubyte ptr, destination as const ubyte ptr ) as Long
	return fb_CrtFileCopy( source, destination )
End Function
End Extern