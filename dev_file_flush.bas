/' file device '/

#include "fb.bi"

extern "C"
function fb_DevFileFlush( handle as FB_FILE ptr ) as long
	dim as FILE ptr fp
	dim as long errorRet = FB_RTERROR_OK

	FB_LOCK()

	fp = cast(FILE ptr, handle->opaque)

	if ( fp = NULL ) then
		errorRet = FB_RTERROR_ILLEGALFUNCTIONCALL
        else if( fflush( fp ) <> 0 ) then
		errorRet = FB_RTERROR_FILEIO
	end if

	FB_UNLOCK()

	return fb_ErrorSetNum( errorRet )
end function
end extern