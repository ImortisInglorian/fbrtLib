/' file device '/

#include "fb.bi"

extern "C"
function fb_DevFileClose( handle as FB_FILE ptr ) as long
    dim as FILE ptr fp

    FB_LOCK()

    fp = cast(FILE ptr, handle->opaque)

    if ( fp <> NULL ) then
        fclose( fp )
    end if

	handle->opaque = NULL

    FB_UNLOCK()

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern