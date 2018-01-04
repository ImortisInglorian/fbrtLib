/' file device '/

#include "fb.bi"

extern "C"
function fb_DevStdIoClose( handle as FB_FILE ptr ) as long
    FB_LOCK()

	handle->opaque = NULL

    FB_UNLOCK()

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern