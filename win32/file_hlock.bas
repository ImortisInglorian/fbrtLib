/' low-level lock and unlock functions '/

#include "../fb.bi"
#include "crt/io.bi"
#include "windows.bi"

extern "C"
function fb_hFileLock cdecl ( f as FILE ptr, inipos as fb_off_t, size as fb_off_t ) as long
	return fb_ErrorSetNum( iif(LockFile( cast(HANDLE, _get_osfhandle( _fileno( f ) )), inipos, 0, size, 0 ) = TRUE, FB_RTERROR_OK, FB_RTERROR_FILEIO) )
end function

function fb_hFileUnlock cdecl ( f as FILE ptr, inipos as fb_off_t, size as fb_off_t ) as long
	return fb_ErrorSetNum( iif(UnlockFile( cast(HANDLE, _get_osfhandle( _fileno( f ) )), inipos, 0, size, 0 ) = TRUE, FB_RTERROR_OK, FB_RTERROR_FILEIO) )
end function
end extern