/' file device '/

#include "fb.bi"
#include "crt_extra/stdio.bi"

extern "C"
function fb_DevFileSeek( handle as FB_FILE ptr, offset as fb_off_t, whence as long ) as long
    dim as long res
    dim as FILE ptr fp

	FB_LOCK()

    fp = cast(FILE ptr, handle->opaque)

    if ( fp = NULL ) then
		FB_UNLOCK()
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
    end if

	res = fb_ErrorSetNum( iif(fseeko( fp, offset, whence ) = 0, FB_RTERROR_OK, FB_RTERROR_FILEIO) )

	FB_UNLOCK()

	return res
end function
end extern