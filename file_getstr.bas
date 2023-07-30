/' get # function for strings '/

#include "fb.bi"

extern "C"
function fb_FileGetStrEx( handle as FB_FILE ptr, _pos as fb_off_t, _str as any ptr, str_len as ssize_t, bytesread as size_t ptr ) as long
    dim as long res
    dim as size_t _len
	dim as ubyte ptr _data

	if ( bytesread <> 0 ) then
		*bytesread = 0
	end if

    if ( FB_HANDLE_USED(handle) = 0 ) then
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

    /' get string len '/
	FB_STRSETUP_DYN( _str, str_len, _data, _len )

	/' perform call ... but only if there's data ... '/
    if ( (_data <> NULL) and (_len > 0) ) then
        res = fb_FileGetDataEx( handle, _pos, _data, _len, @_len, TRUE, FALSE )
        _data[_len] = 0                                /' add the null-term '/
    else
		/' no/empty destination string '/
		res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
    end if

	if ( bytesread <> 0 ) then
		*bytesread = _len
	end if

	/' del if temp '/
	if ( str_len = -1 ) then
		fb_hStrDelTemp( cast(FBSTRING ptr, _str) )		/' will free the temp desc if fix-len passed '/
	end if

	return res
end function

function fb_FileGetStr FBCALL ( fnum as long, _pos as long, _str as any ptr, str_len as ssize_t ) as long
	return fb_FileGetStrEx(FB_FILE_TO_HANDLE(fnum), _pos, _str, str_len, NULL)
end function

function fb_FileGetStrLarge FBCALL ( fnum as long, _pos as longint, _str as any ptr, str_len as ssize_t ) as long
	return fb_FileGetStrEx(FB_FILE_TO_HANDLE(fnum), _pos, _str, str_len, NULL)
end function

function fb_FileGetStrIOB FBCALL ( fnum as long, _pos as long, _str as any ptr, str_len as ssize_t, bytesread as size_t ptr ) as long
	return fb_FileGetStrEx(FB_FILE_TO_HANDLE(fnum), _pos, _str, str_len, bytesread)
end function

function fb_FileGetStrLargeIOB FBCALL ( fnum as long, _pos as longint, _str as any ptr, str_len as ssize_t, bytesread as size_t ptr ) as long
	return fb_FileGetStrEx(FB_FILE_TO_HANDLE(fnum), _pos, _str, str_len, bytesread)
end function
end extern