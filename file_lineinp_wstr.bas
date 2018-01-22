/' line input function for wstrings '/

#include "fb.bi"

extern "C"
function fb_FileLineInputWstr FBCALL ( fnum as long, dst as FB_WCHAR ptr, max_chars as ssize_t ) as long
    dim as FB_FILE ptr handle = FB_FILE_TO_HANDLE(fnum)

    if ( FB_HANDLE_USED(handle) = NULL ) then
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

    if ( handle->hooks->pfnReadLineWstr = NULL ) then
        return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

    return handle->hooks->pfnReadLineWstr( handle, dst, max_chars )
end function
end extern