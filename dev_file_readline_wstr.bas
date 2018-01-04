/' wstring LINE INPUT for file devices '/

#include "fb.bi"

extern "C"
function fb_DevFileReadLineWstr( handle as FB_FILE ptr, dst as FB_WCHAR ptr, dst_chars as ssize_t ) as long
    dim as long res
    dim as FILE ptr fp
    dim as FBSTRING temp = ( 0, 0, 0 )

	FB_LOCK()

    fp = cast(FILE ptr, handle->opaque)
    if ( fp = stdout or fp = stderr ) then
        fp = stdin
	end if

	if ( fp = NULL ) then
		FB_UNLOCK()
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

    res = fb_DevFileReadLineDumb( fp, @temp, NULL )

	/' convert to wchar, file should be opened with the ENCODING option
	   to allow UTF characters to be read '/
	if ( (res = FB_RTERROR_OK) or (res = FB_RTERROR_ENDOFFILE) ) then
    	fb_WstrAssignFromA( dst, dst_chars, cast(any ptr, @temp), -1 )
	end if

    fb_StrDelete( @temp )

	FB_UNLOCK()

	return res
end function
end extern