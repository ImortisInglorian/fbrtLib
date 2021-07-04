/' file copy '/

#include "../fb.bi"
#include "windows.bi"

extern "C"
function fb_FileCopy FBCALL ( source as const ubyte ptr, destination as const ubyte ptr ) as long
	dim as BOOL res
	res = CopyFile( source, destination, FALSE )
	return fb_ErrorSetNum( iif(res = FALSE, FB_RTERROR_ILLEGALFUNCTIONCALL, FB_RTERROR_OK) )
end function
end extern