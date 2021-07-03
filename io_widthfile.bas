/' set the with for files '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_WidthFile FBCALL ( fnum as long, _width as long ) as long
    dim as long cur = _width
    dim as FB_FILE ptr handle

    FB_LOCK()

    handle = FB_HANDLE_DEREF(FB_FILE_TO_HANDLE(fnum))

    if ( FB_HANDLE_USED(handle) = 0 ) then
        /' invalid file handle '/
        FB_UNLOCK()
        return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
    end if

    if ( handle->hooks = NULL ) then
        /' not opened yet '/
        FB_UNLOCK()
        return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
    end if

    if( handle = FB_HANDLE_SCREEN ) then
        /' SCREEN device '/
        if( _width <> -1 ) then
            fb_Width( _width, -1 )
        end if
        cur = FB_HANDLE_SCREEN->width
    else
        if( _width <> -1 ) then
            handle->width = _width
            if( handle->hooks->pfnSetWidth <> NULL ) then
                handle->hooks->pfnSetWidth( handle, _width )
			end if
        end if
        cur = handle->width
    end if

	FB_UNLOCK()

    if ( _width = -1 ) then
        return cur
    end if

    return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern