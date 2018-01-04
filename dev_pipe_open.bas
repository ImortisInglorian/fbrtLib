/' file device '/

#include "fb.bi"

extern "C"
#ifdef HOST_XBOX

function fb_DevPipeOpen( handle as FB_FILE ptr, filename as ubyte const ptr, filename_len ) as long
	return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
end function

#else

dim shared as FB_FILE_HOOKS hooks_dev_pipe = ( @fb_DevFileEof _
											 , @fb_DevPipeClose _
											 , NULL _
											 , NULL _
											 , @fb_DevFileRead _ 'Warning here?
											 , @fb_DevFileReadWstr _
											 , @fb_DevFileWrite _
											 , @fb_DevFileWriteWstr _
											 , NULL _
											 , NULL _
											 , @fb_DevFileReadLine _
											 , @fb_DevFileReadLineWstr _
											 , NULL _
											 , NULL )

function fb_DevPipeOpen( handle as FB_FILE ptr, filename as ubyte const ptr, filename_len as size_t ) as long
    dim as long res = fb_ErrorSetNum( FB_RTERROR_OK )
    dim as FILE ptr fp = NULL
    dim as ubyte openmask(0 to 15)

    FB_LOCK()

    handle->hooks = @hooks_dev_pipe

    openmask(0) = 0

    select case ( handle->mode )
		case FB_FILE_MODE_INPUT:
			if ( handle->access = FB_FILE_ACCESS_ANY) then
				handle->access = FB_FILE_ACCESS_READ
			end if

			if( handle->access <> FB_FILE_ACCESS_READ ) then
				res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
			end if

			strcpy( @openmask(0), sadd("r") )

		case FB_FILE_MODE_OUTPUT:
			if ( handle->access = FB_FILE_ACCESS_ANY) then
				handle->access = FB_FILE_ACCESS_WRITE
			end if

			if( handle->access <> FB_FILE_ACCESS_WRITE ) then
				res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
			end if

			strcpy( @openmask(0), sadd("w") )

		case FB_FILE_MODE_BINARY:
			if ( handle->access = FB_FILE_ACCESS_ANY) then
				handle->access = FB_FILE_ACCESS_WRITE
			end if

			strcpy( @openmask(0), iif(handle->access = FB_FILE_ACCESS_WRITE, sadd("wb"), sadd("rb")) )

		case else:
			res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
    end select

    if ( res = FB_RTERROR_OK ) then
        /' try to open/create pipe '/
		fp = popen( filename, @openmask(0) )
        if( fp = NULL ) then
            res = fb_ErrorSetNum( FB_RTERROR_FILENOTFOUND )
        end if
        handle->opaque = fp
        handle->type = FB_FILE_TYPE_PIPE
    end if

    FB_UNLOCK()

	return res
end function

#endif
end extern