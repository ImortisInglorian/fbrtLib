/' freefile function '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_FileFree FBCALL ( ) as long
	dim as long i

	FB_LOCK()

    for i = 1 to FB_MAX_FILES - FB_RESERVED_FILES
        dim as FB_FILE ptr handle = FB_FILE_TO_HANDLE(i)
        if (handle->hooks = NULL) then
			FB_UNLOCK()
			return i
        end if
    next

	FB_UNLOCK()

	return 0
end function
end extern