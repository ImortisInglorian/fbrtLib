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
private function hCheckBOM( byval fp as FILE ptr, byval encod as FB_FILE_ENCOD ) as long
    dim as long res, bom = 0

    select case ( encod )
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

	return res
end function

private function hWriteBOM( byval fp as FILE ptr, byval encod as FB_FILE_ENCOD ) as long
    dim as long bom

    select case ( encod )
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

function fb_DevFileOpenEncod ( handle as FB_FILE ptr, filename as const ubyte ptr, fname_len as size_t ) as long
	dim as FILE ptr fp = NULL
	dim as ubyte ptr openmask
	dim as ubyte ptr fname
	dim as long errorRet = FB_RTERROR_OK
	dim as long effective_mode

	FB_LOCK()

	fname = strdup( filename )

	/' Convert directory separators to whatever the current platform supports '/
	fb_hConvertPath( fname )

	handle->hooks = @hooks_dev_file
	effective_mode = handle->mode

	select case ( handle->mode )
		case FB_FILE_MODE_INPUT, FB_FILE_MODE_APPEND:
			/'	Even in append mode, try and open for reading first 
				because trying to read the BOM in "ab" mode will fail 
			'/
			openmask = sadd("rb")

		case FB_FILE_MODE_OUTPUT:
			/' will create the file if it doesn't exist '/
			openmask = sadd("wb")

		case else:
			errorRet = FB_RTERROR_ILLEGALFUNCTIONCALL
			Goto unlockExit
	end select

	/' try opening '/
	fp = fopen( fname, openmask )

	if( handle->mode = FB_FILE_MODE_APPEND ) then
		/'	if we weren't able to open an existing file for
			append, then try writing instead 
		'/
		if( fp = NULL ) then
			/' not found? handle mode as if output was specified '/
			effective_mode = FB_FILE_MODE_OUTPUT
			openmask = sadd("ab")
			fp = fopen( fname, openmask )
		else
			fb_hSetFileBufSize( fp )

			if( hCheckBOM( fp, handle->encod ) = 0 ) then
				errorRet = FB_RTERROR_FILEIO
				Goto fileCloseExit
			else
				/' if we have the correct BOM, then reopen the file for append ''/
				openmask = sadd("ab")
				fp = freopen( fname, openmask, fp )
			end if
		end if
	end if

	/' not opened '/
	if ( fp = NULL ) then
		errorRet = FB_RTERROR_FILENOTFOUND
		Goto unlockExit
	end if

	fb_hSetFileBufSize( fp )

	handle->opaque = fp

	if ( handle->access = FB_FILE_ACCESS_ANY) then
		handle->access = FB_FILE_ACCESS_READWRITE
	end if

	/' handle BOM '/
	select case ( effective_mode )
		case FB_FILE_MODE_INPUT:
			if ( hCheckBOM( fp, handle->encod ) = 0 ) then
				errorRet = FB_RTERROR_FILENOTFOUND
				Goto fileCloseExit
			end if

		case FB_FILE_MODE_OUTPUT:
			if ( hWriteBOM( fp, handle->encod ) = 0 ) then
				errorRet = FB_RTERROR_FILENOTFOUND
				Goto fileCloseExit
			end if
	end select

	/' calc file size '/
	handle->size = fb_DevFileGetSize( fp, handle->mode, handle->encod, TRUE )
	if ( handle->size = -1 ) then
		err = FB_RTERROR_ILLEGALFUNCTIONCALL
		Goto fileCloseExit
	end if

fileCloseExit:
	/' close the file if there was any error '/
	if( errorRet <> FB_RTERROR_OK ) then
		fclose( fp )
	end if
unlockExit:
	FB_UNLOCK()
deallocExit:
	free( fname )
	return fb_ErrorSetNum( errorRet )
end function
end extern
