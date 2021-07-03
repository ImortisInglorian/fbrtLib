/' TELL() and TELL '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_FileTellEx( handle as FB_FILE ptr ) as fb_off_t
	dim as fb_off_t _pos

    if ( FB_HANDLE_USED(handle) = 0 ) then
		return 0
	end if

	FB_LOCK()

    if (handle->hooks->pfnTell <> NULL) then
        if (handle->hooks->pfnTell( handle, @_pos ) <> 0) then
            _pos = -1
        end if
    else
        _pos = -1
    end if

    if (_pos <> -1) then
        /' Adjust real position by number of characters in put back buffer '/
        _pos -= handle->putback_size

        /' if in random mode, divide by reclen '/
        if ( handle->mode = FB_FILE_MODE_RANDOM ) then
            _pos /= handle->len
		end if
    end if

	FB_UNLOCK()

	return _pos + 1
end function

/':::::'/
function fb_FileTell FBCALL ( fnum as long ) as longint
    return fb_FileTellEx( FB_FILE_TO_HANDLE(fnum) )
end function
end extern