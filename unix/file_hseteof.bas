/' low-level truncate / set end of file '/

#include "../fb.bi"
#include "unistd.bi"

Function fb_hFileSetEofEx( f as FILE ptr ) As Long

	dim pos as fb_off_t

	pos = ftello( f )
	if ( ftruncate( fileno( f ), pos ) <> 0 ) then
		return fb_ErrorSetNum( FB_RTERROR_FILEIO )
	end if

	return fb_ErrorSetNum( FB_RTERROR_OK )
	
End Function

 
