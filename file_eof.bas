/' eof function '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_FileEofEx( handle as FB_FILE ptr ) as long
    dim as long res

    if ( FB_HANDLE_USED(handle) = 0 ) then
        return FB_TRUE
	end if

    FB_LOCK()

    if ( handle->hooks = NULL or handle->hooks->pfnEof = NULL ) then
		FB_UNLOCK()
		return FB_TRUE
    end if

    if ( handle->putback_size <> 0 ) then
        FB_UNLOCK()
        return FB_FALSE
    end if

    if ( handle->hooks->pfnEof <> NULL ) then
        res = handle->hooks->pfnEof( handle )
    else
        res = FB_TRUE
    end if

	FB_UNLOCK()

	return res
end function

/':::::'/
function fb_FileEof FBCALL ( fnum as long ) as long
    return fb_FileEofEx(FB_FILE_TO_HANDLE(fnum))
end function
end extern