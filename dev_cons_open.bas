/' file device '/

#include "fb.bi"

dim shared as FB_FILE_HOOKS hooks_dev_cons = ( _
    @fb_DevFileEof, _
    @fb_DevStdIoClose, _
    NULL, _
    NULL, _
    @fb_DevFileRead, _
    @fb_DevFileReadWstr, _
    @fb_DevFileWrite, _
    @fb_DevFileWriteWstr, _
    NULL, _
    NULL, _
    @fb_DevFileReadLine, _
    @fb_DevFileReadLineWstr, _
    NULL, _
    NULL _
)

extern "C"
function fb_DevConsOpen( handle as FB_FILE ptr, filename as ubyte const ptr, filename_len as size_t ) as long
    select case ( handle->mode )
		case FB_FILE_MODE_APPEND, FB_FILE_MODE_INPUT, FB_FILE_MODE_OUTPUT:
			'nothing

		case else:
			return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
    end select

    FB_LOCK()

    handle->hooks = @hooks_dev_cons

    if ( handle->access = FB_FILE_ACCESS_ANY) then
        handle->access = FB_FILE_ACCESS_WRITE
	end if

	handle->opaque = iif(handle->mode = FB_FILE_MODE_INPUT, stdin, stdout)
    handle->type = FB_FILE_TYPE_PIPE

    FB_UNLOCK()

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern