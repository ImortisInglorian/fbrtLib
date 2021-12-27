/' put # function for strings '/

#include "fb.bi"

extern "C"
function fb_FilePutStrEx( handle as FB_FILE ptr, _pos as fb_off_t, _str as any ptr, str_len as ssize_t ) as long
	dim as long res
	dim as ssize_t _len
    dim as ubyte ptr _data

    /' get string data len '/
	FB_STRSETUP_DYN( _str, str_len, _data, _len )

	/' perform call ... but only if there's data ... '/
    if ( (_data <> NULL) and (_len > 0) ) then
        res = fb_FilePutDataEx( handle, _pos, _data, _len, TRUE, TRUE, FALSE )
    else
    	res = fb_ErrorSetNum( FB_RTERROR_OK )
	end if

	return res
end function

function fb_FilePutStr FBCALL ( fnum as long, _pos as long, _str as any ptr, str_len as ssize_t ) as long
	return fb_FilePutStrEx(FB_FILE_TO_HANDLE(fnum), _pos, _str, str_len)
end function

function fb_FilePutStrLarge FBCALL( fnum as long, _pos as longint, _str as any ptr, str_len as ssize_t ) as long
	return fb_FilePutStrEx(FB_FILE_TO_HANDLE(fnum), _pos, _str, str_len)
end function
end extern