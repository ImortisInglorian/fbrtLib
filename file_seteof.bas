/' truncate / set end of file '/

#include "fb.bi"

extern "C"
/'
    Truncate a file opened for BINARY, RANDOM, OUTPUT, or APPEND

    Current position is used to determine where to truncate the file.
    Everything before the current position is kept, everything 
    afterwards including the current position is discarded.

    You might set the current position with SEEK. . Or current position
    may be determined by previous read/write operations.

    For BINARY, OUTPUT, and APPEND files the current position is the byte.

    For RANDOM files, the current position is the record.

	If the position less than current length of file, then the file is
	shortened.  If the position is after the current length of file, then
	the file is lengthened.
'/

function fb_FileSetEofEx( handle as FB_FILE ptr ) as long
    dim as long res

    FB_LOCK()

    if FB_HANDLE_USED(handle) <> 0 then
        FB_UNLOCK()
        return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
    end if

    select case handle->mode 
		case FB_FILE_MODE_BINARY, FB_FILE_MODE_RANDOM, FB_FILE_MODE_OUTPUT, FB_FILE_MODE_APPEND:
			'do nothing
		case else:
			FB_UNLOCK()
			return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
    end select

    /' flush stream buffers before truncating '/
    res = fb_FileFlushEx( handle, FALSE )

    /' call the platform specifc implementation '/
    if res = FB_RTERROR_OK then
        res = fb_hFileSetEofEx( cast(FILE ptr, handle->opaque) )
	end if
    FB_UNLOCK()

    return res
end function

/':::::'/
function fb_FileSetEof FBCALL ( fnum as long ) as long
    return fb_FileSetEofEx(FB_FILE_TO_HANDLE(fnum))
end function
end extern