/' UTF-encoded wstring file writing '/

#include "fb.bi"

extern "C"
function fb_DevFileWriteEncodWstr( handle as FB_FILE ptr, buffer as FB_WCHAR const ptr, chars as size_t ) as long
    dim as FILE ptr fp
    dim as ubyte ptr encod_buffer
	dim as ssize_t bytes

    FB_LOCK()

    fp = cast(FILE ptr, handle->opaque)
	if ( fp = NULL ) then
		FB_UNLOCK()
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	/' convert (note: only wstrings will be written using this function,
				so there's no binary data to care) '/
	encod_buffer = fb_WCharToUTF( handle->encod, buffer, chars, NULL, @bytes )

	if ( encod_buffer <> NULL ) then
		/' do write '/
		if ( fwrite( encod_buffer, 1, bytes, fp ) <> cast(size_t, bytes) ) then
			FB_UNLOCK()
			return fb_ErrorSetNum( FB_RTERROR_FILEIO )
		end if

		if ( encod_buffer <> cast(ubyte ptr, buffer) ) then
			free( encod_buffer )
		end if
	end if

	FB_UNLOCK()

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern