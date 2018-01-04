/' UTF-encoded file writing '/

#include "fb.bi"

extern "C"
function fb_DevFileWriteEncod( handle as FB_FILE ptr, buffer as any const ptr, chars as size_t ) as long
    dim as FILE ptr fp
    dim as ubyte ptr encod_buffer
	dim as ssize_t bytes

    FB_LOCK()

    fp = cast(FILE ptr, handle->opaque)
	if ( fp = NULL ) then
		FB_UNLOCK()
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	/' convert (note: encoded file can only be opened in text-mode, so no
	   			PUT# is allowed, no binary data should be emitted ever) '/
	encod_buffer = fb_CharToUTF( handle->encod, cast(ubyte const ptr, buffer), chars, NULL, @bytes )

	if ( encod_buffer <> NULL ) then
		/' do write '/
		if ( fwrite( encod_buffer, 1, bytes, fp ) <> cast(size_t, bytes) ) then
			FB_UNLOCK()
			return fb_ErrorSetNum( FB_RTERROR_FILEIO )
		end if

		if ( encod_buffer <> buffer ) then
			free( encod_buffer )
		end if
	end if

	FB_UNLOCK()

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern