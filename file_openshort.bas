/' short version of OPEN '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_FileOpenShort FBCALL ( str_file_mode as FBSTRING ptr, _
								   fnum as long, _
								   filename as FBSTRING ptr, _
								   _len as long, _
								   str_access_mode as FBSTRING ptr, _
								   str_lock_mode as FBSTRING ptr) as long
    dim as ulong file_mode = 0
    dim as long access_mode = -1, lock_mode = -1
    dim as size_t file_mode_len, access_mode_len, lock_mode_len
    dim as long error_code = FB_RTERROR_OK

    if ( FB_FILE_INDEX_VALID( fnum ) = NULL ) then
    	return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

    file_mode_len = FB_STRSIZE( str_file_mode )
    access_mode_len = FB_STRSIZE( str_access_mode )
    lock_mode_len = FB_STRSIZE( str_lock_mode )

    if ( file_mode_len <> 1 or access_mode_len > 2 or lock_mode_len > 2 ) then
		error_code = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
    end if

    if ( error_code = FB_RTERROR_OK ) then
        if( strcasecmp(str_file_mode->data, "B") = 0 ) then
            file_mode = FB_FILE_MODE_BINARY
        elseif ( strcasecmp(str_file_mode->data, "I") = 0 ) then
            file_mode = FB_FILE_MODE_INPUT
        elseif ( strcasecmp(str_file_mode->data, "O") = 0 ) then
            file_mode = FB_FILE_MODE_OUTPUT
        elseif ( strcasecmp(str_file_mode->data, "A") = 0 ) then
            file_mode = FB_FILE_MODE_APPEND
        elseif ( strcasecmp(str_file_mode->data, "R") = 0 ) then
            file_mode = FB_FILE_MODE_RANDOM
        else
            error_code = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
        end if
    end if

    if ( access_mode_len <> 0 and error_code = FB_RTERROR_OK ) then
        if ( strcasecmp(str_access_mode->data, "R") = 0 ) then
            access_mode = FB_FILE_ACCESS_READ
        elseif ( strcasecmp(str_access_mode->data, "W") = 0 ) then
            access_mode = FB_FILE_ACCESS_WRITE
        elseif( strcasecmp(str_access_mode->data, "RW") = 0 ) then
            access_mode = FB_FILE_ACCESS_READWRITE
        else
            error_code = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
        end if
    end if

    if ( lock_mode_len <> 0 and error_code = FB_RTERROR_OK ) then
        if ( strcasecmp(str_lock_mode->data, "S") = 0 ) then
            lock_mode = FB_FILE_LOCK_SHARED
        elseif ( strcasecmp(str_lock_mode->data, "R") = 0 ) then
            lock_mode = FB_FILE_LOCK_READ
        elseif ( strcasecmp(str_lock_mode->data, "W") = 0 ) then
            lock_mode = FB_FILE_LOCK_WRITE
        elseif ( strcasecmp(str_lock_mode->data, "RW") = 0 ) then
            lock_mode = FB_FILE_LOCK_READWRITE
        else
            error_code = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
        end if
    end if

    if( error_code <> FB_RTERROR_OK ) then
        return error_code
	end if

    if ( access_mode = -1 ) then
        /' determine the default access mode for a given file mode '/
        select case (file_mode)
			case FB_FILE_MODE_INPUT:
				access_mode = FB_FILE_ACCESS_READ
			case FB_FILE_MODE_OUTPUT, FB_FILE_MODE_APPEND:
				access_mode = FB_FILE_ACCESS_WRITE
			case else:
				access_mode = FB_FILE_ACCESS_ANY
        end select
    end if

    if ( lock_mode = -1 ) then
        /' determine the default lock mode for a given file mode '/
        select case (file_mode)
			case FB_FILE_MODE_INPUT:
				lock_mode = FB_FILE_LOCK_SHARED
			case else:
				lock_mode = FB_FILE_LOCK_WRITE
        end select
    end if

    return fb_FileOpen( filename, _
                        file_mode, _
                        access_mode, _
                        lock_mode, _
                        fnum, _
                        _len )
end function
end extern