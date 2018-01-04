/' file device '/

#include "fb.bi"

extern "C"
function fb_DevFileLock( handle as FB_FILE ptr, position as fb_off_t, size as fb_off_t ) as long
	dim as FILE ptr fp
	dim as long res

	if ( size = 0 ) then
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	FB_LOCK()

	fp = cast(FILE ptr, handle->opaque)

	if ( fp = NULL ) then
		FB_UNLOCK()
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	res = fb_hFileLock( fp, position, size )

	FB_UNLOCK()

	return res
end function
end extern