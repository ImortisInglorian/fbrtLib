/' low-level lock and unlock functions '/

#include "../fb.bi"
#include "crt/io.bi"
#include "windows.bi"

extern "C"
function fb_hFileLock cdecl ( FILE *f, fb_off_t inipos, fb_off_t size ) as long
	return fb_ErrorSetNum( iif(LockFile( cast(HANDLE, get_osfhandle( fileno( f ) )), inipos, 0, size, 0 ) = TRUE, FB_RTERROR_OK, FB_RTERROR_FILEIO) )
end function

function fb_hFileUnlock cdecl ( FILE *f, fb_off_t inipos, fb_off_t size ) as long
	return fb_ErrorSetNum( iif(UnlockFile( cast(HANDLE,get_osfhandle( fileno( f ) )), inipos, 0, size, 0 ) = TRUE, FB_RTERROR_OK, FB_RTERROR_FILEIO) )
end function
end extern