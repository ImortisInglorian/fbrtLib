/' low-level flush system buffers '/

#include "../fb.bi"
#include "crt/io.bi"
#include "windows.bi"

extern "C"

function fb_hFileFlushEx( f as FILE ptr ) as long

	if( FlushFileBuffers( cast(HANDLE, _get_osfhandle( _fileno( f ) ) ) ) = 0 ) then
		return fb_ErrorSetNum( FB_RTERROR_FILEIO )
	end if

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function

end extern