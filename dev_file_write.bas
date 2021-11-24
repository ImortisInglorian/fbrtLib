/' file device '/

#include "fb.bi"

extern "C"
function fb_DevFileWrite( handle as FB_FILE ptr, value as const any ptr, valuelen as size_t ) as long
    dim as FILE ptr fp

    FB_LOCK()

    fp = cast(FILE ptr, handle->opaque)

	if ( fp = NULL ) then
		FB_UNLOCK()
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	/' do write '/
	if ( fwrite( cast(any ptr, value), 1, valuelen, fp ) <> valuelen ) then
		FB_UNLOCK()
		return fb_ErrorSetNum( FB_RTERROR_FILEIO )
	end if

	FB_UNLOCK()

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern