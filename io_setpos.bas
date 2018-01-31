/' Sets a file handles line length '/

#include "fb.bi"

extern "C"
function fb_SetPos FBCALL ( handle as FB_FILE ptr, line_length as long ) as long
    FB_LOCK()
    handle->line_length = line_length
	FB_UNLOCK()

    return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern