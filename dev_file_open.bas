/' file device '/

#include "fb.bi"

dim shared as FB_FILE_HOOKS hooks_dev_file = ( _
    @fb_DevFileEof, _
    @fb_DevFileClose, _
    @fb_DevFileSeek, _
    @fb_DevFileTell, _
    @fb_DevFileRead, _
    @fb_DevFileReadWstr, _ 'Worning here?
    @fb_DevFileWrite, _
    @fb_DevFileWriteWstr, _
    @fb_DevFileLock, _
    @fb_DevFileUnlock, _
    @fb_DevFileReadLine, _
    @fb_DevFileReadLineWstr, _
    NULL, _
    @fb_DevFileFlush)

extern "C"
sub fb_hSetFileBufSize( fp as FILE ptr )
	/' change the default buffer size '/
	setvbuf( fp, NULL, _IOFBF, FB_FILE_BUFSIZE )
	/' Note: setvbuf() is only allowed to be called before doing any I/O
	   with that FILE handle '/
end sub

function fb_DevFileOpen( handle as FB_FILE ptr, filename as ubyte const ptr, fname_len as size_t ) as long
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
			openmask = sadd("rt")

		case FB_FILE_MODE_OUTPUT:
			/' will create the file if it doesn't exist '/
			openmask = sadd("wb")

		case FB_FILE_MODE_BINARY, FB_FILE_MODE_RANDOM:

			select case ( handle->access )
				case FB_FILE_ACCESS_WRITE:
					openmask = sadd("wb")
				case FB_FILE_ACCESS_READ:
					openmask = sadd("rb")
				case else:
					/' w+ would erase the contents '/
					openmask = sadd("r+b")
			end select
    end select

    if ( openmask = NULL ) then
        FB_UNLOCK()
        return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
    end if

    handle->size = -1

    select case (handle->mode)
		case FB_FILE_MODE_BINARY, FB_FILE_MODE_RANDOM:
			/' try opening '/
			fp = fopen( fname, openmask )
			if ( fp = NULL ) then
				/' if file was not found and in READ/WRITE (or ANY) mode,
				 * create it '/
				if ( handle->access = FB_FILE_ACCESS_ANY or handle->access = FB_FILE_ACCESS_READWRITE ) then
					fp = fopen( fname, "w+b" )

					/' if file could not be created and in ANY mode, try opening as read-only '/
					if ( (fp = NULL) and (handle->access=FB_FILE_ACCESS_ANY) ) then
						fp = fopen( fname, "rb" )
						if (fp <> NULL) then
							' don't forget to set the effective access mode ...
							handle->access = FB_FILE_ACCESS_READ
						end if
					end if
				end if

				if ( fp = NULL ) then
					FB_UNLOCK()
					return fb_ErrorSetNum( FB_RTERROR_FILENOTFOUND )
				end if
			end if

			fb_hSetFileBufSize( fp )

		/' special case, fseek() is unreliable in text-mode, so the file size
		   must be calculated in binary mode - bin mode can't be used for text
		   input because newlines must be converted, and EOF char (27) handled '/
		case FB_FILE_MODE_INPUT:
			/' try opening in binary mode '/
			fp = fopen( fname, "rb" )
			if( fp = NULL ) then
				FB_UNLOCK()
				return fb_ErrorSetNum( FB_RTERROR_FILENOTFOUND )
			end if

			fb_hSetFileBufSize( fp )

			/' calc file size '/
			handle->size = fb_DevFileGetSize( fp, FB_FILE_MODE_INPUT, handle->encod, FALSE )
			if ( handle->size = -1 ) then
				fclose( fp )
				FB_UNLOCK()
				return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
			end if

			/' now reopen it in text-mode '/
			fp = fopen( fname, "rb" )
			if ( fp = NULL ) then
				FB_UNLOCK()
				return fb_ErrorSetNum( FB_RTERROR_FILENOTFOUND )
			end if

			fb_hSetFileBufSize( fp )

			/' skip BOM, if any '/
			fb_hDevFileSeekStart( fp, FB_FILE_MODE_INPUT, handle->encod, FALSE )

		case else:
			/' try opening '/
			fp = fopen( fname, openmask )
			if ( fp = NULL ) then
				FB_UNLOCK()
				return fb_ErrorSetNum( FB_RTERROR_FILENOTFOUND )
			end if

			fb_hSetFileBufSize( fp )
    end select

	if ( handle->size = -1 ) then
        /' calc file size '/
        handle->size = fb_DevFileGetSize( fp, handle->mode, handle->encod, TRUE )
        if ( handle->size = -1 ) then
        	fclose( fp )
            FB_UNLOCK()
        	return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
        end if
    end if

    handle->opaque = fp
    if (handle->access = FB_FILE_ACCESS_ANY) then
        handle->access = FB_FILE_ACCESS_READWRITE
	end if

    /' We just need this for TAB(n) and SPC(n) '/
    if ( strcasecmp( fname, "CON" ) = 0 ) then
        handle->type = FB_FILE_TYPE_CONSOLE
	end if

    FB_UNLOCK()

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern
