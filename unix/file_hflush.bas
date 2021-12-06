/' flush system buffers '/

#include "../fb.bi"

Extern "c"
Function fb_hFileFlushEx( f as FILE ptr ) as Long
	if( fsync( fileno( f ) ) <> 0 ) then
		return fb_ErrorSetNum( FB_RTERROR_FILEIO )
	end if

	return fb_ErrorSetNum( FB_RTERROR_OK )
End Function
End Extern