/' file copy '/

#include "../fb.bi"
#include "windows.bi"

extern "C"
function fb_FileCopy FBCALL ( source as ubyte const ptr, destination as ubyte const ptr ) as long
	dim as BOOL res
	res = CopyFile( source, destination, FALSE )
	return fb_ErrorSetNum( iif(res = FALSE, FB_RTERROR_ILLEGALFUNCTIONCALL, FB_RTERROR_OK) )
end function
end extern