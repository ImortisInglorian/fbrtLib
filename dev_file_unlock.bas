/' file device '/

#include "fb.bi"

extern "C"
function fb_DevFileUnlock( handle as FB_FILE ptr, position as fb_off_t, size as fb_off_t ) as long
	dim as long res
	dim as FILE ptr fp

	if ( size = 0 ) then
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	FB_LOCK()

	fp = cast(FILE ptr, handle->opaque)
	if ( fp = NULL ) then
		FB_UNLOCK()
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	res = fb_hFileUnlock( fp, position, size )

	FB_UNLOCK()

	return res
end function
end extern