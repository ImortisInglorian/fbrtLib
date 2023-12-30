/' file device '/

#include "fb.bi"

extern "C"
#if defined(HOST_XBOX) or defined(HOST_JS)

function fb_DevPipeOpen( handle as FB_FILE ptr, filename as const ubyte ptr, filename_len ) as long
	return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
end function

#else

dim shared as FB_FILE_HOOKS hooks_dev_pipe = ( _
	@fb_DevFileEof _
	, @fb_DevPipeClose _
	, NULL _
	, NULL _
	, @fb_DevFileRead _ 
	, @fb_DevFileReadWstr _
	, @fb_DevFileWrite _ 
	, @fb_DevFileWriteWstr _
	, NULL _
	, NULL _
	, @fb_DevFileReadLine _
	, @fb_DevFileReadLineWstr _
	, NULL _
	, @fb_DevFileFlush )

function fb_DevPipeOpen( handle as FB_FILE ptr, filename as const ubyte ptr, filename_len as size_t ) as long
    dim as long res = fb_ErrorSetNum( FB_RTERROR_OK )
    dim as FILE ptr fp = NULL
    dim as ubyte ptr openmask = NULL

    FB_LOCK()

    handle->hooks = @hooks_dev_pipe

    select case ( handle->mode )
		case FB_FILE_MODE_INPUT:
			if ( handle->access = FB_FILE_ACCESS_ANY) then
				handle->access = FB_FILE_ACCESS_READ
			end if

			if( handle->access <> FB_FILE_ACCESS_READ ) then
				res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
			end if

			openmask = sadd( "r" )

		case FB_FILE_MODE_OUTPUT:
			if ( handle->access = FB_FILE_ACCESS_ANY) then
				handle->access = FB_FILE_ACCESS_WRITE
			end if

			if( handle->access <> FB_FILE_ACCESS_WRITE ) then
				res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
			end if

			openmask = sadd( "w" )

		case FB_FILE_MODE_BINARY:
			if ( handle->access = FB_FILE_ACCESS_ANY) then
				handle->access = FB_FILE_ACCESS_WRITE
			end if

			openmask = iif(handle->access = FB_FILE_ACCESS_WRITE, sadd( "wb" ), sadd( "rb" ) )

		case else:
			res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
    end select

    if ( res = FB_RTERROR_OK ) then
        /' try to open/create pipe '/
	fp = popen( cast( ZString ptr, filename ), openmask )
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
