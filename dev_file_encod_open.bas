/' UTF-encoded file devices open '/

#include "fb.bi"

dim shared as FB_FILE_HOOKS hooks_dev_file = ( _
    @fb_DevFileEof, _
    @fb_DevFileClose, _
    @fb_DevFileSeek, _
    @fb_DevFileTell, _
    @fb_DevFileReadEncod, _
    @fb_DevFileReadEncodWstr, _ 
    @fb_DevFileWriteEncod, _
    @fb_DevFileWriteEncodWstr, _
    @fb_DevFileLock, _
    @fb_DevFileUnlock, _
    @fb_DevFileReadLineEncod, _
	@fb_DevFileReadLineEncodWstr, _
    NULL, _
    @fb_DevFileFlush)

extern "C"
private function hCheckBOM( handle as FB_FILE ptr ) as long
    dim as long res, bom = 0
    dim as FILE ptr fp = cast(FILE ptr, handle->opaque)

    if ( handle->mode = FB_FILE_MODE_APPEND ) then
    	fseek( fp, 0, SEEK_SET )
	end if

    select case ( handle->encod )
		case FB_FILE_ENCOD_UTF8:
			if ( fread( @bom, 3, 1, fp ) <> 1 ) then
				return 0
			end if

			res = (bom = &h00BFBBEF)

		case FB_FILE_ENCOD_UTF16:
			if ( fread( @bom, sizeof( UTF_16 ), 1, fp ) <> 1 ) then
				return 0
			end if

			/' !!!FIXME!!! only litle-endian supported '/
			res = (bom = &h0000FEFF)

		case FB_FILE_ENCOD_UTF32:
			if ( fread( @bom, sizeof( UTF_32 ), 1, fp ) <> 1 ) then
				return 0
			end if

			/' !!!FIXME!!! only litle-endian supported '/
			res = (bom = &h0000FEFF)

		case else:
			res = 0
    end select

    if ( handle->mode = FB_FILE_MODE_APPEND ) then
    	fseek( fp, 0, SEEK_END )
	end if

	return res
end function

private function hWriteBOM( handle as FB_FILE ptr ) as long
    dim as long bom
    dim as FILE ptr fp = cast(FILE ptr, handle->opaque)

    select case ( handle->encod )
		case FB_FILE_ENCOD_UTF8:
			bom = &h00BFBBEF
			if ( fwrite( @bom, 3, 1, fp ) <> 1 ) then
				return 0
			end if

		case FB_FILE_ENCOD_UTF16:
			/' !!!FIXME!!! only litle-endian supported '/
			bom = &h0000FEFF
			if ( fwrite( @bom, sizeof( UTF_16 ), 1, fp ) <> 1 ) then
				return 0
			end if

		case FB_FILE_ENCOD_UTF32:
			/' !!!FIXME!!! only litle-endian supported '/
			bom = &h0000FEFF
			if ( fwrite( @bom, sizeof( UTF_32 ), 1, fp ) <> 1 ) then
				return 0
			end if

		case else:
			return 0
	end select

	return 1
end function

function fb_DevFileOpenEncod ( handle as FB_FILE ptr, filename as ubyte ptr, fname_len as size_t ) as long
    dim as FILE ptr fp = NULL
    dim as ubyte ptr openmask
    dim as ubyte ptr fname

    FB_LOCK()

    fname = cast(ubyte ptr, malloc(fname_len + 1))
    memcpy(fname, filename, fname_len)
    fname[fname_len] = 0

    /' Convert directory separators to whatever the current platform supports '/
    fb_hConvertPath( fname )

    handle->hooks = @hooks_dev_file

    openmask = NULL
    select case ( handle->mode )
		case FB_FILE_MODE_APPEND:
			/' will create the file if it doesn't exist '/
			openmask = sadd("ab")

		case FB_FILE_MODE_INPUT:
			/' will fail if file doesn't exist '/
			openmask = sadd("rb")

		case FB_FILE_MODE_OUTPUT:
			/' will create the file if it doesn't exist '/
			openmask = sadd("wb")

		case else:
			FB_UNLOCK()
			return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
    end select

    /' try opening '/
	fp = fopen( fname, openmask )
    if ( fp = NULL ) then
    	FB_UNLOCK()
        return fb_ErrorSetNum( FB_RTERROR_FILENOTFOUND )
    end if

    fb_hSetFileBufSize( fp )

    handle->opaque = fp

    if ( handle->access = FB_FILE_ACCESS_ANY) then
        handle->access = FB_FILE_ACCESS_READWRITE
	end if

    /' handle BOM '/
    select case ( handle->mode )
		case FB_FILE_MODE_APPEND, FB_FILE_MODE_INPUT:
			if ( hCheckBOM( handle ) = 0 ) then
				fclose( fp )
				FB_UNLOCK()
				return fb_ErrorSetNum( FB_RTERROR_FILENOTFOUND )
			end if

		case FB_FILE_MODE_OUTPUT:
			if ( hWriteBOM( handle ) = 0 ) then
				fclose( fp )
				FB_UNLOCK()
				return fb_ErrorSetNum( FB_RTERROR_FILENOTFOUND )
			end if
	end select

	/' calc file size '/
    handle->size = fb_DevFileGetSize( fp, handle->mode, handle->encod, TRUE )
    if ( handle->size = -1 ) then
    	fclose( fp )
        FB_UNLOCK()
        return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

    FB_UNLOCK()

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern