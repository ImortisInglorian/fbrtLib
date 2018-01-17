/' put # function for wstrings '/

#include "fb.bi"

extern "C"
function fb_FilePutWstrEx( handle as FB_FILE ptr, _pos as fb_off_t, _str as FB_WCHAR ptr, _len as ssize_t ) as long
    dim as long res

	/' perform call ... but only if there's data ... '/
    if ( (_str <> NULL) and (_len > 0) ) then
        res = fb_FilePutDataEx( handle, _pos, cast(any ptr, _str), _len, TRUE, TRUE, TRUE )
    else
    	res = fb_ErrorSetNum( FB_RTERROR_OK )
	end if

	return res
end function

function fb_FilePutWstr FBCALL ( fnum as long, _pos as long, _str as FB_WCHAR ptr, str_len as ssize_t ) as long
	return fb_FilePutWstrEx(FB_FILE_TO_HANDLE(fnum), _pos, _str, str_len)
end function

function fb_FilePutWstrLarge FBCALL ( fnum as long, _pos as longint, _str as FB_WCHAR ptr, str_len as ssize_t ) as long
	return fb_FilePutWstrEx(FB_FILE_TO_HANDLE(fnum), _pos, _str, str_len)
end function
end extern