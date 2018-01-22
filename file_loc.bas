/' seek function and stmt '/

#include "fb.bi"

/':::::'/
extern "C"
function fb_FileLocationEx( handle as FB_FILE ptr ) as fb_off_t
    dim as fb_off_t _pos

    if ( FB_HANDLE_USED(handle) = NULL ) then
		return 0
	end if

    FB_LOCK()

    _pos = fb_FileTellEx( handle )

    if (_pos <> 0) then
        _pos -= 1
        select case ( handle->mode )
			case FB_FILE_MODE_INPUT, FB_FILE_MODE_OUTPUT:
				/' if in seq mode, divide by 128 (QB quirk) '/
				_pos /= 128
        end select
    end if

	FB_UNLOCK()

	return _pos
end function

/':::::'/
function fb_FileLocation FBCALL ( fnum as long ) as longint
    return fb_FileLocationEx( FB_FILE_TO_HANDLE(fnum) )
end function
end extern
