/' wstring to ascii file writing function '/

#include "fb.bi"

extern "C"
function fb_DevFileWriteWstr( handle as FB_FILE ptr, src as FB_WCHAR const ptr, chars as size_t ) as long
    dim as FILE ptr fp
    dim as ubyte ptr buffer
    dim as long res

    FB_LOCK()

    fp = cast(FILE ptr, handle->opaque)

	if ( fp = NULL ) then
		FB_UNLOCK()
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	if ( chars < FB_LOCALBUFF_MAXLEN ) then
		buffer = allocate( chars + 1 )
	else
		buffer = allocate( chars + 1 )
	end if

	/' convert to ascii, file should be opened with the ENCODING option
	   to allow UTF characters to be written '/
	fb_wstr_ConvToA( buffer, chars, src )

	/' do write '/
	res = (fwrite( cast(any ptr, buffer), 1, chars, fp ) = chars)

	deallocate( buffer )

	FB_UNLOCK()

	return fb_ErrorSetNum( iif(res <> 0, FB_RTERROR_OK, FB_RTERROR_FILEIO) )
end function
end extern