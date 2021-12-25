/' open file (vfs) functions '/

#include "fb.bi"

extern "C"
/'::::::'/
private function hFileGetSize( handle as FB_FILE ptr ) as fb_off_t
	dim as fb_off_t size = 0

	if ( handle->hooks->pfnSeek = NULL or handle->hooks->pfnTell = NULL ) then
		return size
	end if

	select case ( handle->mode )
		case FB_FILE_MODE_RANDOM, FB_FILE_MODE_BINARY, FB_FILE_MODE_INPUT:
			if ( handle->hooks->pfnSeek( handle, 0, SEEK_END ) <> 0 ) then
				return -1
			end if

			handle->hooks->pfnTell( handle, @size )

			handle->hooks->pfnSeek( handle, 0, SEEK_SET )

		case FB_FILE_MODE_APPEND:
			handle->hooks->pfnTell( handle, @size )
	end select

	return size
end function

/'::::::'/
function fb_FileOpenVfsRawEx( handle as FB_FILE ptr, filename as const ubyte ptr, filename_length as size_t, mode as ulong, access_ as ulong, _lock as ulong, _len as long, _encoding as FB_FILE_ENCOD , pfnOpen as FnFileOpen) as long
    dim as long result

    FB_LOCK()

    if (handle->hooks <> NULL) then
		FB_UNLOCK()
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
    end if

	__fb_ctx.do_file_reset = TRUE

    /' clear handle '/
    memset(handle, 0, sizeof(FB_FILE))

    /' specific file/device handles are stored in the member "opaque" '/
    handle->mode 	 = mode
    handle->encod 	 = _encoding
    handle->size 	 = 0
    handle->type 	 = FB_FILE_TYPE_VFS
    handle->access 	 = access_
    handle->lock 	 = _lock      /' lock mode not supported yet '/
    handle->line_length = 0

    /' reclen '/
    select case ( handle->mode )
		case FB_FILE_MODE_INPUT, FB_FILE_MODE_RANDOM, FB_FILE_MODE_OUTPUT:
			if ( _len <= 0 ) then
				_len = 128
			end if
			handle->len = _len

		case else:
			handle->len = 0
    end select

    if (pfnOpen = NULL) then
        /' unknown protocol! '/
		FB_UNLOCK()
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
    end if

    /' assume size won't be calculated by dev::open '/
    handle->size = -1

    result = pfnOpen(handle, filename, filename_length)

    DBG_ASSERT(result <> FB_RTERROR_OK or handle->hooks <> NULL)

    if ( result = 0 ) then
    	/' if size wasn't calculated yet, do it now '/
    	if( handle->size = -1 ) then
    		handle->size = hFileGetSize( handle )
		end if
    else
        memset(handle, 0, sizeof(FB_FILE))
    end if

    FB_UNLOCK()

    return result
end function

/'::::::'/
function fb_FileOpenVfsEx( handle as FB_FILE ptr, str_filename as FBSTRING ptr, mode as ulong, access_ as ulong, _lock as ulong, _len as long, _encoding as FB_FILE_ENCOD, pfnOpen as FnFileOpen ) as long
    dim as ubyte ptr filename
    dim as size_t filename_length

	/' copy file name '/
    filename_length = FB_STRSIZE( str_filename )
    filename = cast(ubyte ptr,  malloc( filename_length + 1 ))
    fb_hStrCopy( filename, str_filename->data, filename_length )
    filename[filename_length] = 0

    return fb_FileOpenVfsRawEx( handle, filename, filename_length, mode, access_, _lock, _len, _encoding, pfnOpen )
end function
end extern