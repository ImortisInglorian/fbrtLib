/' CLOSE function '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_FileCloseEx( handle as FB_FILE ptr ) as long
    FB_LOCK()

    if ( FB_HANDLE_USED(handle) = 0 ) then
    	FB_UNLOCK()
        return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
    end if

    /' close VFS handle '/
    DBG_ASSERT(handle->hooks->pfnClose <> NULL)
    dim as long result = handle->hooks->pfnClose( handle )
    if (result <> 0) then
        FB_UNLOCK()
        return result
    end if

    /' clear structure '/
    memset(handle, 0, sizeof(FB_FILE))

    FB_UNLOCK()

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function

/':::::'/
function fb_FileClose FBCALL ( fnum as long ) as long
	/' make CLOSE #0 return an error
	(QBASIC quirk: return no error; old FB quirk: close all files '/
	if ( fnum = 0 ) then
		/'fb_FileReset( )'/
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if
	return fb_FileCloseEx( FB_FILE_TO_HANDLE(fnum) )
end function

/':::::'/
function fb_FileCloseAll FBCALL ( ) as long
	/' As in QB: CLOSE w/o arguments closes all files '/
	fb_FileReset( )
	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern