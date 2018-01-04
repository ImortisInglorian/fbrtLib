/' file device '/

#include "fb.bi"

extern "C"
function fb_DevScrnClose( handle as FB_FILE ptr ) as long
    FB_LOCK()
	fb_DevScrnEnd( handle )
    FB_UNLOCK()
	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern