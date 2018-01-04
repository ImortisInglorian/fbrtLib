/' file device '/

#include "fb.bi"

extern "C"
function fb_DevPipeClose( handle as FB_FILE ptr ) as long
#if defined( HOST_DOS ) or defined( HOST_UNIX ) or defined( HOST_WIN32 )
	dim as FILE ptr fp

	FB_LOCK()

	fp = cast(FILE ptr, handle->opaque)
	if ( fp <> NULL ) then
		pclose( fp )
	end if

	handle->opaque = NULL

	FB_UNLOCK()
	return fb_ErrorSetNum( FB_RTERROR_OK )
#else
	return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
#endif
end function
end extern