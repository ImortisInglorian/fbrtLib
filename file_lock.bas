/' lock and unlock functions '/

#include "fb.bi"

/':::::'/
extern "C"
function fb_FileLockEx( handle as FB_FILE ptr, inipos as fb_off_t, endpos as fb_off_t ) as long
	dim as long res

	if ( inipos < 1 or endpos <= inipos ) then
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

    if ( FB_HANDLE_USED(handle) = NULL ) then
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	FB_LOCK()

    /' convert to 0 based file i/o '/
    inipos -= 1
    if ( handle->mode = FB_FILE_MODE_RANDOM ) then
        inipos = handle->len * inipos
        endpos = inipos + handle->len
    else
        endpos -= 1
    end if

    if ( handle->hooks->pfnLock <> NULL) then
        res = handle->hooks->pfnLock( handle, inipos-1, endpos - inipos )
    else
        res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
    end if

	FB_UNLOCK()

	return res
end function

/':::::'/
function fb_FileLock FBCALL ( fnum as long, inipos as ulong, endpos as ulong ) as long
    return fb_FileLockEx(FB_FILE_TO_HANDLE(fnum), inipos, endpos)
end function

/':::::'/
function fb_FileLockLarge FBCALL ( fnum as long, inipos as longint, endpos as longint ) as long
    return fb_FileLockEx(FB_FILE_TO_HANDLE(fnum), inipos, endpos)
end function

/':::::'/
function fb_FileUnlockEx( handle as FB_FILE ptr, inipos as fb_off_t, endpos as fb_off_t ) as long
	dim as long res

	if ( inipos < 1 or endpos <= inipos ) then
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	FB_LOCK()

    /' convert to 0 based file i/o '/
    inipos -= 1
    if ( handle->mode = FB_FILE_MODE_RANDOM ) then
        inipos = handle->len * inipos
        endpos = inipos + handle->len
    else
        endpos -= 1
    end if

    if ( handle->hooks <> NULL ) then
        if (handle->hooks->pfnUnlock <> NULL) then
            res = handle->hooks->pfnUnlock( handle, inipos, endpos - inipos )
        else
            res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
        end if

    else
		res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	FB_UNLOCK()

	return res
end function

/':::::'/
function fb_FileUnlock FBCALL ( fnum as long, inipos as ulong, endpos as ulong ) as long
    if ( FB_FILE_INDEX_VALID(fnum) = 0 ) then
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if
    return fb_FileUnlockEx(FB_FILE_TO_HANDLE(fnum), inipos, endpos)
end function

/':::::'/
function fb_FileUnlockLarge FBCALL ( fnum as long, inipos as longint, endpos as longint ) as long
    if ( FB_FILE_INDEX_VALID(fnum) = 0 ) then
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if
    return fb_FileUnlockEx(FB_FILE_TO_HANDLE(fnum), inipos, endpos)
end function
end extern