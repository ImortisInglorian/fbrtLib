/' file device '/

#include "fb.bi"

extern "C"
function fb_DevFileTell( handle as FB_FILE ptr, pOffset as fb_off_t ptr ) as long
	dim as FILE ptr fp

	FB_LOCK()

	fp = cast(FILE ptr, handle->opaque)

	if ( fp = NULL ) then
		FB_UNLOCK()
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	*pOffset = ftello( fp )

	FB_UNLOCK()

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern
