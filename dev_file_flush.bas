/' file device '/

#include "fb.bi"

extern "C"
function fb_DevFileFlush( handle as FB_FILE ptr ) as long
    dim as FILE ptr fp

    FB_LOCK()

    fp = cast(FILE ptr, handle->opaque)

	if ( fp = NULL ) then
		FB_UNLOCK()
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

    fflush( fp )

	FB_UNLOCK()

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern