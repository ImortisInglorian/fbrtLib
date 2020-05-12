/' file device '/

#include "fb.bi"

extern "C"
function fb_DevFileReadWstr( handle as FB_FILE ptr, dst as FB_WCHAR ptr, pchars as size_t ptr ) as long
    dim as FILE ptr fp
    dim as size_t chars
    dim as ubyte ptr buffer

    FB_LOCK()

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

    chars = *pchars

	if ( chars < FB_LOCALBUFF_MAXLEN ) then
		buffer = allocate( chars + 1 )
	else
		buffer = allocate( chars + 1 )
	end if

	/' do read '/
	chars = fread( buffer, 1, chars, fp )
	buffer[chars] = 0

	/' convert to wchar, file should be opened with the ENCODING option
	   to allow UTF characters to be read '/
	fb_wstr_ConvFromA( dst, chars, buffer )

	deallocate(buffer)

	/' fill with nulls if at eof '/
	if ( chars <> *pchars ) then
        memset( cast(any ptr, @dst[chars]), 0, (*pchars - chars) * sizeof( FB_WCHAR ) )
	end if

    *pchars = chars

	FB_UNLOCK()
	
	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern