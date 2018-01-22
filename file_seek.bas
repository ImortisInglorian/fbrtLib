/' SEEK() and SEEK '/

#include "fb.bi"

extern "C"
function fb_FileSeekEx( handle as FB_FILE ptr, newpos as fb_off_t ) as long
	dim as long res

    if ( FB_HANDLE_USED(handle) = NULL ) then
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	FB_LOCK()

    /' clear put back buffer for every modifying non-read operation '/
    handle->putback_size = 0

    /' convert to 0 based file i/o '/
	newpos -= 1
    if ( handle->mode = FB_FILE_MODE_RANDOM ) then
        newpos = newpos * handle->len
	end if

    if (handle->hooks->pfnSeek <> NULL) then
        res = handle->hooks->pfnSeek(handle, newpos, SEEK_SET )
    else
        res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
    end if

	FB_UNLOCK()

	return res
end function

function fb_FileSeek FBCALL ( fnum as long, newpos as long ) as long
    return fb_FileSeekEx( FB_FILE_TO_HANDLE(fnum), newpos )
end function

function fb_FileSeekLarge FBCALL ( fnum as long, newpos as longint ) as long
    return fb_FileSeekEx( FB_FILE_TO_HANDLE(fnum), newpos )
end function
end extern