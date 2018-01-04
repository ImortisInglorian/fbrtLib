/' UTF-encoded input for file devices '/

#include "fb.bi"

extern "C"
function fb_DevFileReadEncod( handle as FB_FILE ptr, dst as any ptr, max_chars as size_t ptr ) as long
    dim as FILE ptr fp
    dim as size_t chars

    FB_LOCK()

    chars = *max_chars

    fp = cast(FILE ptr, handle->opaque)
    if ( fp = stdout or fp = stderr ) then
        fp = stdin
	end if

	if ( fp = NULL ) then
		FB_UNLOCK()
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	/' do read '/
	chars = fb_hFileRead_UTFToChar( fp, handle->encod, dst, chars )

	/' fill with nulls if at eof '/
	if ( chars <> *max_chars ) then
        memset( (cast(ubyte ptr, dst)) + chars, 0, *max_chars - chars )
	end if

    *max_chars = chars

	FB_UNLOCK()

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern