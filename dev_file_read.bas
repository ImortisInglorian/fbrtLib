/' file device '/

#include "fb.bi"

extern "C"
function fb_DevFileRead( handle as FB_FILE ptr, dst as any ptr, pLength as size_t ptr ) as long
    dim as FILE ptr fp
    dim as size_t rlen, length

    FB_LOCK()

    DBG_ASSERT(pLength <> NULL)
    length = *pLength

    if ( handle = NULL ) then
    	fp = stdin
    else
    	fp = cast(FILE ptr, handle->opaque)
    	if ( fp = stdout or fp = stderr ) then
        	fp = stdin
		end if

		if ( fp = NULL ) then
			FB_UNLOCK()
			return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
		end if
	end if

	/' do read '/
	rlen = fread( dst, 1, length, fp )
	/' fill with nulls if at eof '/
	if ( rlen <> length ) then
        memset( cast(ubyte ptr,dst) + rlen, 0, length - rlen )
	end if

    *pLength = rlen

	FB_UNLOCK()

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern